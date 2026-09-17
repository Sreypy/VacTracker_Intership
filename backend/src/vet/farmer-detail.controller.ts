import { Controller, Get, Param, UseGuards, Request } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { FarmerDetailService } from './farmer-detail.service';

@Controller('vet')
@UseGuards(JwtAuthGuard)
export class FarmerDetailController {
  constructor(private readonly farmerDetailService: FarmerDetailService) {}

  @Get('farmer/:farmerId')
  async getFarmerDetail(@Request() req: any, @Param('farmerId') farmerId: string) {
    const vetPhone = req.user.phone;
    const farmerIdNum = parseInt(farmerId, 10);
    return this.farmerDetailService.getFarmerDetail(vetPhone, farmerIdNum);
  }
}