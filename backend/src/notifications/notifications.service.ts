import { Injectable, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Notification, NotificationType } from './entities/notification.entity';
import { Vaccination, VaccinationStatus } from '../vaccinations/entities/vaccination.entity';

@Injectable()
export class NotificationsService {
  private readonly logger = new Logger(NotificationsService.name);

  constructor(
    @InjectRepository(Notification)
    private readonly notificationRepository: Repository<Notification>,
    @InjectRepository(Vaccination)
    private readonly vaccinationRepository: Repository<Vaccination>,
  ) {}

  async findByFarmer(farmerId: number): Promise<Notification[]> {
    // Proactively sync overdue vaccination notifications so the farmer
    // always sees up-to-date overdue alerts in their notification list.
    await this.syncOverdueNotifications(farmerId);

    return this.notificationRepository.find({
      where: { farmerId },
      order: { created_at: 'DESC' },
    });
  }

  async createVetResponseNotification(params: {
    farmerId: number;
    reportId: number;
    vetDiagnosis: string;
    flockName?: string;
  }): Promise<Notification> {
    const flockName = params.flockName?.trim();
    const flockReference = flockName ? ` for ${flockName}` : '';
    const notification = this.notificationRepository.create({
      farmerId: params.farmerId,
      title: 'Veterinarian Response Received',
      message: `Your veterinarian responded to the sick report${flockReference}.`,
      type: NotificationType.VET_RESPONSE,
      referenceId: params.reportId,
    });
    return this.notificationRepository.save(notification);
  }

  /**
   * Create a notification record for a vaccination that is overdue.
   * The method is idempotent – it will not create a duplicate notification
   * for the same vaccination.
   */
  async createOverdueVaccinationNotification(
    vaccination: Vaccination,
  ): Promise<Notification | null> {
    if (
      !vaccination.next_due_date ||
      !vaccination.flock?.farmer?.user_id ||
      !vaccination.flock?.flock_id ||
      !vaccination.vaccine
    ) {
      return null;
    }

    const farmerId = vaccination.flock.farmer.user_id;

    // Avoid duplicate notifications for the same vaccination
    const existing = await this.notificationRepository.findOne({
      where: {
        farmerId,
        type: NotificationType.VACCINATION_OVERDUE,
        referenceId: vaccination.vaccination_id,
      },
    });
    if (existing) {
      return existing;
    }

    const dueDate = new Date(vaccination.next_due_date);
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    dueDate.setHours(0, 0, 0, 0);
    const diffDays = Math.ceil(
      (dueDate.getTime() - today.getTime()) / (1000 * 60 * 60 * 24),
    );
    const absDays = Math.abs(diffDays);

    const vaccineNameEn =
      vaccination.vaccine.name_en || vaccination.vaccine.name_km || 'Unknown vaccine';
    const vaccineNameKm =
      vaccination.vaccine.name_km || vaccination.vaccine.name_en || 'Unknown vaccine';
    const flockName = vaccination.flock.batch_name || 'Unknown flock';

    const notification = this.notificationRepository.create({
      farmerId,
      title: 'Vaccination Overdue',
      message: `${vaccineNameEn} vaccination is overdue for ${flockName}.`,
      type: NotificationType.VACCINATION_OVERDUE,
      referenceId: vaccination.vaccination_id,
      data: {
        vaccination_id: vaccination.vaccination_id,
        vaccine_name: vaccineNameEn,
        vaccine_name_km: vaccineNameKm,
        flock_name: flockName,
        due_date: dueDate.toISOString().split('T')[0],
        flock_id: vaccination.flock.flock_id,
        vaccine_id: vaccination.vaccine.vaccine_id,
      },
    });

    this.logger.log(
      `Created overdue vaccination notification (${absDays} days overdue) for vaccination ${vaccination.vaccination_id}`,
    );
    return this.notificationRepository.save(notification);
  }

  /**
   * Scan all vaccinations for a farmer whose next_due_date has already
   * passed and create an unread notification for each one that does not
   * already have one.
   */
  async syncOverdueNotifications(farmerId: number): Promise<void> {
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const todayStr = today.toISOString().split('T')[0];

    const overdueVaccinations = await this.vaccinationRepository
      .createQueryBuilder('vaccination')
      .leftJoinAndSelect('vaccination.flock', 'flock')
      .leftJoinAndSelect('flock.farmer', 'farmer')
      .leftJoinAndSelect('vaccination.vaccine', 'vaccine')
      .where('farmer.user_id = :farmerId', { farmerId })
      .andWhere('vaccination.next_due_date < :today', { today: todayStr })
      .andWhere('vaccination.status != :completed', {
        completed: VaccinationStatus.COMPLETED,
      })
      .getMany();

    for (const vaccination of overdueVaccinations) {
      await this.createOverdueVaccinationNotification(vaccination);
    }
  }

  /**
   * Mark all unread overdue-vaccination notifications that belong to a
   * specific flock as read.  Called when the farmer logs a new vaccination
   * for that flock so the overdue alert is cleared.
   */
  async markOverdueNotificationsRead(
    farmerId: number,
    flockId: number,
  ): Promise<void> {
    await this.notificationRepository
      .createQueryBuilder()
      .update(Notification)
      .set({ isRead: true })
      .where('farmer_id = :farmerId', { farmerId })
      .andWhere('type = :type', {
        type: NotificationType.VACCINATION_OVERDUE,
      })
      .andWhere('is_read = :isRead', { isRead: false })
      .andWhere(
        'reference_id IN (SELECT vaccination_id FROM vaccinations WHERE flock_id = :flockId)',
        { flockId },
      )
      .execute();
  }

  async markAsRead(id: number, farmerId: number): Promise<void> {
    await this.notificationRepository.update(
      { notification_id: id, farmerId },
      { isRead: true },
    );
  }

  async markAllAsRead(farmerId: number): Promise<void> {
    await this.notificationRepository.update(
      { farmerId, isRead: false },
      { isRead: true },
    );
  }

  async getUnreadCount(farmerId: number): Promise<number> {
    return this.notificationRepository.count({
      where: { farmerId, isRead: false },
    });
  }
}
