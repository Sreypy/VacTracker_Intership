import { Injectable, Logger } from '@nestjs/common';
import { Cron } from '@nestjs/schedule';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';

import { Reminder, ReminderSender, ReminderStatus } from './entities/reminder.entity';
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

    this.logger.log(`Found ${vaccinations.length} vaccinations due tomorrow.`);

    // Create reminders for each vaccination
    for (const vaccination of vaccinations) {
      await this.createReminderIfNotExists(vaccination);
    }
  }

  private async createReminderIfNotExists(vaccination: Vaccination): Promise<void> {
    if (!vaccination.next_due_date || !vaccination.flock?.farmer?.user_id) {
      return;
    }

    // Check if reminder already exists
    const existingReminder = await this.reminderRepository.findOne({
      where: {
        vaccination_id: vaccination.vaccination_id,
        farmer_id: vaccination.flock.farmer.user_id,
        scheduled_date: vaccination.next_due_date,
      },
    });

    if (existingReminder) {
      this.logger.log(
        `Reminder already exists for vaccination ${vaccination.vaccination_id}`,
      );
      return;
    }

    // Create new reminder
    const reminder = this.reminderRepository.create({
      vaccination_id: vaccination.vaccination_id,
      farmer_id: vaccination.flock.farmer.user_id,
      title: 'Vaccination Reminder',
      message: `${vaccination.vaccine.name_en} is due tomorrow for ${vaccination.flock.batch_name}.`,
      scheduled_date: vaccination.next_due_date,
      status: ReminderStatus.PENDING,
      sent_by: ReminderSender.SYSTEM,
    });

    await this.reminderRepository.save(reminder);
    this.logger.log(
      `Created reminder for vaccination ${vaccination.vaccination_id}`,
    );
  }
}