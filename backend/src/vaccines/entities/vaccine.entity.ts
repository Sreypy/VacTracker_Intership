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
  name_en!: string;


  @Column()
  name_km!: string;


  @Column()
  disease_en!: string;


  @Column()
  disease_km!: string;


  @Column({
    type: 'integer',
    nullable: true,
  })
  interval_days!: number | null;


  @Column({
    nullable:true,
  })
  notes_en?: string;


  @Column({
    nullable:true,
  })
  notes_km?: string;

}