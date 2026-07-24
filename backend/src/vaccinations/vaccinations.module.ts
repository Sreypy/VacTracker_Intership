import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';

import { VaccinationsController } from './vaccinations.controller';
import { VaccinationsService } from './vaccinations.service';

import { Vaccination } from './entities/vaccination.entity';
import { Flock } from '../flocks/entities/flock.entity';
import { Vaccine } from '../vaccines/entities/vaccine.entity';
import { User } from '../users/entities/user.entity';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      Vaccination,
      Flock,
      Vaccine,
      User,
    ]),
  ],
  controllers: [VaccinationsController],
  providers: [VaccinationsService],
})
export class VaccinationsModule {}