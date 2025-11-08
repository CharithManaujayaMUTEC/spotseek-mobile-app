import 'package:json_annotation/json_annotation.dart';

part 'admin_registration.g.dart';

@JsonSerializable()
class AdminRegistrationRequest {
  final String email;
  final String mobile;
  final String password;

  AdminRegistrationRequest({
    required this.email,
    required this.mobile,
    required this.password,
  });

  factory AdminRegistrationRequest.fromJson(Map<String, dynamic> json) =>
      _$AdminRegistrationRequestFromJson(json);

  Map<String, dynamic> toJson() => _$AdminRegistrationRequestToJson(this);
}

@JsonSerializable()
class AdminRegistrationResponse {
  final String message;
  final int userId;

  AdminRegistrationResponse({
    required this.message,
    required this.userId,
  });

  factory AdminRegistrationResponse.fromJson(Map<String, dynamic> json) =>
      _$AdminRegistrationResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AdminRegistrationResponseToJson(this);
}
