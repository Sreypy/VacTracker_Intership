import { Controller, Get, Req, UseGuards } from '@nestjs/common';

import { RemindersService } from './reminders.service';
import { JwtAuthGuard } from 'src/auth/jwt-auth.guard';


@Controller('reminders')
@UseGuards(JwtAuthGuard)
export class RemindersController {
  constructor(
    private readonly remindersService: RemindersService,
  ) {}

  @Get('me')
  async getMyReminders(@Req() req) {
    return this.remindersService.findByFarmer(req.user.user_id);
  }
}