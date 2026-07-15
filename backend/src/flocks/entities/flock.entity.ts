import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  JoinColumn,
  CreateDateColumn,
} from 'typeorm';

import { User } from '../../users/entities/user.entity';

@Entity('flocks')
export class Flock {
  @PrimaryGeneratedColumn()
  flock_id!: number;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'farmer_id' })
  farmer!: User;

  @Column()
  batch_name!: string;

  @Column()
  bird_count!: number;

  @Column({
    nullable: true,
  })
  breed!: string;

  @Column({
    type: 'date',
  })
  date_acquired!: Date;

  @CreateDateColumn()
  created_at!: Date;
}