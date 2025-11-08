import 'package:dio/dio.dart';
import 'package:spotseeker_app/core/api/api_client.dart';
import 'package:spotseeker_app/core/api/api_exception.dart';
import 'package:spotseeker_app/core/constants/api_constants.dart';
import 'package:spotseeker_app/core/storage/secure_storage.dart';
import 'package:spotseeker_app/models/auth/admin_registration.dart';
import 'package:spotseeker_app/models/auth/login_request.dart';
import 'package:spotseeker_app/models/auth/login_response.dart';
import 'package:spotseeker_app/models/auth/partner_registration.dart';
import 'package:spotseeker_app/models/auth/refresh_token_request.dart';
import 'package:spotseeker_app/models/auth/partner_become_status.dart';

/// Authentication Service
/// Handles all authentication-related API calls
class AuthService {
  final ApiClient _apiClient = ApiClient();
  final SecureStorage _storage = SecureStorage();

  // External partner API URL built from constants (legacy web uses /api/login)
  static const String _externalPartnerApiUrl =
      '${ApiConstants.legacyWebApiBaseUrl}${ApiConstants.legacyWebLogin}';

  /// Login (Admin/Partner)
  /// Performs two logins:
  /// 1. BASE_URL/api/auth/login - uses email and user-provided password
  /// 2. UAT backend (https://uatapi.spotseeker.lk) /api/auth/login - uses same password
  ///
  /// Returns a LoginResponse with custom status codes:
  /// - Status 'BOTH_SUCCESS': Both APIs succeeded
  /// - Status 'LEGACY_ONLY': Only legacy API succeeded
  /// - Status 'MOBILE_ONLY': Only mobile API succeeded (should stay on login)
  /// - Throws exception if both fail
  Future<LoginResponse> login(String email, String password) async {
    LoginResponse? loginResponse;
    bool mobileLoginSuccess = false;
    bool legacyLoginSuccess = false;
    Map<String, dynamic>? legacyData;

    // First attempt: Mobile API login (BASE_URL/api/auth/login)
    try {
      final request = LoginRequest(email: email, password: password);

      final response = await _apiClient.post(
        ApiConstants.authLogin,
        data: request.toJson(),
      );

      // Dev: log mobile login response details for debugging
      try {
        print(
            'AuthService: mobile login response status: ${response.statusCode}');
        print('AuthService: mobile login response data: ${response.data}');
      } catch (e) {
        print('AuthService: error logging mobile response: $e');
      }

      loginResponse = LoginResponse.fromJson(response.data);

      // Save tokens and user info from first login
      await _saveAuthData(loginResponse);

      // Dev: verify mobile tokens saved (masked) for quick runtime confirmation
      try {
        print('\n=== Mobile API Tokens Saved ===');

        final savedMobileAccess =
            await _storage.read(ApiConstants.mobileAccessTokenKey);
        if (savedMobileAccess != null && savedMobileAccess.isNotEmpty) {
          final masked = savedMobileAccess.length > 8
              ? '${savedMobileAccess.substring(0, 4)}...${savedMobileAccess.substring(savedMobileAccess.length - 4)}'
              : '***';
          print('${ApiConstants.mobileAccessTokenKey} = $masked');
        } else {
          print('${ApiConstants.mobileAccessTokenKey} = NOT FOUND');
        }

        final savedMobileRefresh =
            await _storage.read(ApiConstants.mobileRefreshTokenKey);
        if (savedMobileRefresh != null && savedMobileRefresh.isNotEmpty) {
          final masked = savedMobileRefresh.length > 8
              ? '${savedMobileRefresh.substring(0, 4)}...${savedMobileRefresh.substring(savedMobileRefresh.length - 4)}'
              : '***';
          print('${ApiConstants.mobileRefreshTokenKey} = $masked');
        } else {
          print('${ApiConstants.mobileRefreshTokenKey} = NOT FOUND');
        }

        print('===============================\n');
      } catch (e) {
        print('AuthService: error reading mobile tokens after save: $e');
      }

      mobileLoginSuccess = true;
    } catch (e) {
      // Log mobile API login failure but continue to try legacy API
      if (e is DioError) {
        final resp = e.response;
        print('AuthService: Mobile API login failed - ${e.message}');
        if (resp != null) {
          print('AuthService: Mobile API response status: ${resp.statusCode}');
          print('AuthService: Mobile API response data: ${resp.data}');
        }
      } else {
        print('AuthService: Mobile API login error: $e');
      }

      print('AuthService: Attempting legacy API login...');
    }

    // Second attempt: Legacy partner API login (always attempt, even if mobile login failed)
    try {
      legacyData = await _loginToExternalPartnerApi(email, password);
      legacyLoginSuccess = true;
      print('AuthService: ✅ Legacy API login succeeded');
    } catch (e) {
      print('AuthService: ❌ Legacy API login failed: $e');
    }

    // Determine result based on which APIs succeeded
    if (mobileLoginSuccess && legacyLoginSuccess) {
      // Both succeeded - return response
      print(
          'AuthService: ✅ BOTH mobile and legacy logins succeeded → Navigate to Events Board');
      return loginResponse!;
    } else if (!mobileLoginSuccess &&
        legacyLoginSuccess &&
        legacyData != null) {
      // Only legacy succeeded - create LoginResponse from legacy data
      print(
          'AuthService: ⚠️ Only LEGACY login succeeded → Navigate to Partner Form');

      // Map legacy response to mobile API format
      final legacyLoginResponse = LoginResponse(
        accessToken: legacyData['token'] as String,
        refreshToken: '', // Legacy API doesn't provide refresh token
        user: User(
          id: legacyData['id'].toString(),
          email: legacyData['email'] as String,
          mobile: legacyData['phone_no'] as String? ?? '',
          userType:
              (legacyData['user_type'] as String? ?? 'ADMIN').toLowerCase(),
          status: (legacyData['status'] as String? ?? 'PENDING').toLowerCase(),
          profileComplete: legacyData['profile_complete'] as bool? ?? false,
          loggedInBefore: null, // Legacy API doesn't provide this
        ),
      );

      // Save the legacy token as mobile token for app compatibility
      await _storage.write(
          ApiConstants.mobileAccessTokenKey, legacyData['token'] as String);
      await _storage.write(ApiConstants.userTypeKey,
          legacyData['user_type'] as String? ?? 'ADMIN');
      await _storage.write(
          ApiConstants.userEmailKey, legacyData['email'] as String);

      return legacyLoginResponse;
    } else if (mobileLoginSuccess && !legacyLoginSuccess) {
      // Only mobile succeeded - stay on login screen (should not happen per requirements)
      print(
          'AuthService: ⚠️ Only MOBILE login succeeded → Stay on login screen');
      throw ApiException(
        message:
            'MOBILE_ONLY_SUCCESS: Legacy API authentication failed. Please contact support.',
      );
    } else {
      // Both failed - navigate to become partner screen
      print(
          'AuthService: ❌ BOTH logins failed → Navigate to Become Partner Screen');
      throw ApiException(
        message: 'BOTH_FAILED',
      );
    }
  }

  /// Login to external partner API and save partner token
  /// Returns the legacy API response data if successful
  Future<Map<String, dynamic>?> _loginToExternalPartnerApi(
      String email, String password) async {
    try {
      // Create a separate Dio instance for the external API
      final externalDio = Dio(
        BaseOptions(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );
      // Add a simple log interceptor to see external request/response in console
      externalDio.interceptors.add(
        LogInterceptor(
          request: true,
          requestBody: true,
          responseBody: true,
          requestHeader: true,
        ),
      );

      final response = await externalDio.post(
        _externalPartnerApiUrl,
        data: {
          'email': email,
          'password': password,
        },
      );

      // Extract token from response
      if (response.data != null &&
          response.data['status'] == 'success' &&
          response.data['data'] != null &&
          response.data['data']['token'] != null) {
        final partnerToken = response.data['data']['token'] as String;

        // Save partner token to secure storage under the canonical key
        await _storage.write(ApiConstants.legacyWebAuthTokenKey, partnerToken);

        // Dev: read back partner token and print masked value for verification
        try {
          print('\n=== Legacy Web API Token Saved ===');

          final savedPartner =
              await _storage.read(ApiConstants.legacyWebAuthTokenKey);
          if (savedPartner != null && savedPartner.isNotEmpty) {
            final masked = savedPartner.length > 8
                ? '${savedPartner.substring(0, 4)}...${savedPartner.substring(savedPartner.length - 4)}'
                : '***';
            print('${ApiConstants.legacyWebAuthTokenKey} = $masked');
          } else {
            print('${ApiConstants.legacyWebAuthTokenKey} = NOT FOUND');
          }

          print('===================================\n');
        } catch (e) {
          print(
              'AuthService: error reading legacy partner token after save: $e');
        }

        // Return the legacy response data for use in creating LoginResponse
        return response.data['data'] as Map<String, dynamic>;
      } else {
        // Partner API responded but without success status or token
        print('External partner API login failed: Invalid response structure');
        throw ApiException(
          message:
              'Partner API authentication failed. Please apply to become a partner.',
        );
      }
    } catch (e) {
      // If external API fails, throw error to prevent login from succeeding
      print('External partner API login failed: $e');
      if (e is ApiException) {
        rethrow;
      } else {
        throw ApiException(
          message:
              'Partner API authentication failed. Please apply to become a partner.',
        );
      }
    }
  }

  /// Admin Registration
  Future<AdminRegistrationResponse> registerAdmin({
    required String email,
    required String mobile,
    required String password,
  }) async {
    try {
      final request = AdminRegistrationRequest(
        email: email,
        mobile: mobile,
        password: password,
      );

      final response = await _apiClient.post(
        ApiConstants.authAdminRegister,
        data: request.toJson(),
      );

      return AdminRegistrationResponse.fromJson(response.data);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException.unknown();
    }
  }

  /// Partner Registration - Step 1: Submit Email
  Future<PartnerRegistrationResponse> partnerRegistrationStep1(
    String email,
  ) async {
    try {
      final request = PartnerRegistrationStep1(email: email);

      final response = await _apiClient.post(
        ApiConstants.authPartnerStep1,
        data: request.toJson(),
      );

      return PartnerRegistrationResponse.fromJson(response.data);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException.unknown();
    }
  }

  /// Partner Registration - Step 2: Submit Mobile & Get OTP
  Future<PartnerRegistrationResponse> partnerRegistrationStep2({
    required String email,
    required String mobile,
  }) async {
    try {
      final request = PartnerRegistrationStep2(
        email: email,
        mobile: mobile,
      );

      final response = await _apiClient.post(
        ApiConstants.authPartnerStep2,
        data: request.toJson(),
      );

      return PartnerRegistrationResponse.fromJson(response.data);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException.unknown();
    }
  }

  /// Partner Registration - Step 3: Verify OTP
  Future<PartnerRegistrationResponse> partnerRegistrationStep3({
    required String email,
    required String mobile,
    required String otp,
  }) async {
    try {
      final request = PartnerRegistrationStep3(
        email: email,
        mobile: mobile,
        otp: otp,
      );

      final response = await _apiClient.post(
        ApiConstants.authPartnerStep3,
        data: request.toJson(),
      );

      final registrationResponse =
          PartnerRegistrationResponse.fromJson(response.data);

      // Save tokens if provided
      if (registrationResponse.accessToken != null &&
          registrationResponse.refreshToken != null) {
        await _storage.write(
          ApiConstants.accessTokenKey,
          registrationResponse.accessToken!,
        );
        await _storage.write(
          ApiConstants.refreshTokenKey,
          registrationResponse.refreshToken!,
        );
        await _storage.write(ApiConstants.userTypeKey, 'PARTNER');
        await _storage.write(ApiConstants.userEmailKey, email);
      }

      return registrationResponse;
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException.unknown();
    }
  }

  /// Check Partner Become Status
  /// Returns the status of a partner application by email
  Future<PartnerBecomeStatusResponse> checkPartnerBecomeStatus(
      String email) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.authPartnerBecomeStatus,
        queryParameters: {'email': email},
      );

      return PartnerBecomeStatusResponse.fromJson(response.data);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException.unknown();
    }
  }

  /// Refresh Access Token
  Future<void> refreshToken() async {
    try {
      final refreshToken = await _storage.read(ApiConstants.refreshTokenKey);

      if (refreshToken == null) {
        throw ApiException(message: 'No refresh token found');
      }

      final request = RefreshTokenRequest(refreshToken: refreshToken);

      final response = await _apiClient.post(
        ApiConstants.authRefresh,
        data: request.toJson(),
      );

      final newAccessToken = response.data['accessToken'];
      final newRefreshToken = response.data['refreshToken'];

      await _storage.write(ApiConstants.accessTokenKey, newAccessToken);
      await _storage.write(ApiConstants.refreshTokenKey, newRefreshToken);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException.unknown();
    }
  }

  /// Logout
  Future<void> logout() async {
    await _storage.deleteAll();
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    final accessToken = await _storage.read(ApiConstants.accessTokenKey);
    return accessToken != null && accessToken.isNotEmpty;
  }

  /// Get current user type
  Future<String?> getUserType() async {
    return await _storage.read(ApiConstants.userTypeKey);
  }

  /// Get current user email
  Future<String?> getUserEmail() async {
    return await _storage.read(ApiConstants.userEmailKey);
  }

  /// Get current user ID
  Future<String?> getUserId() async {
    return await _storage.read(ApiConstants.userIdKey);
  }

  /// Get partner token from external API
  Future<String?> getPartnerToken() async {
    return await _storage.read(ApiConstants.legacyWebAuthTokenKey);
  }

  /// Check if partner has accepted agreement
  Future<bool> hasPartnerAcceptedAgreement() async {
    try {
      final response = await _apiClient.get(ApiConstants.adminPartners);

      final userEmail = await getUserEmail();
      if (userEmail == null) return false;

      // Find the partner by email
      final partners = response.data['partners'] as List;
      final partner = partners.firstWhere(
        (p) => p['email'] == userEmail,
        orElse: () => null,
      );

      if (partner == null) return false;

      // Check if agreement is accepted
      return partner['agreementAccepted'] == true;
    } catch (e) {
      // If there's an error, default to false (show forms)
      return false;
    }
  }

  /// Save authentication data
  Future<void> _saveAuthData(LoginResponse loginResponse) async {
    // Save tokens under both the generic legacy keys and the new mobile-specific keys
    // to preserve backward compatibility with existing code that reads ApiConstants.accessTokenKey.
    await _storage.write(
      ApiConstants.accessTokenKey,
      loginResponse.accessToken,
    );
    await _storage.write(
      ApiConstants.refreshTokenKey,
      loginResponse.refreshToken,
    );
    // Mobile-specific keys
    await _storage.write(
      ApiConstants.mobileAccessTokenKey,
      loginResponse.accessToken,
    );
    await _storage.write(
      ApiConstants.mobileRefreshTokenKey,
      loginResponse.refreshToken,
    );
    await _storage.write(
      ApiConstants.userTypeKey,
      loginResponse.userType,
    );
    await _storage.write(
      ApiConstants.userIdKey,
      loginResponse.userId.toString(),
    );
    await _storage.write(
      ApiConstants.userEmailKey,
      loginResponse.email,
    );

    // Save partner-specific data
    await _storage.write(
      'partner_status',
      loginResponse.status,
    );
    await _storage.write(
      'profile_complete',
      loginResponse.profileComplete.toString(),
    );
  }
}
