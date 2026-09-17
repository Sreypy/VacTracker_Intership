import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Like, Repository } from 'typeorm';

import { VaccineLibrary } from './entities/vaccine-library.entity';

@Injectable()
export class VaccineLibraryService {
  constructor(
    @InjectRepository(VaccineLibrary)
    private readonly libraryRepository: Repository<VaccineLibrary>,
  ) {}

  // Get all library articles (optional search by vaccine name or disease)
  async findAll(search?: string) {
    if (search && search.trim().length > 0) {
      const term = search.trim();

      return await this.libraryRepository.find({
        where: [
          { name_en: Like(`%${term}%`) },
          { name_km: Like(`%${term}%`) },
          { disease_en: Like(`%${term}%`) },
          { disease_km: Like(`%${term}%`) },
        ],
        order: {
          name_en: 'ASC',
        },
      });
    }

    return await this.libraryRepository.find({
      order: {
        name_en: 'ASC',
      },
    });
  }

  // Get one library article by ID
  async findOne(id: number) {
    const article = await this.libraryRepository.findOne({
      where: {
        library_id: id,
      },
    });

    if (!article) {
      throw new NotFoundException('Vaccine library article not found');
    }

    return article;
  }
}