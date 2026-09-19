import {
  IsOptional,
  IsString,
} from 'class-validator';

export class CreateVaccineDto {

  @IsString()
  name_en!: string;

  @IsString()
  name_km!: string;

  @IsOptional()
  @IsString()
  disease_en!: string;

  @IsString()
  disease_km!: string;

}