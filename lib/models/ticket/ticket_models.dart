import 'package:json_annotation/json_annotation.dart';

part 'ticket_models.g.dart';

/// Ticket Generate Request
@JsonSerializable()
class GenerateTicketRequest {
  final int ticket_package_id;
  final int quantity;

  GenerateTicketRequest({
    required this.ticket_package_id,
    required this.quantity,
  });

  factory GenerateTicketRequest.fromJson(Map<String, dynamic> json) =>
      _$GenerateTicketRequestFromJson(json);

  Map<String, dynamic> toJson() => _$GenerateTicketRequestToJson(this);
}

/// Ticket Verify Request
@JsonSerializable()
class VerifyTicketRequest {
  final String orderId;

  VerifyTicketRequest({required this.orderId});

  factory VerifyTicketRequest.fromJson(Map<String, dynamic> json) =>
      _$VerifyTicketRequestFromJson(json);

  Map<String, dynamic> toJson() => _$VerifyTicketRequestToJson(this);
}

/// Ticket Verify Response
@JsonSerializable()
class VerifyTicketResponse {
  final bool valid;
  final String? eventName;
  final String? packageName;
  final String? attendeeName;
  final bool? alreadyCheckedIn;
  final String? message;

  VerifyTicketResponse({
    required this.valid,
    this.eventName,
    this.packageName,
    this.attendeeName,
    this.alreadyCheckedIn,
    this.message,
  });

  factory VerifyTicketResponse.fromJson(Map<String, dynamic> json) =>
      _$VerifyTicketResponseFromJson(json);

  Map<String, dynamic> toJson() => _$VerifyTicketResponseToJson(this);
}
