import { Module } from '@nestjs/common';
import { FlocksController } from './flocks.controller';
import { FlocksService } from './flocks.service';
import { User } from 'src/users/entities/user.entity';
import { Flock } from './entities/flock.entity';
import { TypeOrmModule } from '@nestjs/typeorm';


@Module({

  imports: [
  TypeOrmModule.forFeature([
    Flock,
    User,
  ]),
],
  
  controllers: [FlocksController],
  providers: [FlocksService]
})
export class FlocksModule {}
