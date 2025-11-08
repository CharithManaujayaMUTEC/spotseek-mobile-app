import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:spotseeker_app/models/profile.dart';

abstract class ProfileRepository {
  Future<Profile> loadProfile();
}

class MockProfileRepository implements ProfileRepository {
  final String assetPath;
  MockProfileRepository({this.assetPath = 'assets/mocks/profile_mock.json'});

  @override
  Future<Profile> loadProfile() async {
    final jsonStr = await rootBundle.loadString(assetPath);
    final Map<String, dynamic> data = jsonDecode(jsonStr) as Map<String, dynamic>;
    return Profile.fromJson(data);
  }
}
