import { IsEnum, IsInt, IsString, IsOptional, IsDateString } from 'class-validator';
import { Type } from 'class-transformer';
import { ReportType } from '../entities/sick-report.entity';

export class CreateSickReportDto {
  @Type(() => Number)
  @IsInt()
  flockId!: number;

  @IsEnum(ReportType)
  reportType!: ReportType;

  @Type(() => Number)
  @IsInt()
  affectedCount!: number;

  @IsString()
  symptoms!: string;

  @IsOptional()
  @IsString()
  photoUrl?: string;

  @IsDateString()
  reportDate!: Date;
}
