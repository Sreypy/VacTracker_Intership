import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { SickReport } from './entities/sick-report.entity';
import { SickReportsController } from './sick-reports.controller';
import { SickReportsService } from './sick-reports.service';
import { NotificationsModule } from '../notifications/notifications.module';
import { User } from '../users/entities/user.entity';
import { VetFarmerConnection } from '../users/entities/vet-farmer-connection.entity';
import { CloudinaryModule } from 'src/cloudinary/cloudinary.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([SickReport, User, VetFarmerConnection]),
    NotificationsModule,
    CloudinaryModule,
  ],
  controllers: [SickReportsController],
  providers: [SickReportsService],
  exports: [SickReportsService],
})
export class SickReportsModule {}
