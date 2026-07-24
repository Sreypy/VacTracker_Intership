import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';

import { Reminder } from './entities/reminder.entity';
import { RemindersController } from './reminders.controller';
import { RemindersService } from './reminders.service';
import { Vaccination } from 'src/vaccinations/entities/vaccination.entity';
import { ReminderScheduler } from './reminder.scheduler';

@Module({
  imports: [TypeOrmModule.forFeature([
    Reminder,
    Vaccination])],

  controllers: [RemindersController],
  providers: [
    RemindersService,
    ReminderScheduler
    ],
  exports: [RemindersService],
})
export class RemindersModule {}