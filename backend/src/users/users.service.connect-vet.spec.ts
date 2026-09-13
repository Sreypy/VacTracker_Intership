import { UsersService } from './users.service';
import { User, UserRole } from './entities/user.entity';
import { BadRequestException, ConflictException, NotFoundException } from '@nestjs/common';

describe('UsersService.connectToVet', () => {
  const vet: User = {
    user_id: 5,
    name: 'Dr. Sokha',
    phone: '+855100000000',
    role: UserRole.VETERINARIAN,
    vet_code: 'SOKHA-4827',
    share_code: '0f8a9c1e-1234-4abc-9def-567890abcdef',
  } as User;

  const buildService = (existingConnection: unknown = null) => {
    const notificationsService = {
      createConnectionRequestNotification: jest.fn(async () => ({})),
    };

    const userRepository = {
      // Mirrors the OR-based lookup used by connectToVet.
      findOne: jest.fn(async ({ where }: any) => {
        const conditions = Array.isArray(where) ? where : [where];
        const isUserLookup = conditions.some(
          (condition: any) =>
            condition.user_id !== undefined || condition.phone !== undefined,
        );
        if (isUserLookup) {
          return conditions.some((condition: any) => condition.user_id === 10)
            ? { user_id: 10, name: 'Sophea', role: UserRole.FARMER }
            : null;
        }
        const matches = conditions.some((condition: any) => {
          const roleOk =
            condition.role === undefined || condition.role === vet.role;
          const codeOk =
            (condition.vet_code !== undefined &&
              condition.vet_code === vet.vet_code) ||
            (condition.share_code !== undefined &&
              condition.share_code === vet.share_code);
          return roleOk && codeOk;
        });
        return matches ? vet : null;
      }),
    };

    const connectionRepository = {
      findOne: jest.fn(async () => existingConnection),
      create: jest.fn((data: any) => ({ connection_id: 42, ...data })),
      save: jest.fn(async (connection: any) => connection),
    };

    const service = new UsersService(
      userRepository as any,
      connectionRepository as any,
      {} as any,
      notificationsService as any,
    );

    return { service, userRepository, connectionRepository, notificationsService };
  };

  it('connects a farmer with the exact payload the app sends (lowercase vet_code)', async () => {
    const { service, connectionRepository, notificationsService } = buildService();

    const result = await service.connectToVet(10, {
      vet_code: 'sokha-4827',
    } as any);

    expect(result.status).toBe('pending');
    expect(result.vetId).toBe(vet.user_id);
    expect(result.farmerId).toBe(10);
    expect(connectionRepository.save).toHaveBeenCalled();
    // A "New Farmer Connection Request" notification is created for the vet.
    expect(notificationsService.createConnectionRequestNotification).toHaveBeenCalledWith(
      expect.objectContaining({
        vetId: vet.user_id,
        connectionId: 42,
        farmerName: 'Sophea',
      }),
    );
  });

  it('normalizes codes with spaces and mixed case', async () => {
    const { service, connectionRepository } = buildService();

    await service.connectToVet(10, {
      vet_code: '  Sokha - 4827  ',
    } as any);

    expect(connectionRepository.create).toHaveBeenCalledWith(
      expect.objectContaining({
        vetId: vet.user_id,
        farmerId: 10,
        status: 'pending',
      }),
    );
  });

  it('still works with the legacy UUID share code', async () => {
    const { service, connectionRepository } = buildService();

    const result = await service.connectToVet(10, {
      vetShareCode: vet.share_code,
    } as any);

    expect(result.status).toBe('pending');
    expect(result.vetId).toBe(vet.user_id);
  });

  it('rejects unknown / invalid codes with "Veterinarian not found."', async () => {
    const { service } = buildService();

    for (const code of ['ABC-12', 'UNKNOWN-9999', 'SOKHA-0000']) {
      await expect(service.connectToVet(10, { vet_code: code } as any)).rejects.toThrow(
        new NotFoundException('Veterinarian not found.'),
      );
    }
  });

  it('prevents a farmer from connecting to themselves', async () => {
    const { service } = buildService();

    await expect(
      service.connectToVet(vet.user_id, { vet_code: 'SOKHA-4827' } as any),
    ).rejects.toThrow(BadRequestException);
  });

  it('prevents duplicate connections', async () => {
    const { service, connectionRepository } = buildService({
      connection_id: 7,
      vetId: vet.user_id,
      farmerId: 10,
    });

    await expect(
      service.connectToVet(10, { vet_code: 'SOKHA-4827' } as any),
    ).rejects.toThrow(ConflictException);
    expect(connectionRepository.save).not.toHaveBeenCalled();
  });

  it('requires a code', async () => {
    const { service } = buildService();

    await expect(service.connectToVet(10, {} as any)).rejects.toThrow(
      new BadRequestException('Vet code is required'),
    );
  });

  it('re-requests a connection with the same vet after disconnecting', async () => {
    const { service, connectionRepository, notificationsService } = buildService({
      connection_id: 7,
      vetId: vet.user_id,
      farmerId: 10,
      status: 'disconnected',
    });

    const result = await service.connectToVet(10, {
      vet_code: 'SOKHA-4827',
    } as any);

    expect(result.status).toBe('pending');
    expect(connectionRepository.save).toHaveBeenCalled();
    expect(notificationsService.createConnectionRequestNotification).toHaveBeenCalled();
  });
});

describe('UsersService.disconnectVet', () => {
  const vet: User = {
    user_id: 5,
    name: 'Dr. Sokha',
    phone: '+855100000000',
    role: UserRole.VETERINARIAN,
    vet_code: 'SOKHA-4827',
  } as User;

  const buildService = (activeConnections: any[]) => {
    const savedStatuses: string[] = [];

    const userRepository = {
      findOne: jest.fn(async ({ where }: any) =>
        where?.user_id === 10
          ? { user_id: 10, name: 'Sophea', role: UserRole.FARMER }
          : null,
      ),
    };

    const connectionRepository = {
      find: jest.fn(async () => activeConnections),
      save: jest.fn(async (connection: any) => {
        savedStatuses.push(connection.status);
        return connection;
      }),
    };

    const notificationsService = {
      createFarmerDisconnectedNotification: jest.fn(async () => ({})),
    };

    const service = new UsersService(
      userRepository as any,
      connectionRepository as any,
      {} as any,
      notificationsService as any,
    );

    return {
      service,
      connectionRepository,
      notificationsService,
      savedStatuses,
    };
  };

  it('deactivates the connection and notifies the vet (row kept, not deleted)', async () => {
    const active = {
      connection_id: 7,
      vetId: 5,
      farmerId: 10,
      status: 'accepted',
      vet,
    };
    const { service, connectionRepository, notificationsService, savedStatuses } =
      buildService([active]);

    const result = await service.disconnectVet(10, { vet_id: 5 });

    expect(result.disconnected).toHaveLength(1);
    expect(result.disconnected[0]).toMatchObject({
      connection_id: 7,
      vet_id: 5,
      vet_name: 'Dr. Sokha',
      status: 'disconnected',
    });
    // The historical connection row is deactivated, not deleted.
    expect(connectionRepository.find).not.toHaveBeenCalledWith(
      expect.anything(),
      expect.objectContaining({ cascade: true }),
    );
    expect(savedStatuses).toEqual(['disconnected']);
    expect(notificationsService.createFarmerDisconnectedNotification).toHaveBeenCalledWith(
      expect.objectContaining({
        vetId: 5,
        connectionId: 7,
        farmerName: 'Sophea',
      }),
    );
  });

  it('reports clearly when there is no active connection', async () => {
    const { service } = buildService([]);

    await expect(service.disconnectVet(10, { vet_id: 5 })).rejects.toThrow(
      NotFoundException,
    );
  });

  it('only disconnects the requested vet', async () => {
    const otherVet = { ...vet, user_id: 9, name: 'Dr. Dara' };
    const active = [
      { connection_id: 7, vetId: 5, farmerId: 10, status: 'accepted', vet },
      {
        connection_id: 8,
        vetId: 9,
        farmerId: 10,
        status: 'accepted',
        vet: otherVet,
      },
    ];
    const { service, savedStatuses } = buildService(active);

    await service.disconnectVet(10, { vet_id: 5 });

    // Only the connection with vet 5 was deactivated.
    expect(savedStatuses).toEqual(['disconnected']);
  });
});
