import {
  IsDateString,
  IsInt,
  IsOptional,
  IsString,
} from 'class-validator';
import { Type } from 'class-transformer';

export class CreateVaccinationDto {
  @Type(() => Number)
  @IsInt()
  flock_id!: number;

  @Type(() => Number)
  @IsInt()
  vaccine_id!: number;

  @IsDateString()
  date_given!: string;

  @IsOptional()
  @IsDateString()
  next_due_date?: string;

  @IsOptional()
  @IsString()
  photo_url?: string;
}