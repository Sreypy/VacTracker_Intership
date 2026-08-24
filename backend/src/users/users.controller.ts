import { Body, Controller, Get, Param, Patch, Post, UseGuards, Request, ForbiddenException } from '@nestjs/common';
import { UsersService } from './users.service';
import { CreateUserDto } from './dto/create-user.dto';
import { UpdateUserDto } from './dto/update-user.dto';
import { ConnectVetDto } from './dto/connect-vet.dto';
import { JwtAuthGuard } from 'src/auth/jwt-auth.guard';

@Controller('users')
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Post()
  create(@Body() createUserDto: CreateUserDto) {
    return this.usersService.create(createUserDto);
  }

  @UseGuards(JwtAuthGuard)
  @Get()
  findAll(@Request() req) {
    return this.usersService.findAll(req.user.user_id, req.user.role);
  }

  @UseGuards(JwtAuthGuard)
  @Patch(':id')
  update(
    @Param('id') id: number,
    @Body() updateUserDto: UpdateUserDto,
    @Request() req,
  ) {
    // Users can only update their own profile
    if (+id !== req.user.user_id) {
      throw new ForbiddenException('You can only update your own profile');
    }
    return this.usersService.update(+id, updateUserDto);
  }

  @UseGuards(JwtAuthGuard)
  @Get('profile')
  getProfile(@Request() req) {
    return this.usersService.getProfile(req.user.phone);
  }

  @UseGuards(JwtAuthGuard)
  @Post('upload-profile-image')
  async uploadProfileImage(@Request() req, @Body() body: { profile_image_url: string }) {
    return this.usersService.updateProfileImage(req.user.phone, body.profile_image_url);
  }

  @UseGuards(JwtAuthGuard)
  @Post('connect-vet')
  async connectToVet(@Request() req, @Body() connectVetDto: ConnectVetDto) {
    return this.usersService.connectToVet(req.user.user_id, connectVetDto);
  }

  @UseGuards(JwtAuthGuard)
  @Get('my-vets')
  async getMyVets(@Request() req) {
    return this.usersService.getMyVets(req.user.user_id);
  }
}
