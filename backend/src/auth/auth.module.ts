import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';

import { AuthController } from './auth.controller';
import { AuthService } from './auth.service';

import { OtpCode } from './entities/otp-code.entity';
import { User } from '../users/entities/user.entity';

import { JwtModule } from '@nestjs/jwt';
import { PassportModule } from '@nestjs/passport';
import { JwtStrategy } from './jwt.strategy';


@Module({

  imports: [

    PassportModule,

    TypeOrmModule.forFeature([
      OtpCode,
      User
    ]),


    JwtModule.register({
      secret: process.env.JWT_SECRET || 'vactracker_secret',
      signOptions:{
        expiresIn:'7d'
      }
    })

  ],


  controllers:[
    AuthController
  ],


  providers:[
    AuthService,
    JwtStrategy
  ]

})
export class AuthModule {}