import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { In, Repository } from 'typeorm';
import { Vaccination, VaccinationStatus } from '../vaccinations/entities/vaccination.entity';
import { Flock } from '../flocks/entities/flock.entity';
import { User, UserRole } from '../users/entities/user.entity';
import { VetFarmerConnection, ConnectionStatus } from '../users/entities/vet-farmer-connection.entity';
import { SickReport, ReportStatus } from '../sick-reports/entities/sick-report.entity';

@Injectable()
export class FarmerDetailService {
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
   * Get detailed information about a specific farmer/farm
   * @param vetPhone - The phone number of the logged-in vet
   * @param farmerId - The ID of the farmer to get details for
   */
  async getFarmerDetail(vetPhone: string, farmerId: number) {
    // Get vet user
    const vet = await this.userRepository.findOne({
      where: { phone: vetPhone, role: UserRole.VETERINARIAN },
    });

    if (!vet) {
      throw new Error('Veterinarian not found');
    }

    // Verify connection exists
    const connection = await this.connectionRepository.findOne({
      where: {
        vetId: vet.user_id,
        farmerId: farmerId,
        status: ConnectionStatus.ACCEPTED,
      },
    });

    if (!connection) {
      throw new Error('You are not connected to this farmer');
    }

    // Get farmer details
    const farmer = await this.userRepository.findOne({
      where: { user_id: farmerId },
    });

    if (!farmer) {
      throw new Error('Farmer not found');
    }

    // Get all flocks for this farmer
    const flocks = await this.flockRepository.find({
      where: { farmer: { user_id: farmer.user_id } },
      order: { created_at: 'DESC' },
    });

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

    // Get all sick reports for these flocks
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
    const totalChickens = flocks.reduce((sum, flock) => sum + flock.bird_count, 0);
    const totalFlocks = flocks.length;
    const activeSickReports = sickReports.filter(sr => 
      sr.status !== ReportStatus.RESOLVED && sr.status !== ReportStatus.REVIEWED
    ).length;

    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const vaccinationsDue = vaccinations.filter(v => {
      if (v.status === VaccinationStatus.COMPLETED) return false;
      if (!v.next_due_date) return false;
      const nextDue = new Date(v.next_due_date);
      nextDue.setHours(0, 0, 0, 0);
      return nextDue >= today;
    }).length;

    // Build flock data
    const flockData = flocks.map(flock => ({
      flockId: flock.flock_id,
      batchName: flock.batch_name,
      birdCount: flock.bird_count,
      breed: flock.breed,
      createdAt: flock.created_at,
    }));

    // Build vaccination data
    const vaccinationData = vaccinations.map(v => ({
      vaccinationId: v.vaccination_id,
      flockId: v.flock.flock_id,
      flockName: v.flock.batch_name,
      vaccineName: v.vaccine.name_en,
      dateGiven: v.date_given,
      nextDueDate: v.next_due_date,
      status: v.status,
    }));

    // Build sick report data
    const sickReportData = sickReports.map(sr => ({
      reportId: sr.report_id,
      flockId: sr.flockId,
      flockName: sr.flock?.batch_name || 'Unknown',
      reportType: sr.reportType,
      affectedCount: sr.affectedCount,
      symptoms: sr.symptoms,
      reportDate: sr.reportDate,
      status: sr.status,
      createdAt: sr.created_at,
    }));

    return {
      farmer: {
        farmerId: farmer.user_id,
        name: farmer.name,
        phone: farmer.phone,
        village: farmer.village,
        province: farmer.province,
      },
      farmName: flocks.length > 0 ? flocks[0].batch_name : `${farmer.name}'s Farm`,
      summary: {
        totalChickens,
        totalFlocks,
        activeSickReports,
        vaccinationsDue,
      },
      flocks: flockData,
      vaccinations: vaccinationData,
      sickReports: sickReportData,
    };
  }
}