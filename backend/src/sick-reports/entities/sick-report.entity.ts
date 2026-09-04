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

export enum RecommendedAction {
  MONITOR = 'monitor',
  SEPARATE = 'separate',
  TREATMENT = 'treatment',
  VACCINATION = 'vaccination',
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

  @Column({ name: 'vet_id', nullable: true })
  vetId!: number;

  @ManyToOne(() => User, { nullable: true })
  @JoinColumn({ name: 'vet_id' })
  veterinarian?: User;

  // Vet response fields
  @Column({ name: 'vet_diagnosis', nullable: true })
  vetDiagnosis!: string;

  @Column({ name: 'vet_advice', nullable: true })
  vetAdvice!: string;

  @Column({
    name: 'recommended_action',
    type: 'enum',
    enum: RecommendedAction,
    nullable: true,
  })
  recommendedAction!: RecommendedAction;

  @Column({ name: 'follow_up_date', type: 'date', nullable: true })
  followUpDate!: string;

  @Column({ name: 'responded_at', type: 'timestamp', nullable: true })
  respondedAt!: Date;

  @Column({ name: 'farmer_follow_up_message', type: 'text', nullable: true })
  farmerFollowUpMessage!: string | null;

  @Column({ name: 'farmer_follow_up_at', type: 'timestamp', nullable: true })
  farmerFollowUpAt!: Date | null;

  @CreateDateColumn()
  created_at!: Date;
}
