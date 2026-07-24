import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';

import { Reminder, ReminderSender, ReminderStatus } from './entities/reminder.entity';
import { Vaccination } from 'src/vaccinations/entities/vaccination.entity';

@Injectable()
export class RemindersService {
  constructor(
    @InjectRepository(Reminder)
    private readonly reminderRepository: Repository<Reminder>,

    @InjectRepository(Vaccination)
    private readonly vaccinationRepository: Repository<Vaccination>,
  ) {}

  async findByFarmer(farmerId: number): Promise<Reminder[]> {
    return this.reminderRepository.find({
      where: {
        farmer_id: farmerId,
      },
      relations: {
        vaccination: true,
      },
      order: {
        scheduled_date: 'ASC',
      },
    });
  }

  async createReminder(
  vaccination: Vaccination,
): Promise<Reminder> {

  const exists = await this.reminderRepository.findOne({
    where: {
    vaccination_id: vaccination.vaccination_id,
    scheduled_date: vaccination.next_due_date!,
    },
  });

  if (exists) {
    return exists;
  }

  return this.reminderRepository.save({
    vaccination_id: vaccination.vaccination_id,
    farmer_id: vaccination.flock.farmer.user_id,

    title: 'Vaccination Reminder',

    message: `${vaccination.flock.batch_name} is due for ${vaccination.vaccine.name} vaccination tomorrow.`,

    scheduled_date: vaccination.next_due_date!,

    status: ReminderStatus.PENDING,

    sent_by: ReminderSender.SYSTEM,
  });
}
}