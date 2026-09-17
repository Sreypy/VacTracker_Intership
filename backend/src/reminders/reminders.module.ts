import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';

import { Reminder } from './entities/reminder.entity';
import { RemindersController } from './reminders.controller';
import { RemindersService } from './reminders.service';
import { Vaccination } from 'src/vaccinations/entities/vaccination.entity';
import { ReminderScheduler } from './reminder.scheduler';
import { NotificationsModule } from '../notifications/notifications.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      Reminder,
      Vaccination]),
    NotificationsModule,
  ],

  controllers: [RemindersController],
  providers: [
    RemindersService,
    ReminderScheduler
    ],
  exports: [RemindersService, TypeOrmModule],
})
export class RemindersModule {}