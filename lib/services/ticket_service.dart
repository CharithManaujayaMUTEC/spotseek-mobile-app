import 'package:spotseeker_app/core/api/api_client.dart';
import 'package:spotseeker_app/core/api/api_exception.dart';
import 'package:spotseeker_app/core/constants/api_constants.dart';
import 'package:spotseeker_app/models/ticket/ticket_models.dart';

/// Ticket Service
class TicketService {
  final ApiClient _apiClient = ApiClient();

  /// Generate Ticket QR
  Future<void> generateTicketQR({
    required int eventId,
    required int ticketPackageId,
    required int quantity,
  }) async {
    try {
      final request = GenerateTicketRequest(
        ticket_package_id: ticketPackageId,
        quantity: quantity,
      );

      await _apiClient.post(
        ApiConstants.eventGenerateTicketQR(eventId),
        data: request.toJson(),
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException.unknown();
    }
  }

  /// Verify Ticket
  Future<VerifyTicketResponse> verifyTicket(String orderId) async {
    try {
      final request = VerifyTicketRequest(orderId: orderId);

      final response = await _apiClient.post(
        ApiConstants.ticketsVerify,
        data: request.toJson(),
      );

      return VerifyTicketResponse.fromJson(response.data);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException.unknown();
    }
  }
}
