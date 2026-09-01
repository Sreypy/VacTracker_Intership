import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, In } from 'typeorm';
import { ReportStatus, SickReport } from './entities/sick-report.entity';
import { CreateSickReportDto } from './dto/create-sick-report.dto';
import { UpdateSickReportDto } from './dto/update-sick-report.dto';
import { NotificationsService } from '../notifications/notifications.service';
import { User, UserRole } from '../users/entities/user.entity';
import { VetFarmerConnection, ConnectionStatus } from '../users/entities/vet-farmer-connection.entity';
import { CloudinaryService } from 'src/cloudinary/cloudinary.service';

@Injectable()
export class SickReportsService {
  constructor(
    @InjectRepository(SickReport)
    private sickReportRepository: Repository<SickReport>,

    @InjectRepository(User)
    private userRepository: Repository<User>,

    @InjectRepository(VetFarmerConnection)
    private connectionRepository: Repository<VetFarmerConnection>,

    private readonly notificationsService: NotificationsService,
    private readonly cloudinaryService: CloudinaryService,
  ) {}

  async create(
    createSickReportDto: CreateSickReportDto,
    userId: number,
    photo?: Express.Multer.File,
  ) {
    const reportDate = createSickReportDto.reportDate instanceof Date
      ? createSickReportDto.reportDate
      : new Date(createSickReportDto.reportDate);

    // Upload photo to Cloudinary if provided
    let photoUrl: string | undefined = createSickReportDto.photoUrl;
    if (photo) {
      const result = await this.cloudinaryService.uploadImage(
        photo,
        'vactracker/sick-reports',
      );
      photoUrl = result.secure_url;
    }

    const sickReport = this.sickReportRepository.create({
      ...createSickReportDto,
      reportedBy: userId,
      reportDate: reportDate.toISOString().split('T')[0],
      photoUrl,
    });
    return await this.sickReportRepository.save(sickReport);
  }

  // Get all sick reports accessible to the logged-in user
  // - Farmers see only their own reports
  // - Vets see reports from connected farmers
  async findAll(userId: number, role: string) {
    if (role === UserRole.VETERINARIAN) {
      // Vet: get all connected farmer IDs
      const connections = await this.connectionRepository.find({
        where: {
          vetId: userId,
          status: ConnectionStatus.ACCEPTED,
        },
      });
      const farmerIds = connections.map((c) => c.farmerId);

      if (farmerIds.length === 0) {
        return [];
      }

      return await this.sickReportRepository.find({
        where: {
          reportedBy: In(farmerIds),
        },
        relations: {
          flock: true,
          reporter: true,
          veterinarian: true,
        },
        order: {
          created_at: 'DESC',
        },
      });
    }

    // Farmer: only their own reports
    return await this.sickReportRepository.find({
      where: { reportedBy: userId },
      relations: {
        flock: true,
        reporter: true,
        veterinarian: true,
      },
      order: {
        created_at: 'DESC',
      },
    });
  }

  // Get a single sick report with ownership verification
  async findOne(id: number, userId: number, role: string) {
    const sickReport = await this.sickReportRepository.findOne({
      where: { report_id: id },
      relations: {
        flock: true,
        reporter: true,
        veterinarian: true,
      },
    });

    if (!sickReport) {
      throw new NotFoundException('Sick report not found');
    }

    // Ownership check
    if (role === UserRole.VETERINARIAN) {
      // Vet: verify they are connected to the farmer who reported this
      const connection = await this.connectionRepository.findOne({
        where: {
          vetId: userId,
          farmerId: sickReport.reportedBy,
          status: ConnectionStatus.ACCEPTED,
        },
      });

      if (!connection) {
        // Return 404 (not 403) to avoid confirming record existence
        throw new NotFoundException('Sick report not found');
      }
    } else {
      // Farmer: can only see their own reports
      if (sickReport.reportedBy !== userId) {
        throw new NotFoundException('Sick report not found');
      }
    }

    return sickReport;
  }

  async findByFarmer(farmerId: number) {
    return await this.sickReportRepository.find({
      where: { reportedBy: farmerId },
      relations: {
        flock: true,
        reporter: true,
        veterinarian: true,
      },
    });
  }

  async update(
    id: number,
    updateSickReportDto: UpdateSickReportDto,
    userId: number,
    role: string,
  ) {
    const sickReport = await this.findOne(id, userId, role);
    const hadVetResponse = sickReport.respondedAt != null;
    const hasVetResponseFields =
      Object.prototype.hasOwnProperty.call(updateSickReportDto, 'vetDiagnosis') ||
      Object.prototype.hasOwnProperty.call(updateSickReportDto, 'vetAdvice') ||
      Object.prototype.hasOwnProperty.call(updateSickReportDto, 'vetNotes');

    const isFarmerChangingVetFields =
      role !== UserRole.VETERINARIAN &&
      (hasVetResponseFields ||
          updateSickReportDto.recommendedAction != null ||
          updateSickReportDto.followUpDate != null ||
          updateSickReportDto.status != null);
    if (isFarmerChangingVetFields) {
      throw new ForbiddenException('Farmers cannot update veterinarian responses');
    }

    if (hasVetResponseFields) {
      if (role !== UserRole.VETERINARIAN) {
        throw new ForbiddenException('Only veterinarians can respond to sick reports');
      }

      if (!hadVetResponse && !updateSickReportDto.vetDiagnosis?.trim()) {
        throw new BadRequestException('A veterinarian diagnosis is required');
      }

      sickReport.vetId = userId;
      sickReport.respondedAt ??= new Date();
      sickReport.status = updateSickReportDto.status ?? ReportStatus.REVIEWED;
    }

    Object.assign(sickReport, updateSickReportDto);
    const saved = await this.sickReportRepository.save(sickReport);

    // Notify once when a veterinarian creates the response. Subsequent edits
    // update the response without producing duplicate notifications.
    if (hasVetResponseFields && !hadVetResponse) {
      const farmerId = sickReport.reportedBy;
      await this.notificationsService.createVetResponseNotification({
        farmerId,
        reportId: sickReport.report_id,
        vetDiagnosis: updateSickReportDto.vetDiagnosis || '',
        flockName: sickReport.flock?.batch_name,
      });
    }

    return saved;
  }

  async remove(id: number, userId: number, role: string) {
    // findOne performs the ownership check
    const sickReport = await this.findOne(id, userId, role);
    return await this.sickReportRepository.remove(sickReport);
  }
}
