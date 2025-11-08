import 'package:json_annotation/json_annotation.dart';

part 'partner_models.g.dart';

/// Company Profile Model
@JsonSerializable()
class CompanyProfile {
  final String organizationName;
  final String businessEmail;
  final String registeredAddress;
  final bool hasBusinessRegistration;
  final String? instagramUrl;
  final String? facebookUrl;
  final String bankName;
  final String accountNumber;
  final String accountHolderName;
  final String branch;

  CompanyProfile({
    required this.organizationName,
    required this.businessEmail,
    required this.registeredAddress,
    required this.hasBusinessRegistration,
    this.instagramUrl,
    this.facebookUrl,
    required this.bankName,
    required this.accountNumber,
    required this.accountHolderName,
    required this.branch,
  });

  factory CompanyProfile.fromJson(Map<String, dynamic> json) =>
      _$CompanyProfileFromJson(json);

  Map<String, dynamic> toJson() => _$CompanyProfileToJson(this);
}

/// Organizer Info Model
@JsonSerializable()
class OrganizerInfo {
  final String organizerName;
  final String organizerMobile;
  final String organizerAddress;
  final String organizerNic;
  final String idType; // NIC or PASSPORT

  OrganizerInfo({
    required this.organizerName,
    required this.organizerMobile,
    required this.organizerAddress,
    required this.organizerNic,
    required this.idType,
  });

  factory OrganizerInfo.fromJson(Map<String, dynamic> json) =>
      _$OrganizerInfoFromJson(json);

  Map<String, dynamic> toJson() => _$OrganizerInfoToJson(this);
}

/// Agreement Model
@JsonSerializable()
class Agreement {
  final bool agreementAccepted;

  Agreement({required this.agreementAccepted});

  factory Agreement.fromJson(Map<String, dynamic> json) =>
      _$AgreementFromJson(json);

  Map<String, dynamic> toJson() => _$AgreementToJson(this);
}

@JsonSerializable()
class ApplicationStatusUpdate {
  final int partnerId;
  final String applicationStatus;
  final String? adminNotes;
  final List<String>? fieldsToResolve;
  final List<int>? reviewedAt;
  final int? reviewedBy;
  final List<int>? submittedAt;
  final List<int>? lastUpdatedAt;
  final PartnerAgreement? partnerAgreement;

  ApplicationStatusUpdate({
    required this.partnerId,
    required this.applicationStatus,
    this.adminNotes,
    this.fieldsToResolve,
    this.reviewedAt,
    this.reviewedBy,
    this.submittedAt,
    this.lastUpdatedAt,
    this.partnerAgreement,
  });

  factory ApplicationStatusUpdate.fromJson(Map<String, dynamic> json) =>
      _$ApplicationStatusUpdateFromJson(json);

  Map<String, dynamic> toJson() => _$ApplicationStatusUpdateToJson(this);
}

/// Minimal user snapshot embedded in PartnerAgreement
@JsonSerializable()
class PartnerAgreementUser {
  final int id;
  final String? name;
  final String email;
  final String mobile;
  final String? password;
  final String userType;
  final String status;
  final bool profileComplete;
  final bool mobileVerified;
  final List<int>? createdAt;
  final List<int>? updatedAt;
  final bool? loggedInBefore;

  PartnerAgreementUser({
    required this.id,
    this.name,
    required this.email,
    required this.mobile,
    this.password,
    required this.userType,
    required this.status,
    required this.profileComplete,
    required this.mobileVerified,
    this.createdAt,
    this.updatedAt,
    this.loggedInBefore,
  });

  factory PartnerAgreementUser.fromJson(Map<String, dynamic> json) =>
      _$PartnerAgreementUserFromJson(json);

  Map<String, dynamic> toJson() => _$PartnerAgreementUserToJson(this);
}

/// Full partner agreement snapshot as returned by backend
@JsonSerializable()
class PartnerAgreement {
  final int id;
  final PartnerAgreementUser user;

  final String? organizationName;
  final String? businessEmail;
  final String? registrationStatus;
  final bool? emailVerified;
  final bool? mobileVerified;
  final bool? otpVerified;
  final String? adminNotes;
  final String? rejectionReason;
  final int? approvedBy;
  final List<int>? approvedAt;
  final String? applicationStatus;
  final int? reviewedBy;
  final List<int>? reviewedAt;
  final List<String>? rejectedFields;
  final String? registeredAddress;
  final bool? hasBusinessRegistration;
  final String? businessRegistrationFile;
  final String? instagramUrl;
  final String? facebookUrl;
  final String? bankName;
  final String? accountNumber;
  final String? accountHolderName;
  final String? branch;
  final String? organizerName;
  final String? organizerMobile;
  final String? organizerAddress;
  final String? organizerNic;
  final String? idType;
  final String? idFrontFile;
  final String? idBackFile;
  final bool? agreementAccepted;
  final String? signatureFile;
  final List<int>? signedAt;
  final String? onboardingStep;
  final List<int>? createdAt;
  final List<int>? updatedAt;

  PartnerAgreement({
    required this.id,
    required this.user,
    this.organizationName,
    this.businessEmail,
    this.registrationStatus,
    this.emailVerified,
    this.mobileVerified,
    this.otpVerified,
    this.adminNotes,
    this.rejectionReason,
    this.approvedBy,
    this.approvedAt,
    this.applicationStatus,
    this.reviewedBy,
    this.reviewedAt,
    this.rejectedFields,
    this.registeredAddress,
    this.hasBusinessRegistration,
    this.businessRegistrationFile,
    this.instagramUrl,
    this.facebookUrl,
    this.bankName,
    this.accountNumber,
    this.accountHolderName,
    this.branch,
    this.organizerName,
    this.organizerMobile,
    this.organizerAddress,
    this.organizerNic,
    this.idType,
    this.idFrontFile,
    this.idBackFile,
    this.agreementAccepted,
    this.signatureFile,
    this.signedAt,
    this.onboardingStep,
    this.createdAt,
    this.updatedAt,
  });

  factory PartnerAgreement.fromJson(Map<String, dynamic> json) =>
      _$PartnerAgreementFromJson(json);

  Map<String, dynamic> toJson() => _$PartnerAgreementToJson(this);
}

/// Partner Profile Response
@JsonSerializable()
class PartnerProfile {
  final int id;
  final String? organizationName;
  final String? businessEmail;
  final String registrationStatus;
  final bool agreementAccepted;
  final String? onboardingStep;

  PartnerProfile({
    required this.id,
    this.organizationName,
    this.businessEmail,
    required this.registrationStatus,
    required this.agreementAccepted,
    this.onboardingStep,
  });

  factory PartnerProfile.fromJson(Map<String, dynamic> json) =>
      _$PartnerProfileFromJson(json);

  Map<String, dynamic> toJson() => _$PartnerProfileToJson(this);
}

/// File Upload Response
@JsonSerializable()
class FileUploadResponse {
  final String fileId;
  final String url;
  final String type;

  FileUploadResponse({
    required this.fileId,
    required this.url,
    required this.type,
  });

  factory FileUploadResponse.fromJson(Map<String, dynamic> json) =>
      _$FileUploadResponseFromJson(json);

  Map<String, dynamic> toJson() => _$FileUploadResponseToJson(this);
}
