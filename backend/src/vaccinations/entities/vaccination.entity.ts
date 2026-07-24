import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  ManyToOne,
  JoinColumn,
} from 'typeorm';

import { Flock } from '../../flocks/entities/flock.entity';
import { Vaccine } from '../../vaccines/entities/vaccine.entity';
import { User } from '../../users/entities/user.entity';

export enum VaccinationStatus {
  ON_TIME = 'on_time',
  DUE_SOON = 'due_soon',
  OVERDUE = 'overdue',
}

@Entity('vaccinations')
export class Vaccination {
  @PrimaryGeneratedColumn()
  vaccination_id!: number;

  @ManyToOne(() => Flock)
  @JoinColumn({ name: 'flock_id' })
  flock!: Flock;

  @ManyToOne(() => Vaccine)
  @JoinColumn({ name: 'vaccine_id' })
  vaccine!: Vaccine;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'administered_by' })
  administered_by!: User;

  @Column({ type: 'date' })
  date_given!: Date;

  @Column({
    type: 'date',
    nullable: true,
  })
  next_due_date!: Date | null;

  @Column({
    type: 'enum',
    enum: VaccinationStatus,
    default: VaccinationStatus.ON_TIME,
  })
  status!: VaccinationStatus;

  @Column({
    nullable: true,
  })
  photo_url!: string;

  @CreateDateColumn()
  created_at!: Date;
}