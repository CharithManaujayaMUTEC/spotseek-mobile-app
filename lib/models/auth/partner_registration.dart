import 'package:json_annotation/json_annotation.dart';

part 'partner_registration.g.dart';

@JsonSerializable()
class PartnerRegistrationStep1 {
  final String email;

  PartnerRegistrationStep1({required this.email});

  factory PartnerRegistrationStep1.fromJson(Map<String, dynamic> json) =>
      _$PartnerRegistrationStep1FromJson(json);

  Map<String, dynamic> toJson() => _$PartnerRegistrationStep1ToJson(this);
}

@JsonSerializable()
class PartnerRegistrationStep2 {
  final String email;
  final String mobile;

  PartnerRegistrationStep2({
    required this.email,
    required this.mobile,
  });

  factory PartnerRegistrationStep2.fromJson(Map<String, dynamic> json) =>
      _$PartnerRegistrationStep2FromJson(json);

  Map<String, dynamic> toJson() => _$PartnerRegistrationStep2ToJson(this);
}

@JsonSerializable()
class PartnerRegistrationStep3 {
  final String email;
  final String mobile;
  final String otp;

  PartnerRegistrationStep3({
    required this.email,
    required this.mobile,
    required this.otp,
  });

  factory PartnerRegistrationStep3.fromJson(Map<String, dynamic> json) =>
      _$PartnerRegistrationStep3FromJson(json);

  Map<String, dynamic> toJson() => _$PartnerRegistrationStep3ToJson(this);
}

@JsonSerializable()
class PartnerRegistrationResponse {
  final String message;
  final String? otpSent; // For step 2
  final String? accessToken; // For step 3
  final String? refreshToken; // For step 3

  PartnerRegistrationResponse({
    required this.message,
    this.otpSent,
    this.accessToken,
    this.refreshToken,
  });

  factory PartnerRegistrationResponse.fromJson(Map<String, dynamic> json) =>
      _$PartnerRegistrationResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PartnerRegistrationResponseToJson(this);
}
