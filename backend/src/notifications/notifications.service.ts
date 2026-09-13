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

    const reminderVaccine = vaccination.next_vaccine ?? vaccination.vaccine;
    const vaccineNameEn =
      reminderVaccine.name_en || reminderVaccine.name_km || 'Unknown vaccine';
    const vaccineNameKm =
      reminderVaccine.name_km || reminderVaccine.name_en || 'Unknown vaccine';
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
        vaccine_id: reminderVaccine.vaccine_id,
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
      .leftJoinAndSelect('vaccination.next_vaccine', 'next_vaccine')
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

  // ==========================================
  // VETERINARIAN NOTIFICATIONS
  // (sick reports + farmer connection requests)
  // ==========================================

  /**
   * All notifications for a veterinarian. Unlike the farmer flow this does
   * NOT sync vaccination reminders – those are farmer-only notifications.
   */
  async findByVet(vetId: number): Promise<Notification[]> {
    return this.notificationRepository.find({
      where: { vetId },
      order: { created_at: 'DESC' },
    });
  }

  async getVetUnreadCount(vetId: number): Promise<number> {
    return this.notificationRepository.count({
      where: { vetId, isRead: false },
    });
  }

  async markVetNotificationAsRead(id: number, vetId: number): Promise<void> {
    await this.notificationRepository.update(
      { notification_id: id, vetId },
      { isRead: true },
    );
  }

  async markAllVetAsRead(vetId: number): Promise<void> {
    await this.notificationRepository.update(
      { vetId, isRead: false },
      { isRead: true },
    );
  }

  /**
   * Sets the persistent connection status on a farmer-connection-request
   * notification and marks it as read/handled. Called when the vet accepts
   * or rejects the request so the notification keeps reflecting the real
   * connection state after a reload.
   */
  async setConnectionRequestStatus(
    vetId: number,
    connectionId: number,
    connectionStatus: 'pending' | 'connected' | 'rejected',
  ): Promise<void> {
    const notifications = await this.notificationRepository.find({
      where: {
        vetId,
        type: NotificationType.FARMER_CONNECTION_REQUEST,
        referenceId: connectionId,
      },
    });

    for (const notification of notifications) {
      notification.data = {
        ...(notification.data ?? {}),
        connection_status: connectionStatus,
      };
      notification.isRead = true;
      await this.notificationRepository.save(notification);
    }
  }

  /**
   * Creates a notification for the veterinarian when a farmer requests a
   * connection with their vet code.
   */
  async createConnectionRequestNotification(params: {
    vetId: number;
    connectionId: number;
    farmerName: string;
  }): Promise<Notification> {
    const notification = this.notificationRepository.create({
      vetId: params.vetId,
      title: 'New Farmer Connection Request',
      message: `${params.farmerName} wants to connect with you.`,
      type: NotificationType.FARMER_CONNECTION_REQUEST,
      referenceId: params.connectionId,
      data: {
        connection_id: params.connectionId,
        farmer_name: params.farmerName,
        connection_status: 'pending',
        status: 'pending', // legacy alias kept for older clients
      },
    });
    return this.notificationRepository.save(notification);
  }

  /**
   * Creates a notification for the veterinarian when a farmer disconnects.
   */
  async createFarmerDisconnectedNotification(params: {
    vetId: number;
    connectionId: number;
    farmerName: string;
  }): Promise<Notification> {
    const notification = this.notificationRepository.create({
      vetId: params.vetId,
      title: 'Farmer Disconnected',
      message: `${params.farmerName} has disconnected from your veterinary service.`,
      type: NotificationType.FARMER_DISCONNECTED,
      referenceId: params.connectionId,
      data: {
        connection_id: params.connectionId,
        farmer_name: params.farmerName,
        connection_status: 'disconnected',
        status: 'disconnected', // legacy alias kept for older clients
      },
    });
    return this.notificationRepository.save(notification);
  }

  /**
   * Creates a notification for every ACCEPTED (connected) veterinarian of a
   * farmer when the farmer submits a new sick report.
   */
  async createSickReportNotificationsForVets(params: {
    vetIds: number[];
    farmerName: string;
    flockName: string;
    affectedCount: number;
    reportId: number;
    reportDate: string;
  }): Promise<Notification[]> {
    if (!params.vetIds.length) {
      return [];
    }

    const notifications = params.vetIds.map((vetId) =>
      this.notificationRepository.create({
        vetId,
        title: 'New Sick Report',
        message: `${params.farmerName} reported sick chickens in ${params.flockName}.`,
        type: NotificationType.SICK_REPORT,
        referenceId: params.reportId,
        data: {
          report_id: params.reportId,
          farmer_name: params.farmerName,
          flock_name: params.flockName,
          affected_count: params.affectedCount,
          report_date: params.reportDate,
        },
      }),
    );

    return this.notificationRepository.save(notifications);
  }
}
