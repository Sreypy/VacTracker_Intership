import { IsOptional, IsString, IsNumber } from 'class-validator';
import { Type } from 'class-transformer';

export class DisconnectVetDto {
  /**
   * Optional: disconnect from a specific veterinarian only. When omitted,
   * the farmer is disconnected from all active connections.
   */
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  vet_id?: number;
}

export class ConnectVetDto {
  /**
   * Short user-facing veterinarian code, e.g. "SOKHA-4827".
   * This is what the Flutter app sends (snake_case matches the
   * user-facing API contract and the User entity column).
   */
  @IsOptional()
  @IsString()
  vet_code?: string;

  /**
   * Alias of `vet_code` in camelCase (accepted for convenience).
   */
  @IsOptional()
  @IsString()
  vetCode?: string;

  /**
   * Legacy long UUID share code. Kept so that existing clients / already
   * shared codes keep working (backward compatibility).
   */
  @IsOptional()
  @IsString()
  vetShareCode?: string;
}
