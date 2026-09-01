import { Controller, Get, Post, Body, Patch, Param, Delete, UseGuards, Request, UseInterceptors, UploadedFile } from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { JwtAuthGuard } from 'src/auth/jwt-auth.guard';
import { SickReportsService } from './sick-reports.service';
import { CreateSickReportDto } from './dto/create-sick-report.dto';
import { UpdateSickReportDto } from './dto/update-sick-report.dto';

@Controller('sick-reports')
@UseGuards(JwtAuthGuard)
export class SickReportsController {
  constructor(private readonly sickReportsService: SickReportsService) {}

  @Post()
  @UseInterceptors(FileInterceptor('photo'))
  async create(
    @Request() req,
    @Body() createSickReportDto: CreateSickReportDto,
    @UploadedFile() photo?: Express.Multer.File,
  ) {
    try {
      return await this.sickReportsService.create(
        createSickReportDto,
        req.user.user_id,
        photo,
      );
    } catch (error) {
      console.error('Error creating sick report:', error);
      console.error('DTO:', createSickReportDto);
      console.error('User ID:', req.user.user_id);
      throw error;
    }
  }

  @Get()
  findAll(@Request() req) {
    return this.sickReportsService.findAll(req.user.user_id, req.user.role);
  }

  @Get('my-reports')
  findMyReports(@Request() req) {
    return this.sickReportsService.findByFarmer(req.user.user_id);
  }

  @Get(':id')
  findOne(@Param('id') id: string, @Request() req) {
    return this.sickReportsService.findOne(+id, req.user.user_id, req.user.role);
  }

  @Patch(':id')
  update(
    @Param('id') id: string,
    @Body() updateSickReportDto: UpdateSickReportDto,
    @Request() req,
  ) {
    return this.sickReportsService.update(+id, updateSickReportDto, req.user.user_id, req.user.role);
  }

  @Delete(':id')
  remove(@Param('id') id: string, @Request() req) {
    return this.sickReportsService.remove(+id, req.user.user_id, req.user.role);
  }
}
