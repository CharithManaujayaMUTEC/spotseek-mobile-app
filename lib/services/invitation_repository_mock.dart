import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'invitation_repository.dart';
import 'package:spotseeker_app/models/invitation_models.dart';

class MockInvitationRepository implements InvitationRepository {
  final String assetPath;

  MockInvitationRepository({this.assetPath = 'assets/mocks/mock_invitations.json'});

  Future<Map<String, dynamic>> _loadJson() async {
    final jsonStr = await rootBundle.loadString(assetPath);
    return jsonDecode(jsonStr) as Map<String, dynamic>;
  }

  /// Public helper to return the raw decoded JSON document from the mock asset.
  Future<Map<String, dynamic>> loadRawDoc() async => await _loadJson();

  @override
  Future<InvitationStats> fetchStats({required String eventId}) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final doc = await _loadJson();
    return InvitationStats.fromJson(doc['stats'] as Map<String, dynamic>);
  }

  @override
  Future<List<Invitation>> fetchSingleInvitations({required String eventId}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final doc = await _loadJson();
    final list = (doc['single'] as List<dynamic>? ) ?? <dynamic>[];
    return list.map((e) => Invitation.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<BulkInvitation>> fetchBulkInvitations({required String eventId}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final doc = await _loadJson();
    final list = (doc['bulk'] as List<dynamic>?) ?? <dynamic>[];
    return list.map((e) => BulkInvitation.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<Invitation> createInvitation({required String eventId, required Invitation invitation}) async {
    // mock: just return the same invitation after a short delay
    await Future.delayed(const Duration(milliseconds: 300));
    return invitation;
  }

  @override
  Future<Map<String, dynamic>> uploadBulkInvitations({required String eventId, required List<int> fileBytes, required String filename}) async {
    // mock result: pretend upload succeeded and give per-row results
    await Future.delayed(const Duration(milliseconds: 500));
    return {
      'status': 'ok',
      'results': [
        {'row': 1, 'ok': true},
        {'row': 2, 'ok': true},
        {'row': 3, 'ok': false, 'error': 'Invalid phone number'}
      ]
    };
  }
}
