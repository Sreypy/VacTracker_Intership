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
}

@Entity('notifications')
export class Notification {
  @PrimaryGeneratedColumn()
  notification_id!: number;

  @Column({ name: 'farmer_id' })
  farmerId!: number;

  @ManyToOne(() => User, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'farmer_id' })
  farmer!: User;

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