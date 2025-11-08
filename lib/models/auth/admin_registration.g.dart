// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_registration.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminRegistrationRequest _$AdminRegistrationRequestFromJson(
        Map<String, dynamic> json) =>
    AdminRegistrationRequest(
      email: json['email'] as String,
      mobile: json['mobile'] as String,
      password: json['password'] as String,
    );

Map<String, dynamic> _$AdminRegistrationRequestToJson(
        AdminRegistrationRequest instance) =>
    <String, dynamic>{
      'email': instance.email,
      'mobile': instance.mobile,
      'password': instance.password,
    };

AdminRegistrationResponse _$AdminRegistrationResponseFromJson(
        Map<String, dynamic> json) =>
    AdminRegistrationResponse(
      message: json['message'] as String,
      userId: (json['userId'] as num).toInt(),
    );

Map<String, dynamic> _$AdminRegistrationResponseToJson(
        AdminRegistrationResponse instance) =>
    <String, dynamic>{
      'message': instance.message,
      'userId': instance.userId,
    };
