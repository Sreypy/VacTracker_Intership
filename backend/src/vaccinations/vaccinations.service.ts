import {
  Injectable,
  NotFoundException,
} from '@nestjs/common';

import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';

import { Vaccination, VaccinationStatus } from './entities/vaccination.entity';
import { Flock } from '../flocks/entities/flock.entity';
import { Vaccine } from '../vaccines/entities/vaccine.entity';
import { User } from '../users/entities/user.entity';

import { CreateVaccinationDto } from './dto/create-vaccination.dto';
import { UpdateVaccinationDto } from './dto/update-vaccination.dto';

@Injectable()
export class VaccinationsService {
  constructor(
    @InjectRepository(Vaccination)
    private vaccinationRepository: Repository<Vaccination>,

    @InjectRepository(Flock)
    private flockRepository: Repository<Flock>,

    @InjectRepository(Vaccine)
    private vaccineRepository: Repository<Vaccine>,

    @InjectRepository(User)
    private userRepository: Repository<User>,
  ) {}

  // ===========================
  // Create Vaccination
  // ===========================
  async create(
    createVaccinationDto: CreateVaccinationDto,
    phone: string,
  ) {
    // Find logged-in user
    const user = await this.userRepository.findOne({
      where: { phone },
    });

    if (!user) {
      throw new NotFoundException('User not found');
    }

    // Find flock
    const flock = await this.flockRepository.findOne({
      where: {
        flock_id: createVaccinationDto.flock_id,
      },
    });

    if (!flock) {
      throw new NotFoundException('Flock not found');
    }

    // Find vaccine
    const vaccine = await this.vaccineRepository.findOne({
      where: {
        vaccine_id: createVaccinationDto.vaccine_id,
      },
    });

    if (!vaccine) {
      throw new NotFoundException('Vaccine not found');
    }

    // Calculate next due date
    let nextDueDate: Date | null = null;

    if (vaccine.interval_days > 0) {
      nextDueDate = new Date(createVaccinationDto.date_given);

      nextDueDate.setDate(
        nextDueDate.getDate() + vaccine.interval_days,
      );
    }

    // Create vaccination
    const vaccination = this.vaccinationRepository.create({
      flock,
      vaccine,
      administered_by: user,
      date_given: new Date(createVaccinationDto.date_given),
      next_due_date: nextDueDate,
      status: VaccinationStatus.ON_TIME,
      photo_url: createVaccinationDto.photo_url,
    });

    return await this.vaccinationRepository.save(
      vaccination,
    );
  }

  // ===========================
  // Get All Vaccinations
  // ===========================
  async findAll() {
    return await this.vaccinationRepository.find({
      relations: {
        flock: true,
        vaccine: true,
        administered_by: true,
      },
      order: {
        created_at: 'DESC',
      },
    });
  }

  // ===========================
  // Get Vaccination by ID
  // ===========================
  async findOne(id: number) {
    const vaccination =
      await this.vaccinationRepository.findOne({
        where: {
          vaccination_id: id,
        },
        relations: {
          flock: true,
          vaccine: true,
          administered_by: true,
        },
      });

    if (!vaccination) {
      throw new NotFoundException(
        'Vaccination not found',
      );
    }

    return vaccination;
  }

  // ===========================
  // Get Vaccinations by Flock
  // ===========================
  async findByFlock(flockId: number) {
    return await this.vaccinationRepository.find({
      where: {
        flock: {
          flock_id: flockId,
        },
      },
      relations: {
        flock: true,
        vaccine: true,
        administered_by: true,
      },
      order: {
        date_given: 'DESC',
      },
    });
  }

  // ===========================
  // Update Vaccination
  // ===========================
  async update(
    id: number,
    updateVaccinationDto: UpdateVaccinationDto,
  ) {
    const vaccination = await this.findOne(id);

    Object.assign(
      vaccination,
      updateVaccinationDto,
    );

    return await this.vaccinationRepository.save(
      vaccination,
    );
  }

  // ===========================
  // Delete Vaccination
  // ===========================
  async remove(id: number) {
    const vaccination = await this.findOne(id);

    await this.vaccinationRepository.remove(
      vaccination,
    );

    return {
      message:
        'Vaccination deleted successfully',
    };
  }
}