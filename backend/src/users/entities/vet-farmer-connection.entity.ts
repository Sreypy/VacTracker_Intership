import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { User } from './user.entity';

export enum ConnectionStatus {
  PENDING = 'pending',
  ACCEPTED = 'accepted',
  REJECTED = 'rejected',
}

@Entity('vet_farmer_connections')
export class VetFarmerConnection {
  @PrimaryGeneratedColumn()
  connection_id!: number;

  @Column({ name: 'vet_id' })
  vetId!: number;

  @Column({ name: 'farmer_id' })
  farmerId!: number;

  @Column({
    type: 'enum',
    enum: ConnectionStatus,
    default: ConnectionStatus.PENDING,
  })
  status!: ConnectionStatus;

  @CreateDateColumn()
  created_at!: Date;

  // Relationships
  @ManyToOne(() => User, (user) => user.vetConnections)
  @JoinColumn({ name: 'vet_id' })
  vet!: User;

  @ManyToOne(() => User, (user) => user.farmerConnections)
  @JoinColumn({ name: 'farmer_id' })
  farmer!: User;
}
