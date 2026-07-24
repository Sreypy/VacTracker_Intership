import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';

import { UsersModule } from './users/users.module';
import { AuthModule } from './auth/auth.module';
import { SmsModule } from './sms/sms.module';
import { FlocksModule } from './flocks/flocks.module';
import { VaccinesModule } from './vaccines/vaccines.module';
import { VaccinationsModule } from './vaccinations/vaccinations.module';
import { RemindersModule } from './reminders/reminders.module';
import { ScheduleModule } from '@nestjs/schedule';

@Module({
  imports: [

    ConfigModule.forRoot({
      isGlobal: true,
    }),

    TypeOrmModule.forRootAsync({
      inject: [ConfigService],

      useFactory: (config: ConfigService) => ({
        type: 'postgres',

        host: config.get<string>('DB_HOST'),
        port: Number(config.get<string>('DB_PORT')),

        username: config.get<string>('DB_USERNAME'),
        password: config.get<string>('DB_PASSWORD'),
        database: config.get<string>('DB_DATABASE'),

        autoLoadEntities: true,
        synchronize: true,

      }),
    }),
    ScheduleModule.forRoot(),

    UsersModule,

    AuthModule,

    SmsModule,

    FlocksModule,

    VaccinesModule,

    VaccinationsModule,

    RemindersModule,
  ],
})
export class AppModule {}