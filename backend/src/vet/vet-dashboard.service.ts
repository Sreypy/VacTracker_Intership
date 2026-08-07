import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { In, Repository } from 'typeorm';
import { Vaccination, VaccinationStatus } from '../vaccinations/entities/vaccination.entity';
import { Flock } from '../flocks/entities/flock.entity';
import { User, UserRole } from '../users/entities/user.entity';
import { VetFarmerConnection, ConnectionStatus } from '../users/entities/vet-farmer-connection.entity';

@Injectable()
export class VetDashboardService {
  constructor(
    @InjectRepository(Vaccination)
    private vaccinationRepository: Repository<Vaccination>,

    @InjectRepository(Flock)
    private flockRepository: Repository<Flock>,

    @InjectRepository(User)
    private userRepository: Repository<User>,

    @InjectRepository(VetFarmerConnection)
    private connectionRepository: Repository<VetFarmerConnection>,
  ) {}

  /**
   * Get dashboard statistics for a veterinarian
   * @param vetPhone - The phone number of the logged-in vet
   */
  async getDashboardStats(vetPhone: string) {
    // Get vet user
    const vet = await this.userRepository.findOne({
      where: { phone: vetPhone, role: UserRole.VETERINARIAN },
    });

    if (!vet) {
      throw new Error('Veterinarian not found');
    }

    // Get all vaccinations administered by this vet
    const vaccinations = await this.vaccinationRepository.find({
      where: {
        administered_by: { user_id: vet.user_id },
      },
      relations: {
        flock: true,
        vaccine: true,
      },
      order: {
        date_given: 'DESC',
      },
    });

    // Get unique flocks managed by this vet
    const flockIds = [...new Set(vaccinations.map(v => v.flock.flock_id))];
    
    const flocks = await this.flockRepository.find({
      where: {
        flock_id: In(flockIds),
      },
      relations: {
        farmer: true,
      },
    });

    // Calculate statistics
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    const totalClients = flocks.length;

    // Count overdue vaccinations (next_due_date < today and status not completed)
    const overdueCount = vaccinations.filter(v => {
      if (v.status === VaccinationStatus.COMPLETED) return false;
      if (!v.next_due_date) return false;
      const nextDue = new Date(v.next_due_date);
      nextDue.setHours(0, 0, 0, 0);
      return nextDue < today;
    }).length;

    // Count due today (next_due_date === today)
    const dueTodayCount = vaccinations.filter(v => {
      if (!v.next_due_date) return false;
      const nextDue = new Date(v.next_due_date);
      nextDue.setHours(0, 0, 0, 0);
      return nextDue.getTime() === today.getTime();
    }).length;

    // Get accepted or pending farmer connections for the vet
    const connections = await this.connectionRepository.find({
      where: {
        vetId: vet.user_id,
        status: In([ConnectionStatus.PENDING, ConnectionStatus.ACCEPTED]),
      },
      relations: {
        farmer: true,
      },
      order: {
        created_at: 'DESC',
      },
    });

    const connectedFarmers = connections.map((connection) => ({
      farmerId: connection.farmer.user_id,
      name: connection.farmer.name,
      phone: connection.farmer.phone,
      village: connection.farmer.village,
      province: connection.farmer.province,
      status: connection.status,
    }));

    // Get client directory with vaccination status
    const clientDirectory = flocks.map(flock => {
      const flockVaccinations = vaccinations.filter(v => v.flock.flock_id === flock.flock_id);
      const latestVaccination = flockVaccinations[0];
      
      let status = 'compliant';
      let statusText = 'COMPLIANT';
      
      if (latestVaccination) {
        if (latestVaccination.status === VaccinationStatus.OVERDUE) {
          status = 'overdue';
          statusText = 'OVERDUE';
        } else if (latestVaccination.next_due_date) {
          const nextDue = new Date(latestVaccination.next_due_date);
          nextDue.setHours(0, 0, 0, 0);
          const diffTime = nextDue.getTime() - today.getTime();
          const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
          
          if (diffDays <= 0) {
            status = 'overdue';
            statusText = 'OVERDUE';
          } else if (diffDays <= 1) {
            status = 'due_today';
            statusText = 'DUE TODAY';
          }
        }
      }

      return {
        flockId: flock.flock_id,
        name: flock.batch_name,
        location: flock.farmer ? `${flock.farmer.village || ''}, ${flock.farmer.province || ''}` : 'Unknown',
        status,
        statusText,
        birdCount: flock.bird_count,
        lastVaccination: latestVaccination ? {
          date: latestVaccination.date_given,
          vaccine: latestVaccination.vaccine.name_en,
        } : null,
      };
    });

    // Sort by priority (overdue first, then due today, then compliant)
    const priorityOrder = { 'overdue': 0, 'due_today': 1, 'compliant': 2 };
    clientDirectory.sort((a, b) => priorityOrder[a.status] - priorityOrder[b.status]);

    return {
      totalClients,
      overdueCount,
      dueTodayCount,
      clients: clientDirectory,
      connectedFarmers,
    };
  }
}
