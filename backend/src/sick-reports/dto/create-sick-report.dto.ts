import { IsEnum, IsInt, IsString, IsOptional, IsDate } from 'class-validator';
import { ReportType } from '../entities/sick-report.entity';

export class CreateSickReportDto {
  @IsInt()
  flockId!: number;

  @IsEnum(ReportType)
  reportType!: ReportType;

  @IsInt()
  affectedCount!: number;

  @IsString()
  symptoms!: string;

  @IsOptional()
  @IsString()
  photoUrl?: string;

  @IsDate()
  reportDate!: Date;
}
