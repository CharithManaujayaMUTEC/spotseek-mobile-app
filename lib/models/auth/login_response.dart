import 'package:json_annotation/json_annotation.dart';

part 'login_response.g.dart';

@JsonSerializable()
class LoginResponse {
  final String accessToken;
  final String refreshToken;
  final User user;

  LoginResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  // Convenience getters to match old API
  String get userType => user.userType.toUpperCase();
  int get userId => int.parse(user.id);
  String get email => user.email;
  String get mobile => user.mobile;
  String get status => user.status;
  bool get profileComplete => user.profileComplete;

  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseFromJson(json);

  Map<String, dynamic> toJson() => _$LoginResponseToJson(this);
}

@JsonSerializable()
class User {
  final String id;
  final String email;
  final String mobile;
  final String userType; // "partner" or "admin"
  final String status; // "approved", "pending", etc.
  final bool profileComplete;
  final String? loggedInBefore; // "true" or "false" string from API

  User({
    required this.id,
    required this.email,
    required this.mobile,
    required this.userType,
    required this.status,
    required this.profileComplete,
    this.loggedInBefore,
  });
  
  /// Returns true if user has logged in before
  bool get hasLoggedInBefore {
    if (loggedInBefore == null) return true; // Default to true if not provided
    return loggedInBefore?.toLowerCase() == 'true'; // Fixed: check for 'true', not 'false'
  }

  factory User.fromJson(Map<String, dynamic> json) =>
      _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}
