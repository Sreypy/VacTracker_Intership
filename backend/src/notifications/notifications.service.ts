import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Notification, NotificationType } from './entities/notification.entity';

@Injectable()
export class NotificationsService {
  constructor(
    @InjectRepository(Notification)
    private readonly notificationRepository: Repository<Notification>,
  ) {}

  async findByFarmer(farmerId: number): Promise<Notification[]> {
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
