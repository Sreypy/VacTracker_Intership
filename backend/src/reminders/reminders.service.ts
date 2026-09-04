import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';

import { Reminder, ReminderSender, ReminderStatus } from './entities/reminder.entity';
import {
  Vaccination,
  VaccinationStatus,
} from 'src/vaccinations/entities/vaccination.entity';
import { NotificationsService } from 'src/notifications/notifications.service';

@Injectable()
export class RemindersService {
  constructor(
    @InjectRepository(Reminder)
    private readonly reminderRepository: Repository<Reminder>,

    @InjectRepository(Vaccination)
    private readonly vaccinationRepository: Repository<Vaccination>,

    private readonly notificationsService: NotificationsService,
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
      if (
        vaccination.status !== VaccinationStatus.COMPLETED &&
        vaccination.next_due_date
      ) {
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

    // Also mark any overdue-vaccination notifications for this flock as read
    // so the badge count and notification list are cleared after vaccinating.
    await this.notificationsService.markOverdueNotificationsRead(
      farmerId,
      flockId,
    );
  }

  async createReminder(vaccination: Vaccination): Promise<Reminder | null> {
    if (vaccination.status === VaccinationStatus.COMPLETED) {
      return null;
    }

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
      message: this._buildReminderMessage(vaccinationWithRelations),
      scheduled_date: vaccinationWithRelations.next_due_date,
      status: ReminderStatus.PENDING,
      sent_by: ReminderSender.SYSTEM,
    });
  }

  /**
   * Build a human-readable reminder message that correctly reflects
   * whether the vaccination is overdue, due today, or upcoming.
   */
  private _buildReminderMessage(vaccination: Vaccination): string {
    const flockName = vaccination.flock?.batch_name ?? 'your flock';
    const vaccineName =
      vaccination.vaccine?.name_en ?? vaccination.vaccine?.name_km ?? 'vaccine';
    const dueDate = vaccination.next_due_date;

    if (!dueDate) {
      return `${vaccineName} vaccination reminder for ${flockName}.`;
    }

    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const due = new Date(dueDate);
    due.setHours(0, 0, 0, 0);
    const diffDays = Math.ceil(
      (due.getTime() - today.getTime()) / (1000 * 60 * 60 * 24),
    );

    if (diffDays < 0) {
      const absDays = Math.abs(diffDays);
      return `${vaccineName} vaccination is overdue for ${flockName} (${absDays} ${absDays === 1 ? 'day' : 'days'} ago).`;
    }
    if (diffDays === 0) {
      return `${vaccineName} vaccination is due today for ${flockName}.`;
    }
    return `${vaccineName} vaccination is due for ${flockName} on ${dueDate.toISOString().split('T')[0]}.`;
  }
}