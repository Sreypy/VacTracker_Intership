import { Injectable, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import * as bcrypt from 'bcrypt';
import { JwtService } from '@nestjs/jwt';

import { OtpCode } from './entities/otp-code.entity';
import { User } from '../users/entities/user.entity';

@Injectable()
export class AuthService {
  constructor(
    @InjectRepository(OtpCode)
    private readonly otpRepository: Repository<OtpCode>,

    @InjectRepository(User)
    private readonly userRepository: Repository<User>,

    private readonly jwtService: JwtService,
  ) {}

  // Check whether the phone number is already registered
  async checkPhone(phone: string) {
    const user = await this.userRepository.findOne({
      where: { phone },
    });

    return {
      exists: !!user,
    };
  }

  // Send OTP only to registered users
  async sendOtp(phone: string) {
    const user = await this.userRepository.findOne({
      where: { phone },
    });

    if (!user) {
      throw new BadRequestException('Phone number is not registered.');
    }

    const otp = Math.floor(
      100000 + Math.random() * 900000,
    ).toString();

    const hashedOtp = await bcrypt.hash(otp, 10);

    const expiresAt = new Date();
    expiresAt.setMinutes(expiresAt.getMinutes() + 5);

    const otpCode = this.otpRepository.create({
      phone,
      code_hash: hashedOtp,
      attempts: 0,
      expires_at: expiresAt,
    });

    await this.otpRepository.save(otpCode);

    return {
      message: 'OTP sent successfully',

      // Development only
      otp,
    };
  }

  async verifyOtp(phone: string, otp: string) {
    const otpRecord = await this.otpRepository.findOne({
      where: { phone },
      order: {
        created_at: 'DESC',
      },
    });

    if (!otpRecord) {
      throw new BadRequestException('OTP not found.');
    }

    const valid = await bcrypt.compare(
      otp,
      otpRecord.code_hash,
    );

    if (!valid) {
      throw new BadRequestException('Invalid OTP.');
    }

    const user = await this.userRepository.findOne({
      where: { phone },
    });

    if (!user) {
      throw new BadRequestException('User not found.');
    }

    const token = this.jwtService.sign({
      user_id: user.user_id,
      phone: user.phone,
    });

    return {
      message: 'OTP verified successfully',
      access_token: token,
      user,
    };
  }

  async getProfile(payload: any) {
    return await this.userRepository.findOne({
      where: {
        phone: payload.phone,
      },
    });
  }
}