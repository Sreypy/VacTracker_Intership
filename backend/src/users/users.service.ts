import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import * as bcrypt from 'bcrypt';

import { User } from './entities/user.entity';
import { CreateUserDto } from './dto/create-user.dto';
import { UpdateUserDto } from './dto/update-user.dto';

@Injectable()
export class UsersService {

  constructor(
    @InjectRepository(User)
    private readonly userRepository: Repository<User>,
  ) {}

  async create(createUserDto: CreateUserDto) {

    const hashedPassword = await bcrypt.hash(
      createUserDto.password_hash || '',
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
    });

    return await this.userRepository.save(user);
  }
  
    async findAll() {
      return await this.userRepository.find();
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

      return this.userRepository.findOne({
        where: {
          phone,
        },
      });

    }

}