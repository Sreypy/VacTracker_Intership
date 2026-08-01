import {
  IsInt,
  IsOptional,
  IsString,
} from 'class-validator';

export class CreateVaccineDto {

  @IsString()
  name_en!: string;

  @IsString()
  name_km!: string;

  @IsString()
  disease_en!: string;

  @IsString()
  disease_km!: string;

  @IsInt()
  interval_days!: number;

  @IsOptional()
  @IsString()
  notes_en?: string;

  @IsOptional()
  @IsString()
  notes_km?: string;
}