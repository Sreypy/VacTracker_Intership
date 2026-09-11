import { Injectable, Logger } from '@nestjs/common';

@Injectable()
export class SmsService {
  private readonly logger = new Logger(SmsService.name);

  async sendOtp(phone: string, otp: string): Promise<void> {
    this.logger.log('====================================');
    this.logger.log('     VAC TRACKER DEVELOPMENT SMS');
    this.logger.log('====================================');
    this.logger.log(`Phone: ${phone}`);
    this.logger.log(`OTP: ${otp}`);
    this.logger.log('Expires in: 5 minutes');
    this.logger.log('====================================');
  }
}