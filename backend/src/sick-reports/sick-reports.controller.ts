import { Controller, Get, Post, Body, Patch, Param, Delete, UseGuards, Request } from '@nestjs/common';
import { JwtAuthGuard } from 'src/auth/jwt-auth.guard';
import { SickReportsService } from './sick-reports.service';
import { CreateSickReportDto } from './dto/create-sick-report.dto';
import { UpdateSickReportDto } from './dto/update-sick-report.dto';


@Controller('sick-reports')
@UseGuards(JwtAuthGuard)
export class SickReportsController {
  constructor(private readonly sickReportsService: SickReportsService) {}

  @Post()
  async create(@Request() req, @Body() createSickReportDto: CreateSickReportDto) {
    try {
      return await this.sickReportsService.create(createSickReportDto, req.user.user_id);
    } catch (error) {
      console.error('Error creating sick report:', error);
      console.error('DTO:', createSickReportDto);
      console.error('User ID:', req.user.user_id);
      throw error;
    }
  }

  @Get()
  findAll() {
    return this.sickReportsService.findAll();
  }

  @Get('my-reports')
  findMyReports(@Request() req) {
    return this.sickReportsService.findByFarmer(req.user.user_id);
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.sickReportsService.findOne(+id);
  }

  @Patch(':id')
  update(@Param('id') id: string, @Body() updateSickReportDto: UpdateSickReportDto) {
    return this.sickReportsService.update(+id, updateSickReportDto);
  }

  @Delete(':id')
  remove(@Param('id') id: string) {
    return this.sickReportsService.remove(+id);
  }
}
