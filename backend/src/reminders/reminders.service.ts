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

    // Use query builder to sort by status (PENDING first) then by scheduled_date
    // Exclude COMPLETED reminders so the overdue count decreases when a
    // vaccination is logged from the reminder screen
    return this.reminderRepository
      .createQueryBuilder('reminder')
      .leftJoinAndSelect('reminder.vaccination', 'vaccination')
      .leftJoinAndSelect('vaccination.flock', 'flock')
      .leftJoinAndSelect('vaccination.vaccine', 'vaccine')
      .where('reminder.farmer_id = :farmerId', { farmerId })
      .andWhere('reminder.status != :completed', {
        completed: ReminderStatus.COMPLETED,
      })
      .orderBy('CASE WHEN reminder.status = :pending THEN 0 ELSE 1 END', 'ASC')
      .addOrderBy('reminder.scheduled_date', 'ASC')
      .setParameter('pending', ReminderStatus.PENDING)
      .getMany();
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

  async markRemindersCompleted(farmerId: number, flockId: number): Promise<void> {
    // Find all pending reminders for this farmer's flock and mark them as completed
    await this.reminderRepository
      .createQueryBuilder()
      .update(Reminder)
      .set({ status: ReminderStatus.COMPLETED })
      .where('farmer_id = :farmerId', { farmerId })
      .andWhere('status IN (:...statuses)', {
        statuses: [ReminderStatus.PENDING, ReminderStatus.SENT],
      })
      .andWhere(
        'vaccination_id IN (SELECT vaccination_id FROM vaccinations WHERE flock_id = :flockId)',
        { flockId },
      )
      .execute();
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