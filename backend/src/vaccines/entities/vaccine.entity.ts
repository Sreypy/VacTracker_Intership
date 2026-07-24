import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
} from 'typeorm';

@Entity('vaccines')
export class Vaccine {
  @PrimaryGeneratedColumn()
  vaccine_id!: number;

  @Column()
  name!: string;

  @Column()
  disease_target!: string;

  @Column()
  interval_days!: number;

  @Column({
    nullable: true,
  })
  notes!: string;
}