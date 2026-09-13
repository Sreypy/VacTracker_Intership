import { NotificationsService } from './notifications.service';
import { NotificationType } from './entities/notification.entity';

describe('NotificationsService – veterinarian notifications', () => {
  const buildService = () => {
    const notificationRepository = {
      find: jest.fn(async () => []),
      count: jest.fn(async () => 0),
      create: jest.fn((data: any) => ({ notification_id: 1, ...data })),
      save: jest.fn(async (n: any) =>
        Array.isArray(n)
          ? n.map((x, i) => ({ notification_id: i + 1, ...x }))
          : { notification_id: 1, ...n },
      ),
      update: jest.fn(async () => undefined),
    };
    const vaccinationRepository = { createQueryBuilder: jest.fn() };

    const service = new NotificationsService(
      notificationRepository as any,
      vaccinationRepository as any,
    );

    return { service, notificationRepository, vaccinationRepository };
  };

  it('creates a sick-report notification for every connected vet', async () => {
    const { service, notificationRepository, vaccinationRepository } = buildService();

    const created = await service.createSickReportNotificationsForVets({
      vetIds: [5, 6],
      farmerName: 'Sophea',
      flockName: 'Batch A',
      affectedCount: 5,
      reportId: 33,
      reportDate: '2026-09-12',
    });

    expect(created).toHaveLength(2);
    expect(created[0]).toMatchObject({
      vetId: 5,
      type: NotificationType.SICK_REPORT,
      referenceId: 33,
      title: 'New Sick Report',
      message: 'Sophea reported sick chickens in Batch A.',
    });
    expect(created[0].data).toMatchObject({
      report_id: 33,
      farmer_name: 'Sophea',
      flock_name: 'Batch A',
      affected_count: 5,
    });
    // Vaccination reminder logic must NOT be involved for vets.
    expect(vaccinationRepository.createQueryBuilder).not.toHaveBeenCalled();
  });

  it('creates no notifications when the farmer has no connected vet', async () => {
    const { service, notificationRepository } = buildService();

    const created = await service.createSickReportNotificationsForVets({
      vetIds: [],
      farmerName: 'Sophea',
      flockName: 'Batch A',
      affectedCount: 5,
      reportId: 33,
      reportDate: '2026-09-12',
    });

    expect(created).toEqual([]);
    expect(notificationRepository.save).not.toHaveBeenCalled();
  });

  it('creates a connection-request notification with pending status', async () => {
    const { service } = buildService();

    const created = await service.createConnectionRequestNotification({
      vetId: 5,
      connectionId: 42,
      farmerName: 'Sophea',
    });

    expect(created).toMatchObject({
      vetId: 5,
      type: NotificationType.FARMER_CONNECTION_REQUEST,
      referenceId: 42,
      message: 'Sophea wants to connect with you.',
    });
    expect(created.data).toMatchObject({
      connection_id: 42,
      farmer_name: 'Sophea',
      connection_status: 'pending',
      status: 'pending',
    });
  });

  it('persists the connection status and marks the notification read', async () => {
    const { service, notificationRepository } = buildService();
    const savedNotifications: any[] = [];
    (notificationRepository.find as jest.Mock).mockResolvedValue([
      {
        notification_id: 15,
        vetId: 5,
        type: NotificationType.FARMER_CONNECTION_REQUEST,
        referenceId: 42,
        isRead: false,
        data: { farmer_name: 'Sophea', connection_status: 'pending' },
      },
    ]);
    (notificationRepository.save as jest.Mock).mockImplementation(
      async (n: any) => {
        savedNotifications.push(n);
        return n;
      },
    );

    await service.setConnectionRequestStatus(5, 42, 'connected');

    expect(savedNotifications).toHaveLength(1);
    expect(savedNotifications[0]).toMatchObject({
      isRead: true,
      data: { connection_status: 'connected' },
    });
  });

  it('counts only unread vet notifications', async () => {
    const { service, notificationRepository } = buildService();

    await service.getVetUnreadCount(5);

    expect(notificationRepository.count).toHaveBeenCalledWith({
      where: { vetId: 5, isRead: false },
    });
  });
});
