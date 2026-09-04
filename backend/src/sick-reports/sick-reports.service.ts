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
        flock: {
          farmer: true,
        },
        reporter: true,
        veterinarian: true,
      },
    });

    if (!sickReport) {
      throw new NotFoundException('Sick report not found');
    }

    if (role === UserRole.VETERINARIAN) {
      const connection = await this.connectionRepository.findOne({
        where: {
          vetId: userId,
          farmerId: sickReport.reportedBy,
          status: ConnectionStatus.ACCEPTED,
        },
      });

      if (!connection) {
        throw new NotFoundException('Sick report not found');
      }
    } else {
      const flockOwnerMatches = sickReport.flock?.farmer?.user_id === userId;
      const reporterMatches = sickReport.reportedBy === userId;
      if (!reporterMatches && !flockOwnerMatches) {
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
    const sickReport = await this.sickReportRepository.findOne({
      where: { report_id: id },
      relations: {
        flock: {
          farmer: true,
        },
        reporter: true,
        veterinarian: true,
      },
    });

    if (!sickReport) {
      throw new NotFoundException('Sick report not found');
    }

    const isFarmer = role === UserRole.FARMER;
    const isVeterinarian = role === UserRole.VETERINARIAN;
    const isOwner = sickReport.flock?.farmer?.user_id === userId;

    if (!isFarmer && !isVeterinarian) {
      throw new ForbiddenException('Unsupported user role');
    }

    if (isFarmer && !isOwner) {
      throw new ForbiddenException('You do not own this sick report');
    }

    const hadVetResponse = sickReport.respondedAt != null;
    const hasVetResponseFields =
      updateSickReportDto.vetDiagnosis != null ||
      updateSickReportDto.vetAdvice != null ||
      updateSickReportDto.vetNotes != null ||
      updateSickReportDto.recommendedAction != null ||
      updateSickReportDto.followUpDate != null;

    const requestedStatus =
      updateSickReportDto.status == null
        ? null
        : String(updateSickReportDto.status).toLowerCase();

    if (isFarmer) {
      if (hasVetResponseFields) {
        throw new ForbiddenException('Farmers cannot update veterinarian responses');
      }

      if (requestedStatus != null) {
        if (requestedStatus === ReportStatus.RESOLVED) {
          if (sickReport.status !== ReportStatus.REVIEWED || !sickReport.respondedAt) {
            throw new BadRequestException(
              'A veterinarian response is required before resolving the report',
            );
          }
          sickReport.status = ReportStatus.RESOLVED;
          sickReport.farmerFollowUpMessage = null;
          sickReport.farmerFollowUpAt = null;
        } else if (requestedStatus === ReportStatus.PENDING) {
          if (!sickReport.respondedAt) {
            throw new BadRequestException(
              'A veterinarian response is required before reopening the report for follow-up',
            );
          }
          sickReport.status = ReportStatus.PENDING;
        } else {
          throw new BadRequestException('Invalid status transition for farmer update');
        }
      }
    } else {
      if (hasVetResponseFields) {
        if (!hadVetResponse && !updateSickReportDto.vetDiagnosis?.trim()) {
          throw new BadRequestException('A veterinarian diagnosis is required');
        }

        sickReport.vetId = userId;
        sickReport.respondedAt ??= new Date();
        sickReport.status = updateSickReportDto.status ?? ReportStatus.REVIEWED;
      }
    }

    Object.assign(sickReport, updateSickReportDto);
    const saved = await this.sickReportRepository.save(sickReport);

    if (!isFarmer && hasVetResponseFields && !hadVetResponse) {
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

  async resolveReport(id: number, userId: number, role: string) {
    const sickReport = await this.findOne(id, userId, role);

    if (role === UserRole.VETERINARIAN) {
      throw new ForbiddenException('Only the farmer who owns the report can resolve it');
    }

    if (sickReport.reportedBy !== userId) {
      throw new ForbiddenException('You do not own this sick report');
    }

    if (!sickReport.respondedAt) {
      throw new BadRequestException('A veterinarian response is required before resolving the report');
    }

    sickReport.status = ReportStatus.RESOLVED;
    sickReport.farmerFollowUpMessage = null;
    sickReport.farmerFollowUpAt = null;

    const saved = await this.sickReportRepository.save(sickReport);

    return saved;
  }

  async sendFollowUp(id: number, userId: number, role: string, message: string) {
    const sickReport = await this.findOne(id, userId, role);

    if (role === UserRole.VETERINARIAN) {
      throw new ForbiddenException('Only the farmer who owns the report can send a follow-up');
    }

    if (sickReport.reportedBy !== userId) {
      throw new ForbiddenException('You do not own this sick report');
    }

    const cleaned = message?.trim();
    if (!cleaned) {
      throw new BadRequestException('Follow-up message is required');
    }

    sickReport.farmerFollowUpMessage = cleaned;
    sickReport.farmerFollowUpAt = new Date();
    sickReport.status = ReportStatus.PENDING;

    const saved = await this.sickReportRepository.save(sickReport);

    return saved;
  }

  async remove(id: number, userId: number, role: string) {
    // findOne performs the ownership check
    const sickReport = await this.findOne(id, userId, role);
    return await this.sickReportRepository.remove(sickReport);
  }
}
