import { IsEnum, IsInt, IsString, IsOptional } from 'class-validator';
import { ReportStatus, ReportType } from '../entities/sick-report.entity';

export class UpdateSickReportDto {
  @IsOptional()
  @IsEnum(ReportType)
  reportType?: ReportType;

  @IsOptional()
  @IsInt()
  affectedCount?: number;

  @IsOptional()
  @IsString()
  symptoms?: string;

  @IsOptional()
  @IsString()
  photoUrl?: string;

  @IsOptional()
  @IsEnum(ReportStatus)
  status?: ReportStatus;

  @IsOptional()
  @IsString()
  vetNotes?: string;
}

