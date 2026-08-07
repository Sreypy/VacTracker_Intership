import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { VetDashboardController } from './vet-dashboard.controller';
import { VetDashboardService } from './vet-dashboard.service';
import { Vaccination } from '../vaccinations/entities/vaccination.entity';
import { Flock } from '../flocks/entities/flock.entity';
import { User } from '../users/entities/user.entity';
import { VetFarmerConnection } from '../users/entities/vet-farmer-connection.entity';

@Module({
  imports: [TypeOrmModule.forFeature([Vaccination, Flock, User, VetFarmerConnection])],
  controllers: [VetDashboardController],
  providers: [VetDashboardService],
  exports: [VetDashboardService],
})
export class VetModule {}