import { Injectable, NotFoundException, ConflictException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import * as bcrypt from 'bcrypt';
import { randomUUID } from 'crypto';

import { User, UserRole } from './entities/user.entity';
import { VetFarmerConnection, ConnectionStatus } from './entities/vet-farmer-connection.entity';
import { CreateUserDto } from './dto/create-user.dto';
import { UpdateUserDto } from './dto/update-user.dto';
import { ConnectVetDto } from './dto/connect-vet.dto';

@Injectable()
export class UsersService {

  constructor(
    @InjectRepository(User)
    private readonly userRepository: Repository<User>,

    @InjectRepository(VetFarmerConnection)
    private readonly connectionRepository: Repository<VetFarmerConnection>,
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

    return user;
  }

  async updateProfileImage(phone: string, profileImageUrl: string) {
    const user = await this.userRepository.findOne({ where: { phone } });
    if (!user) {
      throw new Error('User not found');
    }

    user.profile_image_url = profileImageUrl;
    return await this.userRepository.save(user);
  }

  async connectToVet(farmerId: number, connectVetDto: ConnectVetDto) {
    const { vetShareCode } = connectVetDto;

    // Find vet by share code
    const vet = await this.userRepository.findOne({
      where: {
        share_code: vetShareCode,
        role: UserRole.VETERINARIAN,
      },
    });

    if (!vet) {
      throw new NotFoundException('Veterinarian not found with this share code');
    }

    // Check if connection already exists
    const existingConnection = await this.connectionRepository.findOne({
      where: {
        vetId: vet.user_id,
        farmerId: farmerId,
      },
    });

    if (existingConnection) {
      throw new ConflictException('Connection already exists with this veterinarian');
    }

    // Create new connection with ACCEPTED status (no vet approval needed)
    const connection = this.connectionRepository.create({
      vetId: vet.user_id,
      farmerId: farmerId,
      status: ConnectionStatus.ACCEPTED,
    });

    return await this.connectionRepository.save(connection);
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
      status: conn.status,
    }));
  }

}
