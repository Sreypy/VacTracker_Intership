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

  @IsDateString()
  date_acquired!: string;
}