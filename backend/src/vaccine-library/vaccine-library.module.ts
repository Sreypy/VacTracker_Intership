import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';

import { VaccineLibraryController } from './vaccine-library.controller';
import { VaccineLibraryService } from './vaccine-library.service';
import { VaccineLibrarySeeder } from './vaccine-library.seeder';
import { VaccineLibrary } from './entities/vaccine-library.entity';
import { Vaccine } from '../vaccines/entities/vaccine.entity';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      VaccineLibrary,
      Vaccine,
    ]),
  ],
  controllers: [
    VaccineLibraryController,
  ],
  providers: [
    VaccineLibraryService,
    VaccineLibrarySeeder,
  ],
})
export class VaccineLibraryModule {}
