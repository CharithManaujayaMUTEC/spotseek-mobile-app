import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spotseeker_app/services/partner_service.dart';
import 'package:spotseeker_app/services/ticket_service.dart';

/// Partner Service Provider
final partnerServiceProvider = Provider<PartnerService>((ref) {
  return PartnerService();
});

/// Ticket Service Provider
final ticketServiceProvider = Provider<TicketService>((ref) {
  return TicketService();
});
