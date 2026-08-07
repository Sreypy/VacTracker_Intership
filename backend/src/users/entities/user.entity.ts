import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  OneToMany,
} from 'typeorm';
import { Flock } from '../../flocks/entities/flock.entity';
import { SickReport } from '../../sick-reports/entities/sick-report.entity';
import { VetFarmerConnection } from './vet-farmer-connection.entity';

export enum UserRole {
  FARMER = 'farmer',
  VETERINARIAN = 'veterinarian',
}

export enum Language {
  KM = 'km',
  EN = 'en',
}

@Entity('users')
export class User {
  @PrimaryGeneratedColumn()
  user_id!: number;

  @Column()
  name!: string;

  @Column({
    unique: true,
  })
  phone!: string;

  @Column({
  nullable: true,
  })
  password_hash!: string;

  @Column({
    type: 'enum',
    enum: UserRole,
  })
  role!: UserRole;

  @Column({
    nullable: true,
  })
  village!: string;

  @Column({
    nullable: true,
  })
  province!: string;

  @Column({
    type: 'enum',
    enum: Language,
    default: Language.KM,
  })
  language_pref!: Language;

  @Column({
    nullable: true,
  })
  profile_image_url!: string;

  @Column({
    nullable: true,
    unique: true,
  })
  share_code!: string;

  @CreateDateColumn()
  created_at!: Date;

  @UpdateDateColumn()
  updated_at!: Date;

  @OneToMany(() => Flock, (flock) => flock.farmer)
  flocks!: Flock[];

  @OneToMany(() => SickReport, (sickReport) => sickReport.reporter)
  sickReports!: SickReport[];

  @OneToMany(() => VetFarmerConnection, (connection) => connection.vet)
  vetConnections!: VetFarmerConnection[];

  @OneToMany(() => VetFarmerConnection, (connection) => connection.farmer)
  farmerConnections!: VetFarmerConnection[];
}
