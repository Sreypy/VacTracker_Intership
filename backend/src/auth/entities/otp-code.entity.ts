import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
} from 'typeorm';

@Entity('otp_codes')
export class OtpCode {
  @PrimaryGeneratedColumn()
  otp_id!: number;

  @Column()
  phone!: string;

  @Column()
  code_hash!: string;

  @Column({
    default: 0,
  })
  attempts!: number;

  @Column()
  expires_at!: Date;

  @CreateDateColumn()
  created_at!: Date;
}