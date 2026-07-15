import { Body, Controller, Post } from '@nestjs/common';
import { AuthService } from './auth.service';

@Controller('auth')
export class AuthController {

  constructor(
    private readonly authService: AuthService,
  ) {}

  @Post('send-otp')
  sendOtp(
    @Body() body: { phone: string }
  ) {
    return this.authService.sendOtp(body.phone);
  }


  @Post('verify-otp')
  verifyOtp(
    @Body() body: {
      phone: string;
      otp: string;
    }
  ) {
    return this.authService.verifyOtp(
      body.phone,
      body.otp,
    );
  }
}