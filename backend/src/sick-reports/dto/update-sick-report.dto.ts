import { IsEnum, IsInt, IsString, IsOptional, IsDateString } from 'class-validator';
import { ReportStatus, ReportType, RecommendedAction } from '../entities/sick-report.entity';

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

  // Vet response fields
  @IsOptional()
  @IsString()
  vetDiagnosis?: string;

  @IsOptional()
  @IsString()
  vetAdvice?: string;

  @IsOptional()
  @IsEnum(RecommendedAction)
  recommendedAction?: RecommendedAction;

  @IsOptional()
  @IsDateString()
  followUpDate?: string;
}
