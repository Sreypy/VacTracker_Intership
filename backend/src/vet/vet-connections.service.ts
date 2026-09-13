import {
  Injectable,
  NotFoundException,
  ForbiddenException,
  ConflictException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';

import { User, UserRole } from '../users/entities/user.entity';
import {
  VetFarmerConnection,
  ConnectionStatus,
} from '../users/entities/vet-farmer-connection.entity';
import { NotificationsService } from '../notifications/notifications.service';

@Injectable()
export class VetConnectionsService {
  constructor(
    @InjectRepository(VetFarmerConnection)
    private readonly connectionRepository: Repository<VetFarmerConnection>,

    @InjectRepository(User)
    private readonly userRepository: Repository<User>,

    private readonly notificationsService: NotificationsService,
  ) {}

  /**
   * Resolves the logged-in veterinarian and makes sure the user really is
   * a VETERINARIAN.
   */
  private async getVet(vetPhone: string): Promise<User> {
    const vet = await this.userRepository.findOne({
      where: { phone: vetPhone, role: UserRole.VETERINARIAN },
    });

    if (!vet) {
      throw new NotFoundException('Veterinarian not found');
    }

    return vet;
  }

  /**
   * Lists the PENDING connection requests for the logged-in veterinarian.
   */
  async getConnectionRequests(vetPhone: string) {
    const vet = await this.getVet(vetPhone);

    const requests = await this.connectionRepository.find({
      where: {
        vetId: vet.user_id,
        status: ConnectionStatus.PENDING,
      },
      relations: { farmer: true },
      order: { created_at: 'DESC' },
    });

    return requests.map((request) => ({
      connection_id: request.connection_id,
      status: request.status,
      created_at: request.created_at,
      farmer: {
        user_id: request.farmer.user_id,
        name: request.farmer.name,
        phone: request.farmer.phone,
        village: request.farmer.village,
        province: request.farmer.province,
        profile_image_url: request.farmer.profile_image_url,
      },
    }));
  }

  /**
   * Accepts or rejects a connection request. Only the veterinarian of the
   * connection can respond, and the user must be a VETERINARIAN.
   */
  async respondToConnection(
    vetPhone: string,
    connectionId: number,
    action: 'accept' | 'reject',
  ) {
    const vet = await this.getVet(vetPhone);

    const connection = await this.connectionRepository.findOne({
      where: { connection_id: connectionId },
      relations: { farmer: true },
    });

    if (!connection) {
      throw new NotFoundException('Connection request not found');
    }

    if (connection.vetId !== vet.user_id) {
      throw new ForbiddenException(
        'This connection request does not belong to you',
      );
    }

    if (connection.status === ConnectionStatus.DISCONNECTED) {
      throw new ConflictException(
        'The farmer has disconnected. Ask them to send a new connection request.',
      );
    }

    if (action === 'accept') {
      if (connection.status === ConnectionStatus.ACCEPTED) {
        throw new ConflictException('Connection request is already accepted');
      }
      connection.status = ConnectionStatus.ACCEPTED;
    } else {
      if (connection.status === ConnectionStatus.REJECTED) {
        throw new ConflictException('Connection request is already rejected');
      }
      connection.status = ConnectionStatus.REJECTED;
    }

    const saved = await this.connectionRepository.save(connection);

    // Persist the outcome on the related notification so the vet sees
    // "Connected"/"Rejected" even after reloading. The notification is
    // also marked read so it no longer counts towards the unread badge.
    const connectionStatus: 'connected' | 'rejected' =
      action === 'accept' ? 'connected' : 'rejected';
    await this.notificationsService.setConnectionRequestStatus(
      vet.user_id,
      connection.connection_id,
      connectionStatus,
    );

    return saved;
  }
}
