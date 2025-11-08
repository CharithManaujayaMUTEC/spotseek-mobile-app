/// Partner Become Status Response Model
class PartnerBecomeStatusResponse {
  final int requestId;
  final String status;
  final bool requiresOtp;
  final bool requiresApproval;

  PartnerBecomeStatusResponse({
    required this.requestId,
    required this.status,
    required this.requiresOtp,
    required this.requiresApproval,
  });

  factory PartnerBecomeStatusResponse.fromJson(Map<String, dynamic> json) {
    return PartnerBecomeStatusResponse(
      requestId: json['requestId'] as int,
      status: json['status'] as String,
      requiresOtp: json['requiresOtp'] as bool,
      requiresApproval: json['requiresApproval'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'requestId': requestId,
      'status': status,
      'requiresOtp': requiresOtp,
      'requiresApproval': requiresApproval,
    };
  }

  // Status helper getters
  bool get isApproved => status.toUpperCase() == 'APPROVED';
  bool get isPending => status.toUpperCase() == 'PENDING_APPROVAL';
  bool get isRejected => status.toUpperCase() == 'REJECTED';
}
