import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { VetDashboardController } from './vet-dashboard.controller';
import { VetDashboardService } from './vet-dashboard.service';
import { FarmerDetailController } from './farmer-detail.controller';
import { FarmerDetailService } from './farmer-detail.service';
import { VetConnectionsController } from './vet-connections.controller';
import { VetConnectionsService } from './vet-connections.service';
import { Vaccination } from '../vaccinations/entities/vaccination.entity';
import { Flock } from '../flocks/entities/flock.entity';
import { User } from '../users/entities/user.entity';
import { VetFarmerConnection } from '../users/entities/vet-farmer-connection.entity';
import { SickReport } from '../sick-reports/entities/sick-report.entity';
import { NotificationsModule } from '../notifications/notifications.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([Vaccination, Flock, User, VetFarmerConnection, SickReport]),
    NotificationsModule,
  ],
  controllers: [VetDashboardController, FarmerDetailController, VetConnectionsController],
  providers: [VetDashboardService, FarmerDetailService, VetConnectionsService],
  exports: [VetDashboardService, FarmerDetailService],
})
export class VetModule {}
