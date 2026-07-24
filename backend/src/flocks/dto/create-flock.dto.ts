import {
  IsString,
  IsInt,
  IsOptional,
  IsDateString,
} from 'class-validator';


export class CreateFlockDto {

  @IsString()
  batch_name!: string;


  @IsInt()
  bird_count!: number;


  @IsOptional()
  @IsString()
  breed?: string;


  // Chicken age
  @IsInt()
  age!: number;


  // days / weeks / months
  @IsOptional()
  @IsString()
  age_unit?: string;


  @IsDateString()
  date_acquired!: string;


  @IsOptional()
  @IsString()
  health_status?: string;
}