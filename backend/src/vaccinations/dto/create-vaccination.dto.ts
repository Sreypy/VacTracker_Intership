import {
  IsBoolean,
  IsDateString,
  IsInt,
  IsOptional,
  IsString,
} from 'class-validator';
import { Transform, Type } from 'class-transformer';

export class CreateVaccinationDto {
  @Type(() => Number)
  @IsInt()
  flock_id!: number;

  @Type(() => Number)
  @IsOptional()
  @IsInt()
  vaccination_id?: number;

  @Type(() => Number)
  @IsInt()
  vaccine_id!: number;

  @IsDateString()
  date_given!: string;

  @Type(() => Number)
  @IsOptional()
  @IsInt()
  next_vaccine_id?: number;

  @IsOptional()
  @IsDateString()
  next_due_date?: string;

  @IsOptional()
  @IsBoolean()
  @Transform(({ value }) => value === true || value === 'true')
  create_reminder?: boolean;

  @IsOptional()
  @IsString()
  photo_url?: string;
}