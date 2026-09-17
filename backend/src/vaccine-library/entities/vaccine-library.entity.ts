import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
  JoinColumn,
} from 'typeorm';

import { Vaccine } from '../../vaccines/entities/vaccine.entity';

@Entity('vaccine_library')
export class VaccineLibrary {

  @PrimaryGeneratedColumn()
  library_id!: number;

  // Optional relation to the vaccines table (used by vaccination recording).
  // The library item can exist without a matching vaccines row.
  @ManyToOne(() => Vaccine, { nullable: true, onDelete: 'SET NULL' })
  @JoinColumn({ name: 'vaccine_id' })
  vaccine?: Vaccine | null;

  @Column({ nullable: true })
  vaccine_id!: number | null;

  @Column()
  name_en!: string;

  @Column()
  name_km!: string;

  @Column()
  disease_en!: string;

  @Column()
  disease_km!: string;

  // Short explanation / summary shown on the library card
  @Column('text')
  description_en!: string;

  @Column('text')
  description_km!: string;

  // What is this disease?
  @Column('text')
  disease_description_en!: string;

  @Column('text')
  disease_description_km!: string;

  // Why is this vaccine important?
  @Column('text')
  why_important_en!: string;

  @Column('text')
  why_important_km!: string;

  // How is it generally used?
  @Column('text')
  usage_en!: string;

  @Column('text')
  usage_km!: string;

  // Important precautions
  @Column('text')
  precautions_en!: string;

  @Column('text')
  precautions_km!: string;

  // Other useful information for farmers
  @Column('text', { nullable: true })
  other_info_en?: string;

  @Column('text', { nullable: true })
  other_info_km?: string;

  // Category: core, broiler, layer, emergency, etc.
  @Column({ default: 'general' })
  category!: string;

  @CreateDateColumn()
  created_at!: Date;

  @UpdateDateColumn()
  updated_at!: Date;
}