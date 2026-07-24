import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  ManyToOne,
  JoinColumn,
} from 'typeorm';

import { Vaccination } from '../../vaccinations/entities/vaccination.entity';
import { User } from '../../users/entities/user.entity';

export enum ReminderStatus {
  PENDING = 'pending',
  SENT = 'sent',
  FAILED = 'failed',
}

export enum ReminderSender {
  SYSTEM = 'system',
  VET = 'vet',
}

@Entity('reminders')
export class Reminder {
  @PrimaryGeneratedColumn()
  reminder_id!: number;

  @ManyToOne(() => Vaccination, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'vaccination_id' })
  vaccination!: Vaccination;

  @Column()
  vaccination_id!: number;

  @ManyToOne(() => User, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'farmer_id' })
  farmer!: User;

  @Column()
  farmer_id!: number;

  @Column()
  title!: string;

  @Column('text')
  message!: string;

  @Column({ type: 'date' })
  scheduled_date!: Date;

  @Column({
    type: 'timestamp',
    nullable: true,
  })
  sent_at?: Date;

  @Column({
    type: 'enum',
    enum: ReminderStatus,
    default: ReminderStatus.PENDING,
  })
  status!: ReminderStatus;

  @Column({
    type: 'enum',
    enum: ReminderSender,
    default: ReminderSender.SYSTEM,
  })
  sent_by!: ReminderSender;

  @CreateDateColumn()
  created_at!: Date;
}