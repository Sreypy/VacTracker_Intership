import {
  Controller,
  Get,
  Request,
  UseGuards,
} from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { VetDashboardService } from './vet-dashboard.service';

@Controller('vet/dashboard')
@UseGuards(JwtAuthGuard)
export class VetDashboardController {
  constructor(private readonly vetDashboardService: VetDashboardService) {}

  @Get('stats')
  async getDashboardStats(@Request() req) {
    return this.vetDashboardService.getDashboardStats(req.user.phone);
  }
}