import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Patch,
  Post,
} from '@nestjs/common';

import { VaccinesService } from './vaccines.service';
import { CreateVaccineDto } from './dto/create-vaccine.dto';
import { UpdateVaccineDto } from './dto/update-vaccine.dto';

@Controller('vaccines')
export class VaccinesController {
  constructor(
    private readonly vaccinesService: VaccinesService,
  ) {}

  // Create Vaccine
  @Post()
  create(
    @Body() createVaccineDto: CreateVaccineDto,
  ) {
    return this.vaccinesService.create(createVaccineDto);
  }

  // Get All Vaccines
  @Get()
  findAll() {
    return this.vaccinesService.findAll();
  }

  // Get Vaccine By ID
  @Get(':id')
  findOne(
    @Param('id') id: string,
  ) {
    return this.vaccinesService.findOne(+id);
  }

  // Update Vaccine
  @Patch(':id')
  update(
    @Param('id') id: string,
    @Body() updateVaccineDto: UpdateVaccineDto,
  ) {
    return this.vaccinesService.update(
      +id,
      updateVaccineDto,
    );
  }

  // Delete Vaccine
  @Delete(':id')
  remove(
    @Param('id') id: string,
  ) {
    return this.vaccinesService.remove(+id);
  }
}