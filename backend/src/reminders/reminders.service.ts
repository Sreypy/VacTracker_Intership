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
    await this.syncRemindersForFarmer(farmerId);

    return this.reminderRepository.find({
      where: {
        farmer_id: farmerId,
      },
      relations: {
        vaccination: {
          flock: true,
          vaccine: true,
        },
      },
      order: {
        scheduled_date: 'ASC',
      },
    });
  }

  async syncRemindersForFarmer(farmerId: number): Promise<void> {
    const vaccinations = await this.vaccinationRepository.find({
      where: {
        flock: {
          farmer: {
            user_id: farmerId,
          },
        },
      },
      relations: {
        flock: {
          farmer: true,
        },
        vaccine: true,
      },
    });

    for (const vaccination of vaccinations) {
      if (vaccination.next_due_date) {
        await this.createReminder(vaccination);
      }
    }
  }

  async createReminder(vaccination: Vaccination): Promise<Reminder | null> {
    const vaccinationWithRelations = await this.vaccinationRepository.findOne({
      where: {
        vaccination_id: vaccination.vaccination_id,
      },
      relations: {
        flock: {
          farmer: true,
        },
        vaccine: true,
      },
    });

    if (!vaccinationWithRelations?.next_due_date) {
      return null;
    }

    const exists = await this.reminderRepository.findOne({
      where: {
        vaccination_id: vaccinationWithRelations.vaccination_id,
        scheduled_date: vaccinationWithRelations.next_due_date,
      },
    });

    if (exists) {
      return exists;
    }

    const farmerId = vaccinationWithRelations.flock?.farmer?.user_id;
    if (!farmerId) {
      return null;
    }

    return this.reminderRepository.save({
      vaccination_id: vaccinationWithRelations.vaccination_id,
      farmer_id: farmerId,
      title: 'Vaccination Reminder',
      message: `${vaccinationWithRelations.flock.batch_name} is due for ${vaccinationWithRelations.vaccine.name_en} vaccination tomorrow.`,
      scheduled_date: vaccinationWithRelations.next_due_date,
      status: ReminderStatus.PENDING,
      sent_by: ReminderSender.SYSTEM,
    });
  }
}