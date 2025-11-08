// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'partner_registration.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PartnerRegistrationStep1 _$PartnerRegistrationStep1FromJson(
        Map<String, dynamic> json) =>
    PartnerRegistrationStep1(
      email: json['email'] as String,
    );

Map<String, dynamic> _$PartnerRegistrationStep1ToJson(
        PartnerRegistrationStep1 instance) =>
    <String, dynamic>{
      'email': instance.email,
    };

PartnerRegistrationStep2 _$PartnerRegistrationStep2FromJson(
        Map<String, dynamic> json) =>
    PartnerRegistrationStep2(
      email: json['email'] as String,
      mobile: json['mobile'] as String,
    );

Map<String, dynamic> _$PartnerRegistrationStep2ToJson(
        PartnerRegistrationStep2 instance) =>
    <String, dynamic>{
      'email': instance.email,
      'mobile': instance.mobile,
    };

PartnerRegistrationStep3 _$PartnerRegistrationStep3FromJson(
        Map<String, dynamic> json) =>
    PartnerRegistrationStep3(
      email: json['email'] as String,
      mobile: json['mobile'] as String,
      otp: json['otp'] as String,
    );

Map<String, dynamic> _$PartnerRegistrationStep3ToJson(
        PartnerRegistrationStep3 instance) =>
    <String, dynamic>{
      'email': instance.email,
      'mobile': instance.mobile,
      'otp': instance.otp,
    };

PartnerRegistrationResponse _$PartnerRegistrationResponseFromJson(
        Map<String, dynamic> json) =>
    PartnerRegistrationResponse(
      message: json['message'] as String,
      otpSent: json['otpSent'] as String?,
      accessToken: json['accessToken'] as String?,
      refreshToken: json['refreshToken'] as String?,
    );

Map<String, dynamic> _$PartnerRegistrationResponseToJson(
        PartnerRegistrationResponse instance) =>
    <String, dynamic>{
      'message': instance.message,
      'otpSent': instance.otpSent,
      'accessToken': instance.accessToken,
      'refreshToken': instance.refreshToken,
    };
