import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';

import { User } from './entities/user.entity';
import { UsersController } from './users.controller';
import { UsersService } from './users.service';
import { VetFarmerConnection } from './entities/vet-farmer-connection.entity';

@Module({
  imports: [TypeOrmModule.forFeature([
              User,
              VetFarmerConnection,
            ])],
  controllers: [UsersController],
  providers: [UsersService],
  exports: [UsersService],
})
export class UsersModule {}