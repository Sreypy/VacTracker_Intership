import {
  Injectable,
  NotFoundException,
  ConflictException,
  BadRequestException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { QueryFailedError, Repository } from 'typeorm';
import * as bcrypt from 'bcrypt';
import { randomUUID } from 'crypto';

import { generateVetCode, normalizeVetCode } from './utils/vet-code.util';

import { User, UserRole } from './entities/user.entity';
import { VetFarmerConnection, ConnectionStatus } from './entities/vet-farmer-connection.entity';
import { CreateUserDto } from './dto/create-user.dto';
import { UpdateUserDto } from './dto/update-user.dto';
import { ConnectVetDto } from './dto/connect-vet.dto';
import { CloudinaryService } from 'src/cloudinary/cloudinary.service';
import { NotificationsService } from '../notifications/notifications.service';

@Injectable()
export class UsersService {

  constructor(
    @InjectRepository(User)
    private readonly userRepository: Repository<User>,

    @InjectRepository(VetFarmerConnection)
    private readonly connectionRepository: Repository<VetFarmerConnection>,

    private readonly cloudinaryService: CloudinaryService,

    private readonly notificationsService: NotificationsService,

  ) {}

  async create(createUserDto: CreateUserDto) {
    const hashedPassword = await bcrypt.hash(
      createUserDto.password,
      10,
    );

    const user = this.userRepository.create({
      name: createUserDto.name,
      phone: createUserDto.phone,
      password_hash: hashedPassword,
      role: createUserDto.role,
      village: createUserDto.village,
      province: createUserDto.province,
      language_pref: createUserDto.language_pref,
      share_code: randomUUID(),
    });

    // Veterinarians receive their short user-facing code (e.g. SOKHA-4827)
    // at registration. Farmers do not get a vet code.
    if (user.role === UserRole.VETERINARIAN) {
      await this.ensureVetCode(user);
      return user;
    }

    return await this.userRepository.save(user);
  }
  
    async findAll(userId: number, role: string) {
      // Only return the current user's own record to prevent data leakage
      // (e.g., password_hash exposure)
      return await this.userRepository.find({
        where: { user_id: userId },
      });
    }
    async update(
      id: number,
      updateUserDto: UpdateUserDto,
    ) {
      await this.userRepository.update(
        id,
        updateUserDto,
      );
      return this.userRepository.findOne({
        where: {
          user_id: id,
        },
      });
    }

    async getProfile(phone: string) {
    const user = await this.userRepository.findOne({
      where: {
        phone,
      },
    });

    if (!user) {
      throw new NotFoundException('User not found');
    }

    if (!user.share_code) {
      user.share_code = randomUUID();
      await this.userRepository.save(user);
    }

    // Existing veterinarians that have no vet code yet receive a stable one
    // here. Codes are NEVER regenerated once they exist (see ensureVetCode).
    await this.ensureVetCode(user);

    return user;
  }

  async updateProfileImage(
    phone: string,
    file: any,
  ) {
    const user = await this.userRepository.findOne({
      where: { phone },
    });

    if (!user) {
      throw new NotFoundException('User not found');
    }

    if (!file) {
      throw new Error('No image file provided');
    }

    // Upload image to Cloudinary
  const result = await this.cloudinaryService.uploadImage(file, 'vactracker/profile');

    // Save Cloudinary URL to PostgreSQL
    user.profile_image_url = result.secure_url;

    return await this.userRepository.save(user);
  }

  async connectToVet(farmerId: number, connectVetDto: ConnectVetDto) {
    // Accept the new short vet code first (the app sends it as snake_case
    // `vet_code`), fall back to the camelCase alias and then to the legacy
    // UUID share code for backward compatibility.
    const rawCode = (
      connectVetDto.vet_code ??
      connectVetDto.vetCode ??
      connectVetDto.vetShareCode ??
      ''
    ).toString();

    if (!rawCode.trim()) {
      throw new BadRequestException('Vet code is required');
    }

    // Normalize the user-facing vet code before searching.
    // Example: " sokha-4827 " -> "SOKHA-4827"
    const normalizedCode = normalizeVetCode(rawCode);

    // Find the veterinarian by vet code (short code) or, as a fallback,
    // by the legacy UUID share code (original case preserved).
    const vet = await this.userRepository.findOne({
      where: [
        { vet_code: normalizedCode, role: UserRole.VETERINARIAN },
        { share_code: rawCode.trim(), role: UserRole.VETERINARIAN },
        { share_code: normalizedCode, role: UserRole.VETERINARIAN },
      ],
    });

    if (!vet) {
      throw new NotFoundException('Veterinarian not found.');
    }

    // Prevent a farmer from connecting to themselves.
    if (vet.user_id === farmerId) {
      throw new BadRequestException('You cannot connect to yourself.');
    }

    // Check if connection already exists (pending, accepted or rejected).
    const existingConnection = await this.connectionRepository.findOne({
      where: {
        vetId: vet.user_id,
        farmerId: farmerId,
      },
    });

    if (existingConnection) {
      // A rejected or disconnected request can be requested again – the
      // connection simply goes back to PENDING so the farmer is not stuck.
      if (
        existingConnection.status === ConnectionStatus.REJECTED ||
        existingConnection.status === ConnectionStatus.DISCONNECTED
      ) {
        existingConnection.status = ConnectionStatus.PENDING;
        const renewed = await this.connectionRepository.save(existingConnection);
        await this.notifyVetOfConnectionRequest(vet.user_id, renewed.connection_id, farmerId);
        return renewed;
      }

      throw new ConflictException('Connection already exists with this veterinarian');
    }

    // Create the connection request as PENDING. The veterinarian can then
    // accept or reject it (see VetConnectionsService). Existing connections
    // that were created before are not modified.
    const connection = this.connectionRepository.create({
      vetId: vet.user_id,
      farmerId: farmerId,
      status: ConnectionStatus.PENDING,
    });

    const saved = await this.connectionRepository.save(connection);
    await this.notifyVetOfConnectionRequest(vet.user_id, saved.connection_id, farmerId);
    return saved;
  }

  /**
   * Creates the "New Farmer Connection Request" notification for the vet.
   * Wrapped in try/catch so a notification failure never breaks the
   * connection request itself.
   */
  private async notifyVetOfConnectionRequest(
    vetId: number,
    connectionId: number,
    farmerId: number,
  ) {
    try {
      const farmer = await this.userRepository.findOne({
        where: { user_id: farmerId },
      });

      await this.notificationsService.createConnectionRequestNotification({
        vetId,
        connectionId,
        farmerName: farmer?.name ?? 'A farmer',
      });
    } catch {
      // Notification is non-critical – ignore failures.
    }
  }

  // ==========================================
  // DISCONNECT VET (farmer-initiated)
  // ==========================================

  /**
   * The farmer ends their relationship with a connected veterinarian.
   *
   * - The connection row is DEACTIVATED (status -> DISCONNECTED), never
   *   deleted, so historical sick reports / vaccinations stay intact.
   * - Because all "connected" queries filter on ACCEPTED, the farmer
   *   disappears from the vet's My Farmers list and the vet no longer
   *   receives new sick-report notifications from this farmer.
   * - A "Farmer Disconnected" notification is created for the vet.
   * - The farmer can then connect to another (or the same) vet.
   */
  async disconnectVet(
    farmerId: number,
    disconnectVetDto?: { vet_id?: number },
  ) {
    // Find the farmer's active (pending/accepted) connection(s).
    const activeConnections = await this.connectionRepository.find({
      where: [
        { farmerId, status: ConnectionStatus.ACCEPTED },
        { farmerId, status: ConnectionStatus.PENDING },
      ],
      relations: { vet: true },
    });

    const connectionsToDisconnect = disconnectVetDto?.vet_id
      ? activeConnections.filter(
          (connection) => connection.vetId === disconnectVetDto.vet_id,
        )
      : activeConnections;

    if (connectionsToDisconnect.length === 0) {
      throw new NotFoundException('No active veterinarian connection found.');
    }

    const farmer = await this.userRepository.findOne({
      where: { user_id: farmerId },
    });

    for (const connection of connectionsToDisconnect) {
      connection.status = ConnectionStatus.DISCONNECTED;
      await this.connectionRepository.save(connection);

      // "Farmer Disconnected" notification for the vet (non-critical).
      try {
        await this.notificationsService.createFarmerDisconnectedNotification({
          vetId: connection.vetId,
          connectionId: connection.connection_id,
          farmerName: farmer?.name ?? 'A farmer',
        });
      } catch {
        // Notification is non-critical – ignore failures.
      }
    }

    return {
      message: 'Veterinarian disconnected successfully.',
      disconnected: connectionsToDisconnect.map((connection) => ({
        connection_id: connection.connection_id,
        vet_id: connection.vetId,
        vet_name: connection.vet?.name,
        status: connection.status,
      })),
    };
  }

  async getMyVets(farmerId: number) {
    const connections = await this.connectionRepository.find({
      where: { farmerId },
      relations: { vet: true },
    });

    return connections.map((conn) => ({
      user_id: conn.vet.user_id,
      name: conn.vet.name,
      phone: conn.vet.phone,
      share_code: conn.vet.share_code,
      vet_code: conn.vet.vet_code,
      status: conn.status,
    }));
  }

  // ==========================================
  // VET CODE (short user-facing code)
  // ==========================================

  /**
   * Ensures a veterinarian has a stable, unique, user-facing vet code
   * (e.g. "SOKHA-4827").
   *
   * - Generates only when role is VETERINARIAN and no code exists yet.
   * - NEVER regenerates an existing code (codes stay stable).
   * - Checks the database before saving (does not assume uniqueness) and
   *   retries with a new 4-digit number on collision / unique-constraint
   *   conflict (e.g. concurrent registrations).
   */
  async ensureVetCode(user: User): Promise<User> {
    if (user.role !== UserRole.VETERINARIAN || user.vet_code) {
      return user;
    }

    const MAX_VET_CODE_ATTEMPTS = 25;

    for (let attempt = 0; attempt < MAX_VET_CODE_ATTEMPTS; attempt++) {
      const candidate = generateVetCode(user.name);

      // Check the database before saving.
      const existing = await this.userRepository.findOne({
        where: { vet_code: candidate },
        select: { user_id: true },
      });

      if (existing) {
        continue; // collision -> generate another 4-digit number
      }

      user.vet_code = candidate;

      try {
        await this.userRepository.save(user);
        return user;
      } catch (error) {
        // Handle a database unique-constraint conflict safely: another
        // request may have saved the same code in the meantime.
        if (this.isUniqueViolation(error)) {
          continue;
        }
        throw error;
      }
    }

    throw new Error('Could not generate a unique vet code. Please try again.');
  }

  /**
   * Detects PostgreSQL unique-constraint violations (SQLSTATE 23505).
   */
  private isUniqueViolation(error: unknown): boolean {
    if (error instanceof QueryFailedError) {
      const driverError = error.driverError as { code?: string };
      return driverError?.code === '23505' || (error as any).code === '23505';
    }
    return (error as { code?: string })?.code === '23505';
  }

}
