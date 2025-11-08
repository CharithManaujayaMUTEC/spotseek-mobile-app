import 'dart:io';
import 'package:dio/dio.dart';
import 'package:spotseeker_app/core/api/api_client.dart';
import 'package:spotseeker_app/core/api/api_exception.dart';
import 'package:spotseeker_app/core/constants/api_constants.dart';
import 'package:spotseeker_app/models/partner/partner_models.dart';

/// Partner Service
/// Handles all partner onboarding and profile API calls
class PartnerService {
  final ApiClient _apiClient = ApiClient();

  /// Save Company Profile (Multipart with files)
  Future<void> saveCompanyProfile({
    required CompanyProfile profile,
    File? businessRegistrationFile,
  }) async {
    try {
      final formData = FormData.fromMap({
        'organizationName': profile.organizationName,
        'businessEmail': profile.businessEmail,
        'registeredAddress': profile.registeredAddress,
        'hasBusinessRegistration': profile.hasBusinessRegistration,
        'bankName': profile.bankName,
        'accountNumber': profile.accountNumber,
        'accountHolderName': profile.accountHolderName,
        'branch': profile.branch,
        if (profile.instagramUrl != null) 'instagramUrl': profile.instagramUrl,
        if (profile.facebookUrl != null) 'facebookUrl': profile.facebookUrl,
        if (businessRegistrationFile != null)
          'businessRegistrationFile': await MultipartFile.fromFile(
            businessRegistrationFile.path,
            filename: businessRegistrationFile.path.split('/').last,
          ),
      });

      await _apiClient.postMultipart(
        ApiConstants.partnerCompanyProfile,
        formData: formData,
      );
    } on DioException catch (e) {
      if (e.error is ApiException) {
        rethrow;
      }
      throw ApiException.unknown();
    } catch (e) {
      throw ApiException.unknown();
    }
  }

  /// Save Organizer Info (Multipart with ID files)
  Future<void> saveOrganizerInfo({
    required OrganizerInfo organizerInfo,
    required File idFrontFile,
    required File idBackFile,
  }) async {
    try {
      final formData = FormData.fromMap({
        'organizerName': organizerInfo.organizerName,
        'organizerMobile': organizerInfo.organizerMobile,
        'organizerAddress': organizerInfo.organizerAddress,
        'organizerNic': organizerInfo.organizerNic,
        'idType': organizerInfo.idType,
        'idFrontFile': await MultipartFile.fromFile(
          idFrontFile.path,
          filename: idFrontFile.path.split('/').last,
        ),
        'idBackFile': await MultipartFile.fromFile(
          idBackFile.path,
          filename: idBackFile.path.split('/').last,
        ),
      });

      await _apiClient.postMultipart(
        ApiConstants.partnerOrganizerInfo,
        formData: formData,
      );
    } on DioException catch (e) {
      if (e.error is ApiException) {
        rethrow;
      }
      throw ApiException.unknown();
    } catch (e) {
      throw ApiException.unknown();
    }
  }

  /// Save Agreement (Multipart with signature file)
  Future<void> saveAgreement({
    required bool agreementAccepted,
    required File signatureFile,
  }) async {
    try {
      final formData = FormData.fromMap({
        'agreementAccepted': agreementAccepted,
        'signatureFile': await MultipartFile.fromFile(
          signatureFile.path,
          filename: signatureFile.path.split('/').last,
        ),
      });

      await _apiClient.postMultipart(
        ApiConstants.partnerAgreement,
        formData: formData,
      );
    } on DioException catch (e) {
      if (e.error is ApiException) {
        rethrow;
      }
      throw ApiException.unknown();
    } catch (e) {
      throw ApiException.unknown();
    }
  }

  Future<ApplicationStatusUpdate> getApplicationStatus() async {
    try {
      final response = await _apiClient.get(
        ApiConstants.partnerApplicationStatusUpdate,
      );

      return ApplicationStatusUpdate.fromJson(response.data);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException.unknown();
    }
  }

  /// Get Partner Profile
  Future<PartnerProfile> getPartnerProfile() async {
    try {
      final response = await _apiClient.get(
        ApiConstants.partnerProfile,
      );

      return PartnerProfile.fromJson(response.data);
    } on DioException catch (e) {
      if (e.error is ApiException) {
        rethrow;
      }
      throw ApiException.unknown();
    } catch (e) {
      throw ApiException.unknown();
    }
  }

  /// Upload File (Generic file upload)
  Future<FileUploadResponse> uploadFile({
    required File file,
    required String type, // IMAGE or DOCUMENT
    required String purpose, // EVENT_BANNER, EVENT_THUMBNAIL, etc.
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        ),
        'type': type,
        'purpose': purpose,
      });

      final response = await _apiClient.postMultipart(
        ApiConstants.upload,
        formData: formData,
      );

      return FileUploadResponse.fromJson(response.data);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException.unknown();
    }
  }

  /// Delete File
  Future<void> deleteFile(String fileId) async {
    try {
      await _apiClient.delete(ApiConstants.deleteFile(fileId));
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException.unknown();
    }
  }
}
