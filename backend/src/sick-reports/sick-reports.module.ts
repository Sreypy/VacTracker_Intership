import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { SickReport } from './entities/sick-report.entity';
import { SickReportsController } from './sick-reports.controller';
import { SickReportsService } from './sick-reports.service';


@Module({
  imports: [TypeOrmModule.forFeature([SickReport])],
  controllers: [SickReportsController],
  providers: [SickReportsService],
  exports: [SickReportsService],
})
export class SickReportsModule {}
