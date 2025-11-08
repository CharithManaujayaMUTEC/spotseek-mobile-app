import 'package:spotseeker_app/models/invitation_models.dart';

/// Abstract repository for invitations. UI should depend on this interface so
/// implementations can be swapped between mocks and real API clients.
abstract class InvitationRepository {
  /// Fetch aggregated stats (total counts etc).
  Future<InvitationStats> fetchStats({required String eventId});

  /// Fetch single (individual) invitations for an event.
  Future<List<Invitation>> fetchSingleInvitations({required String eventId});

  /// Fetch bulk invitation batches for an event.
  Future<List<BulkInvitation>> fetchBulkInvitations({required String eventId});

  /// Create a single invitation (returns created invitation).
  Future<Invitation> createInvitation({required String eventId, required Invitation invitation});

  /// Upload a bulk invitations file. For mocks this can return a simple result.
  Future<Map<String, dynamic>> uploadBulkInvitations({required String eventId, required List<int> fileBytes, required String filename});
}
