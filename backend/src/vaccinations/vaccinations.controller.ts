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
export class VaccinationsController {
  constructor(
    private readonly vaccinationsService: VaccinationsService,
  ) {}

  @UseGuards(JwtAuthGuard)
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
  findAll() {
    return this.vaccinationsService.findAll();
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.vaccinationsService.findOne(+id);
  }

  @Get('/flock/:id')
  findByFlock(@Param('id') id: string) {
    return this.vaccinationsService.findByFlock(+id);
  }

  @Patch(':id')
  update(
    @Param('id') id: string,
    @Body() dto: UpdateVaccinationDto,
  ) {
    return this.vaccinationsService.update(+id, dto);
  }

  @Delete(':id')
  remove(@Param('id') id: string) {
    return this.vaccinationsService.remove(+id);
  }
}