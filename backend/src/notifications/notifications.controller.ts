import { Controller, Get, Patch, Param, Req, UseGuards } from '@nestjs/common';
import { NotificationsService } from './notifications.service';
import { JwtAuthGuard } from 'src/auth/jwt-auth.guard';

@Controller('notifications')
@UseGuards(JwtAuthGuard)
export class NotificationsController {
  constructor(private readonly notificationsService: NotificationsService) {}

  @Get('me')
  async getMyNotifications(@Req() req) {
    return this.notificationsService.findByFarmer(req.user.user_id);
  }

  @Get('unread-count')
  async getUnreadCount(@Req() req) {
    return { count: await this.notificationsService.getUnreadCount(req.user.user_id) };
  }

  @Patch(':id/read')
  async markAsRead(@Param('id') id: string, @Req() req) {
    await this.notificationsService.markAsRead(+id, req.user.user_id);
    return { success: true };
  }

  @Patch('read-all')
  async markAllAsRead(@Req() req) {
    await this.notificationsService.markAllAsRead(req.user.user_id);
    return { success: true };
  }
}