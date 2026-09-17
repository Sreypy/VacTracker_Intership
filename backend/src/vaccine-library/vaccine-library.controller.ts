import {
  Controller,
  Get,
  Param,
  Query,
} from '@nestjs/common';

import { VaccineLibraryService } from './vaccine-library.service';

@Controller('vaccine-library')
export class VaccineLibraryController {
  constructor(
    private readonly vaccineLibraryService: VaccineLibraryService,
  ) {}

  // Get all library articles (with optional search)
  // GET /vaccine-library?search=newcastle
  @Get()
  findAll(
    @Query('search') search?: string,
  ) {
    return this.vaccineLibraryService.findAll(search);
  }

  // Get one library article by ID
  // GET /vaccine-library/1
  @Get(':id')
  findOne(
    @Param('id') id: string,
  ) {
    return this.vaccineLibraryService.findOne(+id);
  }
}