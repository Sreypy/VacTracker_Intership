import { VetConnectionsService } from './vet-connections.service';
import { User, UserRole } from '../users/entities/user.entity';
import { ConflictException, ForbiddenException, NotFoundException } from '@nestjs/common';

describe('VetConnectionsService – accept / reject', () => {
  const vet: User = {
    user_id: 5,
    name: 'Dr. Sokha',
    phone: '+855100000000',
    role: UserRole.VETERINARIAN,
  } as User;

  const buildService = (connection: any) => {
    const connectionRepository = {
      find: jest.fn(async () => []),
      findOne: jest.fn(async () => connection),
      save: jest.fn(async (c: any) => c),
    };
    const userRepository = {
      findOne: jest.fn(async () => vet),
    };
    const notificationsService = {
      setConnectionRequestStatus: jest.fn(async () => undefined),
    };

    const service = new VetConnectionsService(
      connectionRepository as any,
      userRepository as any,
      notificationsService as any,
    );

    return { service, connectionRepository, notificationsService };
  };

  it('accepting sets the connection to accepted and marks the notification handled', async () => {
    const { service, connectionRepository, notificationsService } = buildService({
      connection_id: 42,
      vetId: 5,
      farmerId: 10,
      status: 'pending',
    });

    const result = await service.respondToConnection(vet.phone, 42, 'accept');

    expect(result.status).toBe('accepted');
    expect(connectionRepository.save).toHaveBeenCalled();
    expect(notificationsService.setConnectionRequestStatus).toHaveBeenCalledWith(
      5,
      42,
      'connected',
    );
  });

  it('rejecting sets the connection to rejected and marks the notification handled', async () => {
    const { service, notificationsService } = buildService({
      connection_id: 42,
      vetId: 5,
      farmerId: 10,
      status: 'pending',
    });

    const result = await service.respondToConnection(vet.phone, 42, 'reject');

    expect(result.status).toBe('rejected');
    expect(notificationsService.setConnectionRequestStatus).toHaveBeenCalledWith(
      5,
      42,
      'rejected',
    );
  });

  it('another vet cannot respond to a request that is not theirs', async () => {
    const { service } = buildService({
      connection_id: 42,
      vetId: 99,
      farmerId: 10,
      status: 'pending',
    });

    await expect(
      service.respondToConnection(vet.phone, 42, 'accept'),
    ).rejects.toThrow(ForbiddenException);
  });

  it('cannot accept an already accepted request', async () => {
    const { service } = buildService({
      connection_id: 42,
      vetId: 5,
      farmerId: 10,
      status: 'accepted',
    });

    await expect(
      service.respondToConnection(vet.phone, 42, 'accept'),
    ).rejects.toThrow(ConflictException);
  });

  it('cannot accept a request after the farmer disconnected', async () => {
    const { service } = buildService({
      connection_id: 42,
      vetId: 5,
      farmerId: 10,
      status: 'disconnected',
    });

    await expect(
      service.respondToConnection(vet.phone, 42, 'accept'),
    ).rejects.toThrow(ConflictException);
  });

  it('unknown connection id -> not found', async () => {
    const { service } = buildService(null);

    await expect(
      service.respondToConnection(vet.phone, 999, 'accept'),
    ).rejects.toThrow(NotFoundException);
  });
});
