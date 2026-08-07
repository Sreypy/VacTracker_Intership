import { IsString, IsNotEmpty } from 'class-validator';

export class ConnectVetDto {
  @IsString()
  @IsNotEmpty()
  vetShareCode!: string;
}
