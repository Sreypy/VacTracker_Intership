import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';

import { VaccinesController } from './vaccines.controller';
import { VaccinesService } from './vaccines.service';
import { Vaccine } from './entities/vaccine.entity';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      Vaccine,
    ]),
  ],
  controllers: [
    VaccinesController,
  ],
  providers: [
    VaccinesService,
  ],
})
export class VaccinesModule {}