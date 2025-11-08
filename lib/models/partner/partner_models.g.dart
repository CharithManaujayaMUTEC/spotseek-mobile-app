// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'partner_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CompanyProfile _$CompanyProfileFromJson(Map<String, dynamic> json) =>
    CompanyProfile(
      organizationName: json['organizationName'] as String,
      businessEmail: json['businessEmail'] as String,
      registeredAddress: json['registeredAddress'] as String,
      hasBusinessRegistration: json['hasBusinessRegistration'] as bool,
      instagramUrl: json['instagramUrl'] as String?,
      facebookUrl: json['facebookUrl'] as String?,
      bankName: json['bankName'] as String,
      accountNumber: json['accountNumber'] as String,
      accountHolderName: json['accountHolderName'] as String,
      branch: json['branch'] as String,
    );

Map<String, dynamic> _$CompanyProfileToJson(CompanyProfile instance) =>
    <String, dynamic>{
      'organizationName': instance.organizationName,
      'businessEmail': instance.businessEmail,
      'registeredAddress': instance.registeredAddress,
      'hasBusinessRegistration': instance.hasBusinessRegistration,
      'instagramUrl': instance.instagramUrl,
      'facebookUrl': instance.facebookUrl,
      'bankName': instance.bankName,
      'accountNumber': instance.accountNumber,
      'accountHolderName': instance.accountHolderName,
      'branch': instance.branch,
    };

OrganizerInfo _$OrganizerInfoFromJson(Map<String, dynamic> json) =>
    OrganizerInfo(
      organizerName: json['organizerName'] as String,
      organizerMobile: json['organizerMobile'] as String,
      organizerAddress: json['organizerAddress'] as String,
      organizerNic: json['organizerNic'] as String,
      idType: json['idType'] as String,
    );

Map<String, dynamic> _$OrganizerInfoToJson(OrganizerInfo instance) =>
    <String, dynamic>{
      'organizerName': instance.organizerName,
      'organizerMobile': instance.organizerMobile,
      'organizerAddress': instance.organizerAddress,
      'organizerNic': instance.organizerNic,
      'idType': instance.idType,
    };

Agreement _$AgreementFromJson(Map<String, dynamic> json) => Agreement(
      agreementAccepted: json['agreementAccepted'] as bool,
    );

Map<String, dynamic> _$AgreementToJson(Agreement instance) => <String, dynamic>{
      'agreementAccepted': instance.agreementAccepted,
    };

// Removed unused ApplicationStatusStep serializers

ApplicationStatusUpdate _$ApplicationStatusUpdateFromJson(
        Map<String, dynamic> json) =>
    ApplicationStatusUpdate(
      partnerId: (json['partnerId'] as num).toInt(),
      applicationStatus: json['applicationStatus'] as String,
      adminNotes: json['adminNotes'] as String?,
      fieldsToResolve: (json['fieldsToResolve'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      reviewedAt: (json['reviewedAt'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
      reviewedBy: (json['reviewedBy'] as num?)?.toInt(),
      submittedAt: (json['submittedAt'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
      lastUpdatedAt: (json['lastUpdatedAt'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
      partnerAgreement: json['partnerAgreement'] == null
          ? null
          : PartnerAgreement.fromJson(
              json['partnerAgreement'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ApplicationStatusUpdateToJson(
        ApplicationStatusUpdate instance) =>
    <String, dynamic>{
      'partnerId': instance.partnerId,
      'applicationStatus': instance.applicationStatus,
      'adminNotes': instance.adminNotes,
      'fieldsToResolve': instance.fieldsToResolve,
      'reviewedAt': instance.reviewedAt,
      'reviewedBy': instance.reviewedBy,
      'submittedAt': instance.submittedAt,
      'lastUpdatedAt': instance.lastUpdatedAt,
      'partnerAgreement': instance.partnerAgreement,
    };

PartnerAgreementUser _$PartnerAgreementUserFromJson(
        Map<String, dynamic> json) =>
    PartnerAgreementUser(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String?,
      email: json['email'] as String,
      mobile: json['mobile'] as String,
      password: json['password'] as String?,
      userType: json['userType'] as String,
      status: json['status'] as String,
      profileComplete: json['profileComplete'] as bool,
      mobileVerified: json['mobileVerified'] as bool,
      createdAt: (json['createdAt'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
      updatedAt: (json['updatedAt'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
      loggedInBefore: json['loggedInBefore'] as bool?,
    );

Map<String, dynamic> _$PartnerAgreementUserToJson(
        PartnerAgreementUser instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'mobile': instance.mobile,
      'password': instance.password,
      'userType': instance.userType,
      'status': instance.status,
      'profileComplete': instance.profileComplete,
      'mobileVerified': instance.mobileVerified,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
      'loggedInBefore': instance.loggedInBefore,
    };

PartnerAgreement _$PartnerAgreementFromJson(Map<String, dynamic> json) =>
    PartnerAgreement(
      id: (json['id'] as num).toInt(),
      user: PartnerAgreementUser.fromJson(json['user'] as Map<String, dynamic>),
      organizationName: json['organizationName'] as String?,
      businessEmail: json['businessEmail'] as String?,
      registrationStatus: json['registrationStatus'] as String?,
      emailVerified: json['emailVerified'] as bool?,
      mobileVerified: json['mobileVerified'] as bool?,
      otpVerified: json['otpVerified'] as bool?,
      adminNotes: json['adminNotes'] as String?,
      rejectionReason: json['rejectionReason'] as String?,
      approvedBy: (json['approvedBy'] as num?)?.toInt(),
      approvedAt: (json['approvedAt'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
      applicationStatus: json['applicationStatus'] as String?,
      reviewedBy: (json['reviewedBy'] as num?)?.toInt(),
      reviewedAt: (json['reviewedAt'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
      rejectedFields: (json['rejectedFields'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      registeredAddress: json['registeredAddress'] as String?,
      hasBusinessRegistration: json['hasBusinessRegistration'] as bool?,
      businessRegistrationFile: json['businessRegistrationFile'] as String?,
      instagramUrl: json['instagramUrl'] as String?,
      facebookUrl: json['facebookUrl'] as String?,
      bankName: json['bankName'] as String?,
      accountNumber: json['accountNumber'] as String?,
      accountHolderName: json['accountHolderName'] as String?,
      branch: json['branch'] as String?,
      organizerName: json['organizerName'] as String?,
      organizerMobile: json['organizerMobile'] as String?,
      organizerAddress: json['organizerAddress'] as String?,
      organizerNic: json['organizerNic'] as String?,
      idType: json['idType'] as String?,
      idFrontFile: json['idFrontFile'] as String?,
      idBackFile: json['idBackFile'] as String?,
      agreementAccepted: json['agreementAccepted'] as bool?,
      signatureFile: json['signatureFile'] as String?,
      signedAt: (json['signedAt'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
      onboardingStep: json['onboardingStep'] as String?,
      createdAt: (json['createdAt'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
      updatedAt: (json['updatedAt'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
    );

Map<String, dynamic> _$PartnerAgreementToJson(PartnerAgreement instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user': instance.user,
      'organizationName': instance.organizationName,
      'businessEmail': instance.businessEmail,
      'registrationStatus': instance.registrationStatus,
      'emailVerified': instance.emailVerified,
      'mobileVerified': instance.mobileVerified,
      'otpVerified': instance.otpVerified,
      'adminNotes': instance.adminNotes,
      'rejectionReason': instance.rejectionReason,
      'approvedBy': instance.approvedBy,
      'approvedAt': instance.approvedAt,
      'applicationStatus': instance.applicationStatus,
      'reviewedBy': instance.reviewedBy,
      'reviewedAt': instance.reviewedAt,
      'rejectedFields': instance.rejectedFields,
      'registeredAddress': instance.registeredAddress,
      'hasBusinessRegistration': instance.hasBusinessRegistration,
      'businessRegistrationFile': instance.businessRegistrationFile,
      'instagramUrl': instance.instagramUrl,
      'facebookUrl': instance.facebookUrl,
      'bankName': instance.bankName,
      'accountNumber': instance.accountNumber,
      'accountHolderName': instance.accountHolderName,
      'branch': instance.branch,
      'organizerName': instance.organizerName,
      'organizerMobile': instance.organizerMobile,
      'organizerAddress': instance.organizerAddress,
      'organizerNic': instance.organizerNic,
      'idType': instance.idType,
      'idFrontFile': instance.idFrontFile,
      'idBackFile': instance.idBackFile,
      'agreementAccepted': instance.agreementAccepted,
      'signatureFile': instance.signatureFile,
      'signedAt': instance.signedAt,
      'onboardingStep': instance.onboardingStep,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
    };

PartnerProfile _$PartnerProfileFromJson(Map<String, dynamic> json) =>
    PartnerProfile(
      id: (json['id'] as num).toInt(),
      organizationName: json['organizationName'] as String?,
      businessEmail: json['businessEmail'] as String?,
      registrationStatus: json['registrationStatus'] as String,
      agreementAccepted: json['agreementAccepted'] as bool,
      onboardingStep: json['onboardingStep'] as String?,
    );

Map<String, dynamic> _$PartnerProfileToJson(PartnerProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'organizationName': instance.organizationName,
      'businessEmail': instance.businessEmail,
      'registrationStatus': instance.registrationStatus,
      'agreementAccepted': instance.agreementAccepted,
      'onboardingStep': instance.onboardingStep,
    };

FileUploadResponse _$FileUploadResponseFromJson(Map<String, dynamic> json) =>
    FileUploadResponse(
      fileId: json['fileId'] as String,
      url: json['url'] as String,
      type: json['type'] as String,
    );

Map<String, dynamic> _$FileUploadResponseToJson(FileUploadResponse instance) =>
    <String, dynamic>{
      'fileId': instance.fileId,
      'url': instance.url,
      'type': instance.type,
    };
