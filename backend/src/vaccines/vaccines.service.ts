import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';

import { Vaccine } from './entities/vaccine.entity';
import { CreateVaccineDto } from './dto/create-vaccine.dto';
import { UpdateVaccineDto } from './dto/update-vaccine.dto';

@Injectable()
export class VaccinesService {
  constructor(
    @InjectRepository(Vaccine)
    private vaccineRepository: Repository<Vaccine>,
  ) {}

  // Create Vaccine
  async create(createVaccineDto: CreateVaccineDto) {
    const vaccine = this.vaccineRepository.create(createVaccineDto);

    return await this.vaccineRepository.save(vaccine);
  }

  // Get All Vaccines
  async findAll() {
    return await this.vaccineRepository.find();
  }

  // Get One Vaccine
  async findOne(id: number) {
    const vaccine = await this.vaccineRepository.findOne({
      where: {
        vaccine_id: id,
      },
    });

    if (!vaccine) {
      throw new NotFoundException('Vaccine not found');
    }

    return vaccine;
  }

  // Update Vaccine
  async update(
    id: number,
    updateVaccineDto: UpdateVaccineDto,
  ) {
    const vaccine = await this.findOne(id);

    Object.assign(vaccine, updateVaccineDto);

    return await this.vaccineRepository.save(vaccine);
  }

  // Delete Vaccine
  async remove(id: number) {
    const vaccine = await this.findOne(id);

    await this.vaccineRepository.remove(vaccine);

    return {
      message: 'Vaccine deleted successfully',
    };
  }
}