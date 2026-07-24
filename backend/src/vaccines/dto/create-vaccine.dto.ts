import { IsInt, IsOptional, IsString } from 'class-validator';

export class CreateVaccineDto {
  @IsString()
  name?: string;

  @IsString()
  disease_target?: string;

  @IsInt()
  interval_days?: number;

  @IsOptional()
  @IsString()
  notes?: string;
}