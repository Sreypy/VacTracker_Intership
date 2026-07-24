import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  JoinColumn,
  CreateDateColumn,
  UpdateDateColumn,
} from 'typeorm';

import { User } from '../../users/entities/user.entity';


@Entity('flocks')
export class Flock {

  @PrimaryGeneratedColumn()
  flock_id!: number;


  @ManyToOne(() => User, (farmer) => farmer.flocks)
  @JoinColumn({
    name: 'farmer_id',
  })
  farmer!: User;


  // Farmer's name for this batch
  @Column()
  batch_name!: string;


  // Total chickens
  @Column()
  bird_count!: number;


  // Broiler, Layer, Local chicken
  @Column({
    nullable: true,
  })
  breed!: string;

  // Chicken age when registered
  @Column({ default: 0 })
  age!: number;


  // days, weeks, months
  @Column({
    default: 'days',
  })
  age_unit!: string;


  // Date farmer received/bought chickens
  @Column({
    type:'date',
  })
  date_acquired!: Date;


  // Healthy, sick, recovered
  @Column({
    default:'healthy',
  })
  health_status!: string;


  @CreateDateColumn()
  created_at!: Date;


  @UpdateDateColumn()
  updated_at!: Date;
}