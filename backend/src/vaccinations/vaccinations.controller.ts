import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Patch,
  Post,
  Request,
  UseGuards,
} from '@nestjs/common';

import { VaccinationsService } from './vaccinations.service';
import { CreateVaccinationDto } from './dto/create-vaccination.dto';
import { UpdateVaccinationDto } from './dto/update-vaccination.dto';

import { JwtAuthGuard } from '../auth/jwt-auth.guard';

@Controller('vaccinations')
@UseGuards(JwtAuthGuard)
export class VaccinationsController {
  constructor(
    private readonly vaccinationsService: VaccinationsService,
  ) {}

  @Post()
  create(
    @Body() dto: CreateVaccinationDto,
    @Request() req,
  ) {
    return this.vaccinationsService.create(
      dto,
      req.user.phone,
    );
  }

  @Get()
  findAll(@Request() req) {
    return this.vaccinationsService.findAllForUser(
      req.user.phone,
    );
  }

  @Get(':id')
  findOne(
    @Param('id') id: string,
    @Request() req,
  ) {
    return this.vaccinationsService.findOne(
      +id,
      req.user.phone,
    );
  }

  @Get('/flock/:id')
  findByFlock(
    @Param('id') id: string,
    @Request() req,
  ) {
    return this.vaccinationsService.findByFlock(
      +id,
      req.user.phone,
    );
  }

  @Patch(':id')
  update(
    @Param('id') id: string,
    @Body() dto: UpdateVaccinationDto,
    @Request() req,
  ) {
    return this.vaccinationsService.update(
      +id,
      dto,
      req.user.phone,
    );
  }

  @Delete(':id')
  remove(
    @Param('id') id: string,
    @Request() req,
  ) {
    return this.vaccinationsService.remove(
      +id,
      req.user.phone,
    );
  }
}