import { NotificationsService } from './notifications.service';
import { NotificationType } from './entities/notification.entity';
import { Vaccination, VaccinationStatus } from '../vaccinations/entities/vaccination.entity';

describe('NotificationsService – vaccination notifications', () => {
  // In-memory store so `find` reflects what `save` persists, exactly like the
  // real database does for these service-level tests.
  const buildHarness = () => {
    const stored: any[] = [];
    const notificationRepository = {
      find: jest.fn(async () => stored),
      create: jest.fn((data: any) => ({
        notification_id: 10,
        createdAt: new Date('2026-09-14T10:30:00.000Z'),
        ...data,
      })),
      save: jest.fn(async (n: any) => {
        if (Array.isArray(n)) return n;
        if (!stored.some((x) => x.notification_id === n.notification_id)) {
          stored.push(n);
        }
        return n;
      }),
      remove: jest.fn(async (entities: any) => {
        const list = Array.isArray(entities) ? entities : [entities];
        for (const entity of list) {
          const index = stored.findIndex(
            (x) => x.notification_id === entity.notification_id,
          );
          if (index >= 0) stored.splice(index, 1);
        }
      }),
    };
    const vaccinationRepository = {};

    const service = new NotificationsService(
      notificationRepository as any,
      vaccinationRepository as any,
    );

    return { service, notificationRepository, stored };
  };

  const buildVaccination = (overrides: Partial<Vaccination> = {}) =>
    ({
      vaccination_id: 1,
      next_due_date: new Date('2026-09-15T00:00:00.000Z'),
      status: VaccinationStatus.OVERDUE,
      flock: {
        flock_id: 7,
        batch_name: 'Batch A',
        farmer: { user_id: 3 },
      },
      vaccine: {
        vaccine_id: 5,
        name_en: 'Newcastle',
        name_km: 'នូកាសែល',
      },
      next_vaccine: null,
      ...overrides,
    }) as unknown as Vaccination;

  it('creates exactly one "vaccine due today" notification and reuses it', async () => {
    const { service, notificationRepository, stored } = buildHarness();
    const vaccination = buildVaccination({
      status: VaccinationStatus.ON_TIME,
      next_due_date: new Date('2026-09-15T00:00:00.000Z'),
    });

    const first = await service.createDueTodayVaccinationNotification(
      vaccination,
    );
    const second = await service.createDueTodayVaccinationNotification(
      vaccination,
    );

    expect(first?.notification_id).toBe(second?.notification_id);
    expect(stored).toHaveLength(1);
    // The repository is only asked to CREATE once; the second call updates.
    expect(
      notificationRepository.create.mock.calls.filter(
        ([c]) => c.referenceId === 1,
      ),
    ).toHaveLength(1);
    expect(stored[0]).toMatchObject({
      farmerId: 3,
      referenceId: 1,
      type: NotificationType.VACCINE_DUE_TODAY,
      title: 'Vaccine Due Today',
    });
    expect(stored[0].createdAt).toEqual(
      new Date('2026-09-14T10:30:00.000Z'),
    );
  });

  it('turns the SAME "due today" notification into an overdue one (no duplicate)', async () => {
    const { service, stored } = buildHarness();
    const vaccination = buildVaccination({
      status: VaccinationStatus.ON_TIME,
      next_due_date: new Date('2026-09-15T00:00:00.000Z'),
    });

    await service.createDueTodayVaccinationNotification(vaccination);
    const notificationId = stored[0].notification_id;

    const updated = await service.createOverdueVaccinationNotification(
      vaccination,
    );

    expect(updated?.notification_id).toBe(notificationId);
    expect(stored).toHaveLength(1);
    expect(stored[0]).toMatchObject({
      type: NotificationType.VACCINATION_OVERDUE,
      title: 'Vaccination Overdue',
      isRead: false,
    });
    // The original creation timestamp is preserved across the transition.
    expect(stored[0].createdAt).toEqual(
      new Date('2026-09-14T10:30:00.000Z'),
    );
});

  it('marks the SAME notification as completed and keeps it in history', async () => {
    const { service, notificationRepository, stored } = buildHarness();
    const vaccination = buildVaccination();

    await service.createOverdueVaccinationNotification(vaccination);
    const notificationId = stored[0].notification_id;
    const completedAt = new Date('2026-09-15T10:30:00.000Z');

    await service.markVaccinationCompleted({
      farmerId: 3,
      vaccinationId: vaccination.vaccination_id,
      completedAt,
    });

    expect(stored).toHaveLength(1);
    expect(stored[0].notification_id).toBe(notificationId);
    expect(stored[0].type).toBe(NotificationType.VACCINATION_COMPLETED);
    expect(stored[0].title).toBe('Vaccination Completed');
    expect(stored[0].isRead).toBe(true);
    expect(stored[0].data).toMatchObject({
      status: 'completed',
      completed_at: completedAt.toISOString(),
      vaccination_id: 1,
      flock_name: 'Batch A',
      vaccine_name: 'Newcastle',
    });
    // createdAt is untouched – the entry simply changed state.
    expect(stored[0].createdAt).toEqual(
      new Date('2026-09-14T10:30:00.000Z'),
    );
    // The completion itself mutated the existing row: no repository.create.
    expect(notificationRepository.create).toHaveBeenCalledTimes(1);
  });

  it('merges pre-existing duplicate notifications for the same vaccination', async () => {
    const { service, notificationRepository, stored } = buildHarness();
    stored.push(
      {
        notification_id: 11,
        farmerId: 3,
        referenceId: 1,
        type: NotificationType.VACCINE_DUE_TODAY,
        title: 'Vaccine Due Today',
        isRead: false,
        createdAt: new Date('2026-09-14T10:30:00.000Z'),
      },
      {
        notification_id: 12,
        farmerId: 3,
        referenceId: 1,
        type: NotificationType.VACCINE_DUE_TODAY,
        title: 'Vaccine Due Today',
        isRead: false,
        createdAt: new Date('2026-09-14T10:35:00.000Z'),
      },
    );

    await service.markVaccinationCompleted({
      farmerId: 3,
      vaccinationId: 1,
      completedAt: new Date('2026-09-15T10:30:00.000Z'),
    });

    // First (oldest) notification is kept, the later duplicate removed.
    expect(notificationRepository.remove).toHaveBeenCalledWith([
      expect.objectContaining({ notification_id: 12 }),
    ]);
    expect(stored[0].notification_id).toBe(11);
    expect(stored[0].type).toBe(NotificationType.VACCINATION_COMPLETED);
    expect(stored).toHaveLength(1);
  });

  it('returns null for a due-today call on an already completed vaccination', async () => {
    const { service } = buildHarness();
    const vaccination = buildVaccination({
      status: VaccinationStatus.COMPLETED,
    });

    const created = await service.createDueTodayVaccinationNotification(
      vaccination,
    );

    expect(created).toBeNull();
  });
});