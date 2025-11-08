// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ticket_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GenerateTicketRequest _$GenerateTicketRequestFromJson(
        Map<String, dynamic> json) =>
    GenerateTicketRequest(
      ticket_package_id: (json['ticket_package_id'] as num).toInt(),
      quantity: (json['quantity'] as num).toInt(),
    );

Map<String, dynamic> _$GenerateTicketRequestToJson(
        GenerateTicketRequest instance) =>
    <String, dynamic>{
      'ticket_package_id': instance.ticket_package_id,
      'quantity': instance.quantity,
    };

VerifyTicketRequest _$VerifyTicketRequestFromJson(Map<String, dynamic> json) =>
    VerifyTicketRequest(
      orderId: json['orderId'] as String,
    );

Map<String, dynamic> _$VerifyTicketRequestToJson(
        VerifyTicketRequest instance) =>
    <String, dynamic>{
      'orderId': instance.orderId,
    };

VerifyTicketResponse _$VerifyTicketResponseFromJson(
        Map<String, dynamic> json) =>
    VerifyTicketResponse(
      valid: json['valid'] as bool,
      eventName: json['eventName'] as String?,
      packageName: json['packageName'] as String?,
      attendeeName: json['attendeeName'] as String?,
      alreadyCheckedIn: json['alreadyCheckedIn'] as bool?,
      message: json['message'] as String?,
    );

Map<String, dynamic> _$VerifyTicketResponseToJson(
        VerifyTicketResponse instance) =>
    <String, dynamic>{
      'valid': instance.valid,
      'eventName': instance.eventName,
      'packageName': instance.packageName,
      'attendeeName': instance.attendeeName,
      'alreadyCheckedIn': instance.alreadyCheckedIn,
      'message': instance.message,
    };
