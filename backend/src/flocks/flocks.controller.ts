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

import { FlocksService } from './flocks.service';
import { CreateFlockDto } from './dto/create-flock.dto';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { UpdateFlockDto } from './dto/update-flock.dto';

@Controller('flocks')
export class FlocksController {
  constructor(private readonly flocksService: FlocksService) {}

  @UseGuards(JwtAuthGuard)
  @Post()
  create(
    @Body() dto: CreateFlockDto,
    @Request() req,
  ) {
    return this.flocksService.create(dto, req.user.phone);
  }

  @Get()
    @UseGuards(JwtAuthGuard)
    findAll(@Request() req) {
    return this.flocksService.findAll(req.user.phone);
    }

    @UseGuards(JwtAuthGuard)
    @Get(':id')
    findOne(
    @Param('id') id: number,
    @Request() req,
    ) {
    return this.flocksService.findOne(+id, req.user.phone);
    }

    @UseGuards(JwtAuthGuard)
    @Patch(':id')
    update(
    @Param('id') id: number,
    @Body() dto: UpdateFlockDto,
    @Request() req,
    ) {

    return this.flocksService.update(
        +id,
        dto,
        req.user.phone,
    );

    }

    @UseGuards(JwtAuthGuard)
    @Delete(':id')
    remove(
    @Param('id') id: number,
    @Request() req,
    ) {

    return this.flocksService.remove(
        +id,
        req.user.phone,
    );

    }


}