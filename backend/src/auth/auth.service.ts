import {
  Injectable,
  BadRequestException,
} from '@nestjs/common';

import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';

import * as bcrypt from 'bcrypt';

import { JwtService } from '@nestjs/jwt';

import { OtpCode } from './entities/otp-code.entity';
import { User } from '../users/entities/user.entity';

import { randomInt } from 'crypto';

import { SmsService } from './sms.service';


const OTP_LENGTH = 6;

const OTP_TTL_MINUTES = 5;

const MAX_OTP_ATTEMPTS = 5;

const RESEND_COOLDOWN_SECONDS = 60;


@Injectable()
export class AuthService {

  constructor(

    @InjectRepository(OtpCode)
    private readonly otpRepository: Repository<OtpCode>,

    @InjectRepository(User)
    private readonly userRepository: Repository<User>,

    private readonly jwtService: JwtService,

    private readonly smsService: SmsService,

  ) {}


  // ==========================================
  // CHECK PHONE
  // ==========================================

  async checkPhone(phone: string) {

    phone = phone.trim();

    const user = await this.userRepository.findOne({
      where: { phone },
    });

    return {
      exists: !!user,
    };
  }


  // ==========================================
  // SEND OTP
  // ==========================================

  async sendOtp(phone: string) {

    phone = phone.trim();

    // Check user exists
    const user = await this.userRepository.findOne({
      where: { phone },
    });

    if (!user) {
      throw new BadRequestException(
        'Phone number is not registered.',
      );
    }


    // ------------------------------------------
    // Check resend cooldown
    // ------------------------------------------

    const latestOtp = await this.otpRepository.findOne({
      where: {
        phone,
        used: false,
      },
      order: {
        created_at: 'DESC',
      },
    });


    if (latestOtp) {

      const now = new Date();

      const secondsPassed =
        (now.getTime() - latestOtp.created_at.getTime()) / 1000;


      if (secondsPassed < RESEND_COOLDOWN_SECONDS) {

        const remaining =
          Math.ceil(
            RESEND_COOLDOWN_SECONDS - secondsPassed,
          );

        throw new BadRequestException(
          `Please wait ${remaining} seconds before requesting another OTP.`,
        );
      }
    }


    // ------------------------------------------
    // Invalidate old OTPs
    // ------------------------------------------

    await this.otpRepository.update(
      {
        phone,
        used: false,
      },
      {
        used: true,
      },
    );


    // ------------------------------------------
    // Generate OTP
    // ------------------------------------------

    const otp = this.generateOtp();


    // ------------------------------------------
    // Hash OTP
    // ------------------------------------------

    const hashedOtp =
      await bcrypt.hash(otp, 12);


    // ------------------------------------------
    // Expiration
    // ------------------------------------------

    const expiresAt = new Date();

    expiresAt.setMinutes(
      expiresAt.getMinutes() + OTP_TTL_MINUTES,
    );


    // ------------------------------------------
    // Save OTP
    // ------------------------------------------

    const otpCode =
      this.otpRepository.create({

        phone,

        code_hash: hashedOtp,

        attempts: 0,

        expires_at: expiresAt,

        used: false,

      });


    await this.otpRepository.save(
      otpCode,
    );


    // ------------------------------------------
    // DEVELOPMENT SMS
    // ------------------------------------------

    await this.smsService.sendOtp(
      phone,
      otp,
    );


    const response: { message: string; development_otp?: string } = {
      message: 'OTP sent successfully',
    };

    // Keep the test OTP easy to disable for production deployments.
    if (process.env.NODE_ENV !== 'production') {
      response.development_otp = otp;
    }

    return response;
  }


  // ==========================================
  // VERIFY OTP
  // ==========================================

  async verifyOtp(
    phone: string,
    otp: string,
  ) {

    phone = phone.trim();

    otp = otp.trim();


    // ------------------------------------------
    // Validate OTP format
    // ------------------------------------------

    if (!/^\d{6}$/.test(otp)) {

      throw new BadRequestException(
        'OTP must be a 6-digit number.',
      );

    }


    // ------------------------------------------
    // Find latest unused OTP
    // ------------------------------------------

    const otpRecord =
      await this.otpRepository.findOne({

        where: {
          phone,
          used: false,
        },

        order: {
          created_at: 'DESC',
        },

      });


    if (!otpRecord) {

      throw new BadRequestException(
        'OTP not found or already used.',
      );

    }


    // ------------------------------------------
    // Check expiration
    // ------------------------------------------

    if (
      new Date() >
      otpRecord.expires_at
    ) {

      otpRecord.used = true;

      await this.otpRepository.save(
        otpRecord,
      );

      throw new BadRequestException(
        'OTP has expired.',
      );

    }


    // ------------------------------------------
    // Check attempts
    // ------------------------------------------

    if (
      otpRecord.attempts >=
      MAX_OTP_ATTEMPTS
    ) {

      otpRecord.used = true;

      await this.otpRepository.save(
        otpRecord,
      );

      throw new BadRequestException(
        'Too many incorrect attempts. Please request a new OTP.',
      );

    }


    // ------------------------------------------
    // Compare OTP
    // ------------------------------------------

    const valid =
      await bcrypt.compare(
        otp,
        otpRecord.code_hash,
      );


    if (!valid) {

      otpRecord.attempts += 1;


      if (
        otpRecord.attempts >=
        MAX_OTP_ATTEMPTS
      ) {

        otpRecord.used = true;

      }


      await this.otpRepository.save(
        otpRecord,
      );


      throw new BadRequestException(
        'Invalid OTP.',
      );

    }


    // ------------------------------------------
    // OTP is correct
    // ------------------------------------------

    otpRecord.used = true;

    await this.otpRepository.save(
      otpRecord,
    );


    // ------------------------------------------
    // Find user
    // ------------------------------------------

    const user =
      await this.userRepository.findOne({
        where: { phone },
      });


    if (!user) {

      throw new BadRequestException(
        'User not found.',
      );

    }


    // ------------------------------------------
    // Generate JWT
    // ------------------------------------------

    const token =
      this.jwtService.sign({

        user_id: user.user_id,

        phone: user.phone,

        role: user.role,

      });


    // ------------------------------------------
    // Return login result
    // ------------------------------------------

    return {

      message:
        'OTP verified successfully',

      access_token:
        token,

      user,

    };

  }


  // ==========================================
  // GET PROFILE
  // ==========================================

  async getProfile(payload: any) {

    return await this.userRepository.findOne({
      where: {
        phone: payload.phone,
      },
    });

  }


  // ==========================================
  // GENERATE OTP
  // ==========================================

  private generateOtp(
    length: number = OTP_LENGTH,
  ): string {

    let otp = '';

    for (
      let i = 0;
      i < length;
      i++
    ) {

      otp += randomInt(0, 10).toString();

    }

    return otp;

  }

}