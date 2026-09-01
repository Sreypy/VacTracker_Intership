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
import { Reminder } from 'src/reminders/entities/reminder.entity';
import { RemindersService } from 'src/reminders/reminders.service';
import { NotificationsService } from 'src/notifications/notifications.service';
import { CloudinaryService } from 'src/cloudinary/cloudinary.service';

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

    private readonly remindersService: RemindersService,
    private readonly notificationsService: NotificationsService,
    private readonly cloudinaryService: CloudinaryService, // add this

  ) {}

  // ===========================
  // Create Vaccination
  // ===========================
  async create(
    createVaccinationDto: CreateVaccinationDto,
    phone: string,
    photo?: Express.Multer.File,
  ) {
    // Find logged-in user
    const user = await this.userRepository.findOne({
      where: { phone },
    });

    if (!user) {
      throw new NotFoundException('User not found');
    }

    // Find flock with farmer relation loaded
    const flock = await this.flockRepository.findOne({
      where: {
        flock_id: createVaccinationDto.flock_id,
      },
      relations: {
        farmer: true,
      },
    });

    if (!flock) {
      throw new NotFoundException('Flock not found');
    }

    // Verify the flock belongs to the logged-in user
    if (flock.farmer?.user_id !== user.user_id) {
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

    // Guard against duplicate submissions
    const existingVaccination = await this.vaccinationRepository.findOne({
      where: {
        flock: { flock_id: createVaccinationDto.flock_id },
        vaccine: { vaccine_id: createVaccinationDto.vaccine_id },
        date_given: new Date(createVaccinationDto.date_given),
      },
    });

    if (existingVaccination) {
      return existingVaccination;
    }

    // Determine next due date
    let nextDueDate: Date | null = null;

    if (createVaccinationDto.next_due_date) {
      nextDueDate = new Date(createVaccinationDto.next_due_date);
    } else if (vaccine.interval_days && vaccine.interval_days > 0) {
      nextDueDate = new Date(createVaccinationDto.date_given);
      nextDueDate.setDate(nextDueDate.getDate() + vaccine.interval_days);
    }

    const status = this.calculateVaccinationStatus(nextDueDate);

    // Upload photo to Cloudinary if provided
    let photoUrl: string | undefined = createVaccinationDto.photo_url;
    if (photo) {
      const result = await this.cloudinaryService.uploadImage(
        photo,
        'vactracker/vaccinations',
      );
      photoUrl = result.secure_url;
    }

    // Create vaccination
    const vaccination = this.vaccinationRepository.create({
      flock,
      vaccine,
      administered_by: user,
      date_given: new Date(createVaccinationDto.date_given),
      next_due_date: nextDueDate,
      status,
      photo_url: photoUrl,
    });

    const savedVaccination = await this.vaccinationRepository.save(vaccination);

    await this.remindersService.markRemindersCompleted(
      user.user_id,
      createVaccinationDto.flock_id,
    );

    await this.notificationsService.markOverdueNotificationsRead(
      user.user_id,
      createVaccinationDto.flock_id,
    );

    if (savedVaccination.next_due_date) {
      await this.remindersService.createReminder(savedVaccination);
    }

    return savedVaccination;
  }

  // ===========================
  // Calculate Vaccination Status
  // ===========================
  private calculateVaccinationStatus(nextDueDate: Date | null): VaccinationStatus {
    if (!nextDueDate) {
      return VaccinationStatus.ON_TIME;
    }

    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const dueDate = new Date(nextDueDate);
    dueDate.setHours(0, 0, 0, 0);

    const diffTime = dueDate.getTime() - today.getTime();
    const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));

    if (diffDays < 0) {
      return VaccinationStatus.OVERDUE;
    } else if (diffDays <= 3) {
      // Within 3 days = DUE_SOON
      return VaccinationStatus.DUE_SOON;
    }

    return VaccinationStatus.ON_TIME;
  }

  // ===========================
  // Get All Vaccinations for the logged-in user
  // ===========================
  async findAllForUser(phone: string) {
    const user = await this.userRepository.findOne({
      where: { phone },
    });

    if (!user) {
      throw new NotFoundException('User not found');
    }

    return await this.vaccinationRepository.find({
      where: {
        flock: {
          farmer: {
            user_id: user.user_id,
          },
        },
      },
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
  // Get Vaccination by ID (with ownership check)
  // ===========================
  async findOne(id: number, phone: string) {
    const user = await this.userRepository.findOne({
      where: { phone },
    });

    if (!user) {
      throw new NotFoundException('User not found');
    }

    const vaccination =
      await this.vaccinationRepository.findOne({
        where: {
          vaccination_id: id,
        },
        relations: {
          flock: {
            farmer: true,
          },
          vaccine: true,
          administered_by: true,
        },
      });

    if (!vaccination) {
      throw new NotFoundException(
        'Vaccination not found',
      );
    }

    // Ownership check: the vaccination's flock must belong to the logged-in user
    if (vaccination.flock?.farmer?.user_id !== user.user_id) {
      // Return 404 (not 403) to avoid confirming record existence to an attacker
      throw new NotFoundException(
        'Vaccination not found',
      );
    }

    return vaccination;
  }

  // ===========================
  // Get Vaccinations by Flock (with ownership check)
  // ===========================
  async findByFlock(flockId: number, phone: string) {
    const user = await this.userRepository.findOne({
      where: { phone },
    });

    if (!user) {
      throw new NotFoundException('User not found');
    }

    // Verify the flock belongs to the logged-in user
    const flock = await this.flockRepository.findOne({
      where: {
        flock_id: flockId,
        farmer: {
          user_id: user.user_id,
        },
      },
    });

    if (!flock) {
      throw new NotFoundException('Flock not found');
    }

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
  // Update Vaccination (with ownership check)
  // ===========================
  async update(
    id: number,
    updateVaccinationDto: UpdateVaccinationDto,
    phone: string,
  ) {
    const vaccination = await this.findOne(id, phone);

    Object.assign(
      vaccination,
      updateVaccinationDto,
    );

    return await this.vaccinationRepository.save(
      vaccination,
    );
  }

  // ===========================
  // Delete Vaccination (with ownership check)
  // ===========================
  async remove(id: number, phone: string) {
    const vaccination = await this.findOne(id, phone);

    await this.vaccinationRepository.remove(
      vaccination,
    );

    return {
      message:
        'Vaccination deleted successfully',
    };
  }
}