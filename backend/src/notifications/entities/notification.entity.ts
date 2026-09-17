import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { User } from '../../users/entities/user.entity';

export enum NotificationType {
  VET_RESPONSE = 'vet_response',
  SYSTEM = 'system',
  VACCINATION_OVERDUE = 'vaccination_overdue',
  VACCINE_DUE_TODAY = 'vaccine_due_today',
  /** The vaccination's reminder was completed. Keeps the same notification row. */
  VACCINATION_COMPLETED = 'vaccination_completed',
  /** A connected farmer submitted a new sick report (recipient: vet). */
  SICK_REPORT = 'sick_report',
  /** A farmer requested a connection using the vet code (recipient: vet). */
  FARMER_CONNECTION_REQUEST = 'farmer_connection_request',
  /** The farmer disconnected from the vet (recipient: vet). */
  FARMER_DISCONNECTED = 'farmer_disconnected',
}

@Entity('notifications')
export class Notification {
  @PrimaryGeneratedColumn()
  notification_id!: number;

  /**
   * Recipient for farmer-facing notifications (vaccination reminders,
   * vet responses). Nullable so vet-facing notifications can use `vetId`.
   */
  @Column({ name: 'farmer_id', nullable: true })
  farmerId!: number;

  @ManyToOne(() => User, { nullable: true, onDelete: 'CASCADE' })
  @JoinColumn({ name: 'farmer_id' })
  farmer!: User;

  /**
   * Recipient for veterinarian-facing notifications (sick reports,
   * farmer connection requests).
   */
  @Column({ name: 'vet_id', nullable: true })
  vetId!: number;

  @ManyToOne(() => User, { nullable: true, onDelete: 'CASCADE' })
  @JoinColumn({ name: 'vet_id' })
  vet!: User;

  @Column()
  title!: string;

  @Column('text')
  message!: string;

  @Column({
    type: 'enum',
    enum: NotificationType,
    default: NotificationType.SYSTEM,
  })
  type!: NotificationType;

  @Column({ name: 'reference_id', nullable: true })
  referenceId!: number;

  @Column({ name: 'is_read', default: false })
  isRead!: boolean;

  @Column({ type: 'json', nullable: true })
  data!: Record<string, any> | null;

  @CreateDateColumn()
  created_at!: Date;
}