import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { SickReport } from './entities/sick-report.entity';
import { CreateSickReportDto } from './dto/create-sick-report.dto';
import { UpdateSickReportDto } from './dto/update-sick-report.dto';


@Injectable()
export class SickReportsService {
  constructor(
    @InjectRepository(SickReport)
    private sickReportRepository: Repository<SickReport>,
  ) {}

  async create(createSickReportDto: CreateSickReportDto, userId: number) {
    const reportDate = createSickReportDto.reportDate instanceof Date 
      ? createSickReportDto.reportDate 
      : new Date(createSickReportDto.reportDate);
    
    const sickReport = this.sickReportRepository.create({
      ...createSickReportDto,
      reportedBy: userId,
      reportDate: reportDate.toISOString().split('T')[0],
    });
    return await this.sickReportRepository.save(sickReport);
  }

  async findAll() {
    return await this.sickReportRepository.find({
      relations: {
        flock: true,
        reporter: true,
      },
    });
  }

  async findOne(id: number) {
    const sickReport = await this.sickReportRepository.findOne({
      where: { report_id: id },
      relations: {
        flock: true,
        reporter: true,
      },
    });
    if (!sickReport) {
      throw new NotFoundException('Sick report not found');
    }
    return sickReport;
  }

  async findByFarmer(farmerId: number) {
    return await this.sickReportRepository.find({
      where: { reportedBy: farmerId },
      relations: {
        flock: true,
        reporter: true,
      },
    });
  }

  async update(id: number, updateSickReportDto: UpdateSickReportDto) {
    const sickReport = await this.findOne(id);
    Object.assign(sickReport, updateSickReportDto);
    return await this.sickReportRepository.save(sickReport);
  }

  async remove(id: number) {
    const sickReport = await this.findOne(id);
    return await this.sickReportRepository.remove(sickReport);
  }
}
