import { Injectable, Logger } from '@nestjs/common';
import { Cron } from '@nestjs/schedule';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';

import { Reminder } from './entities/reminder.entity';
import { Vaccination } from '../vaccinations/entities/vaccination.entity';

@Injectable()
export class ReminderScheduler {
  private readonly logger = new Logger(ReminderScheduler.name);

  constructor(
    @InjectRepository(Reminder)
    private readonly reminderRepository: Repository<Reminder>,

    @InjectRepository(Vaccination)
    private readonly vaccinationRepository: Repository<Vaccination>,
  ) {}

  @Cron('* * * * *')
    async generateReminders() {
    const tomorrow = new Date();
    tomorrow.setDate(tomorrow.getDate() + 1);

    const date = tomorrow.toISOString().split('T')[0];

    const vaccinations = await this.vaccinationRepository
        .createQueryBuilder('vaccination')
        .leftJoinAndSelect('vaccination.flock', 'flock')
        .leftJoinAndSelect('flock.farmer', 'farmer')
        .leftJoinAndSelect('vaccination.vaccine', 'vaccine')
        .where('vaccination.next_due_date = :date', { date })
        .getMany();

    this.logger.log(`Found ${vaccinations.length} vaccinations due.`);
}
}