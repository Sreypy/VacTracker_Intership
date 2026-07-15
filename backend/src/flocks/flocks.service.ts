import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';

import { Flock } from './entities/flock.entity';
import { User } from '../users/entities/user.entity';
import { CreateFlockDto } from './dto/create-flock.dto';
import { UpdateFlockDto } from './dto/update-flock.dto';

@Injectable()
export class FlocksService {
  constructor(
    @InjectRepository(Flock)
    private readonly flockRepository: Repository<Flock>,

    @InjectRepository(User)
    private readonly userRepository: Repository<User>,
  ) {}

  async create(createFlockDto: CreateFlockDto, phone: string) {
    const farmer = await this.userRepository.findOne({
      where: { phone },
    });

    if (!farmer) {
      throw new NotFoundException('Farmer not found');
    }

    const flock = this.flockRepository.create({
      ...createFlockDto,
      farmer,
    });

    return await this.flockRepository.save(flock);
  }

  async findAll(phone: string) {
  const farmer = await this.userRepository.findOne({
    where: { phone },
  });

  if (!farmer) {
    throw new NotFoundException('Farmer not found');
  }

  return this.flockRepository.find({
    where: {
      farmer: {
        user_id: farmer.user_id,
      },
    },
    relations: {
    farmer: true,
    },  
    });
}

async findOne(id: number, phone: string) {
  const flock = await this.flockRepository.findOne({
    where: {
      flock_id: id,
      farmer: {
        phone,
      },
    },
    relations: {
      farmer: true,
    },
  });

  if (!flock) {
    throw new NotFoundException('Flock not found');
  }

  return flock;
}

async update(
  id: number,
  updateFlockDto: UpdateFlockDto,
  phone: string,
) {

  const flock = await this.flockRepository.findOne({
    where: {
      flock_id: id,
      farmer: {
        phone,
      },
    },
  });


  if (!flock) {
    throw new NotFoundException('Flock not found');
  }


  Object.assign(flock, updateFlockDto);


  return this.flockRepository.save(flock);
}

async remove(id: number, phone: string) {

  const flock = await this.flockRepository.findOne({
    where: {
      flock_id: id,
      farmer: {
        phone,
      },
    },
  });


  if (!flock) {
    throw new NotFoundException('Flock not found');
  }


  await this.flockRepository.remove(flock);


  return {
    message: 'Flock deleted successfully',
  };
}


}