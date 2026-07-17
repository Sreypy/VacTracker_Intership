import { IsEnum, IsOptional, IsString } from 'class-validator';
import { Language, UserRole } from '../entities/user.entity';

export class CreateUserDto {
  @IsString()
  name!: string;

  @IsString()
  phone!: string;

  @IsString()
  password!: string;

  @IsEnum(UserRole)
  role!: UserRole;

  @IsOptional()
  @IsString()
  village?: string;

  @IsOptional()
  @IsString()
  province?: string;

  @IsOptional()
  @IsEnum(Language)
  language_pref?: Language;
}