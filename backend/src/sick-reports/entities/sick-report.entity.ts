import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  JoinColumn,
  CreateDateColumn,
} from 'typeorm';
import { Flock } from '../../flocks/entities/flock.entity';
import { User } from '../../users/entities/user.entity';

export enum ReportStatus {
  PENDING = 'pending',
  REVIEWED = 'reviewed',
  RESOLVED = 'resolved',
}

export enum ReportType {
  DISEASE = 'disease',
  INJURY = 'injury',
  DEATH = 'death',
  OTHER = 'other',
}

@Entity('sick_reports')
export class SickReport {
  @PrimaryGeneratedColumn()
  report_id!: number;

  @Column({ name: 'flock_id' })
  flockId!: number;

  @ManyToOne(() => Flock, (flock) => flock.sickReports)
  @JoinColumn({ name: 'flock_id' })
  flock?: Flock;

  @Column({ name: 'reported_by' })
  reportedBy!: number;

  @ManyToOne(() => User, (user) => user.sickReports)
  @JoinColumn({ name: 'reported_by' })
  reporter?: User;

  @Column({ type: 'enum', enum: ReportType })
  reportType!: ReportType;

  @Column()
  affectedCount!: number;

  @Column('text')
  symptoms!: string;

  @Column({ nullable: true })
  photoUrl!: string;

  @Column({ name: 'report_date', type: 'date' })
  reportDate!: string;

  @Column({ type: 'enum', enum: ReportStatus, default: ReportStatus.PENDING })
  status!: ReportStatus;

  @Column({ name: 'vet_notes', nullable: true })
  vetNotes!: string;

  @CreateDateColumn()
  created_at!: Date;
}
