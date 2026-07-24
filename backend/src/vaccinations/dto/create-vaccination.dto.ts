import {
  IsDateString,
  IsInt,
  IsOptional,
  IsString,
} from 'class-validator';

export class CreateVaccinationDto {
  @IsInt()
    flock_id!: number;

  @IsInt()
    vaccine_id!: number;

  @IsDateString()
    date_given!: string;

  @IsOptional()
  @IsString()
  photo_url?: string;
}