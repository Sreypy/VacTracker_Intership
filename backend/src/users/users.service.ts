import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';

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
    const user = this.userRepository.create(createUserDto);
    return await this.userRepository.save(user);
  }

  async findAll() {
    return await this.userRepository.find();
  }

  async update(id: number, updateUserDto: UpdateUserDto) {
  await this.userRepository.update(id, updateUserDto);

    return this.userRepository.findOne({
      where: {
        user_id: id,
      },
    });
  }

  async getProfile(phone: string) {
  return this.userRepository.findOne({
    where: { phone },
  });
}
}