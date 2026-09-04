import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { In, Repository } from 'typeorm';
import { Vaccination, VaccinationStatus } from '../vaccinations/entities/vaccination.entity';
import { Flock } from '../flocks/entities/flock.entity';
import { User, UserRole } from '../users/entities/user.entity';
import { VetFarmerConnection, ConnectionStatus } from '../users/entities/vet-farmer-connection.entity';
import { ReportStatus, SickReport } from '../sick-reports/entities/sick-report.entity';

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

    @InjectRepository(SickReport)
    private sickReportRepository: Repository<SickReport>,
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

    // Get all accepted connections for this vet
    const connections = await this.connectionRepository.find({
      where: {
        vetId: vet.user_id,
        status: ConnectionStatus.ACCEPTED,
      },
      relations: {
        farmer: true,
      },
    });

    // Get all flocks from connected farmers
    const farmerIds = connections.map(conn => conn.farmerId);
    const flocks = farmerIds.length > 0 ? await this.flockRepository
      .createQueryBuilder('flock')
      .where('flock.farmer_id IN (:...farmerIds)', { farmerIds })
      .leftJoinAndSelect('flock.farmer', 'farmer')
      .getMany() : [];

    // Get all vaccinations for these flocks administered by this vet
    const flockIds = flocks.map(f => f.flock_id);
    const vaccinations = flockIds.length > 0 ? await this.vaccinationRepository.find({
      where: {
        flock: In(flockIds),
        administered_by: {
          user_id: vet.user_id,
        },
      },
      relations: {
        flock: true,
        vaccine: true,
      },
      order: {
        date_given: 'DESC',
      },
    }) : [];

    // Get sick reports for these flocks
    const sickReports = flockIds.length > 0 ? await this.sickReportRepository.find({
      where: {
        flockId: In(flockIds),
      },
      relations: {
        flock: true,
      },
      order: {
        created_at: 'DESC',
      },
    }) : [];

    // Calculate statistics
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    // Summary cards
    const connectedFarmers = connections.length;
    const totalFlocks = flocks.length;
    const newSickReports = sickReports.filter(
      sr => sr.status === ReportStatus.PENDING,
    ).length;

    const overdueVaccinations = vaccinations.filter(v => {
      if (v.status === VaccinationStatus.COMPLETED) return false;
      if (!v.next_due_date) return false;
      const nextDue = new Date(v.next_due_date);
      nextDue.setHours(0, 0, 0, 0);
      return nextDue < today;
    }).length;

    // Build connected farmers list with their flocks
    const farmersList = connections.map(connection => {
      const farmer = connection.farmer;
      const farmerFlocks = flocks.filter(f => f.farmer?.user_id === farmer.user_id);
      
      // Get all vaccinations for this farmer's flocks
      const farmerFlockIds = farmerFlocks.map(f => f.flock_id);
      const farmerVaccinations = vaccinations.filter(v => farmerFlockIds.includes(v.flock.flock_id));
      const latestVaccination = farmerVaccinations[0];
      
      // Get sick reports for this farmer's flocks
      const farmerSickReports = sickReports.filter(sr => farmerFlockIds.includes(sr.flockId));
      const activeSickReports = farmerSickReports.filter(sr => 
        sr.status !== 'resolved' && sr.status !== 'reviewed'
      ).length;

      // Determine status
      let status = 'healthy';
      let statusText = 'HEALTHY';
      
      if (activeSickReports > 0) {
        status = 'sick';
        statusText = `${activeSickReports} SICK REPORT${activeSickReports > 1 ? 'S' : ''}`;
      } else if (latestVaccination) {
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
          } else if (diffDays <= 7) {
            status = 'due_soon';
            statusText = `${diffDays} VACCINATION${diffDays > 1 ? 'S' : ''} DUE`;
          }
        }
      }

      const totalBirds = farmerFlocks.reduce((sum, flock) => sum + flock.bird_count, 0);
      
      // Get farm names (flock batch names)
      const farmNames = farmerFlocks.map(f => f.batch_name).join(', ');

      return {
        farmerId: farmer.user_id,
        name: farmer.name,
        farmName: farmNames,
        location: `${farmer.village || ''}, ${farmer.province || ''}`,
        status,
        statusText,
        flockCount: farmerFlocks.length,
        totalBirds,
        lastVaccination: latestVaccination ? {
          date: latestVaccination.date_given,
          vaccine: latestVaccination.vaccine.name_en,
        } : null,
      };
    });

    // Sort by priority (sick first, then overdue, then due soon, then healthy)
    const priorityOrder = { 'sick': 0, 'overdue': 1, 'due_soon': 2, 'healthy': 3 };
    farmersList.sort((a, b) => priorityOrder[a.status] - priorityOrder[b.status]);

    return {
      connectedFarmers,
      totalFlocks,
      newSickReports,
      overdueVaccinations,
      farmers: farmersList,
    };
  }
}