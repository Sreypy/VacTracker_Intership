import { Controller, Get, Patch, Param, Req, UseGuards } from '@nestjs/common';
import { NotificationsService } from './notifications.service';
import { JwtAuthGuard } from 'src/auth/jwt-auth.guard';
import { UserRole } from '../users/entities/user.entity';

@Controller('notifications')
@UseGuards(JwtAuthGuard)
export class NotificationsController {
  constructor(private readonly notificationsService: NotificationsService) {}

  @Get('me')
  async getMyNotifications(@Req() req) {
    // Farmers receive vaccination reminders / vet responses, veterinarians
    // receive sick reports / farmer connection requests – same endpoint,
    // resolved by the authenticated role.
    if (req.user.role === UserRole.VETERINARIAN) {
      return this.notificationsService.findByVet(req.user.user_id);
    }
    return this.notificationsService.findByFarmer(req.user.user_id);
  }

  @Get('unread-count')
  async getUnreadCount(@Req() req) {
    if (req.user.role === UserRole.VETERINARIAN) {
      return {
        count: await this.notificationsService.getVetUnreadCount(
          req.user.user_id,
        ),
      };
    }
    return { count: await this.notificationsService.getUnreadCount(req.user.user_id) };
  }

  @Patch(':id/read')
  async markAsRead(@Param('id') id: string, @Req() req) {
    if (req.user.role === UserRole.VETERINARIAN) {
      await this.notificationsService.markVetNotificationAsRead(
        +id,
        req.user.user_id,
      );
      return { success: true };
    }
    await this.notificationsService.markAsRead(+id, req.user.user_id);
    return { success: true };
  }

  @Patch('read-all')
  async markAllAsRead(@Req() req) {
    if (req.user.role === UserRole.VETERINARIAN) {
      await this.notificationsService.markAllVetAsRead(req.user.user_id);
      return { success: true };
    }
    await this.notificationsService.markAllAsRead(req.user.user_id);
    return { success: true };
  }
}