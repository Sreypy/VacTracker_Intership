import {
  Controller,
  Get,
  Param,
  ParseIntPipe,
  Post,
  Request,
  UseGuards,
} from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { VetConnectionsService } from './vet-connections.service';

@Controller('vet/connections')
@UseGuards(JwtAuthGuard)
export class VetConnectionsController {
  constructor(private readonly vetConnectionsService: VetConnectionsService) {}

  /** Pending farmer connection requests for the logged-in veterinarian. */
  @Get('requests')
  async getConnectionRequests(@Request() req) {
    return this.vetConnectionsService.getConnectionRequests(req.user.phone);
  }

  /** Accept a pending farmer connection request. */
  @Post(':id/accept')
  async acceptConnection(
    @Request() req,
    @Param('id', ParseIntPipe) connectionId: number,
  ) {
    return this.vetConnectionsService.respondToConnection(
      req.user.phone,
      connectionId,
      'accept',
    );
  }

  /** Reject a pending farmer connection request. */
  @Post(':id/reject')
  async rejectConnection(
    @Request() req,
    @Param('id', ParseIntPipe) connectionId: number,
  ) {
    return this.vetConnectionsService.respondToConnection(
      req.user.phone,
      connectionId,
      'reject',
    );
  }
}
