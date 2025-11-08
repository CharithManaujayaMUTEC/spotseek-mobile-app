/// API Configuration Constants
class ApiConstants {
  // Base URL - Change this for different environments
  // Production: AWS Elastic Beanstalk
  // static const String baseUrl = String.fromEnvironment(
  //   'BASE_URL',
  //   defaultValue: 'https://friendly-garbanzo-pjjvw4w9x4rwfrvrx-8081.app.github.dev',
  // );

  // Explicit commonly-used base URLs (used by frontend/backends in the project)
  // Local dev / mobile (SpringBoot) backend (used in Postman collection /login example)
  // For physical device: use your PC's local network IP (192.168.8.142)
  // For emulator: use 10.0.2.2 (Android) or localhost (iOS)
  // static const String mobileApiBaseUrl =
  //     'http://copilot-backend-env-1.eba-ytkhpj3z.ap-south-1.elasticbeanstalk.com';
  static const String mobileApiBaseUrl =
      'https://sbh3fg3j-8081.asse.devtunnels.ms';

  // Legacy UAT / Web backend (Spotseeker original backend)
  // NOTE: the `/api` prefix is added by `apiVersion` when building endpoints below.
  static const String legacyWebApiBaseUrl = 'https://uatapi.spotseeker.lk';

  // Timeout durations
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  // API Version
  static const String apiVersion = '/api';

  // Auth Endpoints
  // Common login path (append to whichever base URL you call)
  static const String authLogin = '$apiVersion/auth/login';
  // Legacy web login path (legacy UAT/web API uses a different login path)
  static const String legacyWebLogin = '$apiVersion/login';
  static const String authRefresh = '$apiVersion/auth/refresh';
  static const String authAdminRegister = '$apiVersion/auth/admin/register';
  static const String authPartnerStep1 =
      '$apiVersion/auth/partner/register/step1-email';
  static const String authPartnerStep2 =
      '$apiVersion/auth/partner/register/step2-mobile';
  static const String authPartnerStep3 =
      '$apiVersion/auth/partner/register/step3-verify-otp';
  static const String authPartnerBecomeStatus =
      '$apiVersion/auth/partner/become/status';

  // Partner Endpoints
  static const String partnerCompanyProfile =
      '$apiVersion/partner/company-profile';
  static const String partnerOrganizerInfo =
      '$apiVersion/partner/organizer-info';
  static const String partnerAgreement = '$apiVersion/partner/agreement';
  static const String partnerApplicationStatusUpdate =
      '$apiVersion/partners/application-status';
  static const String partnerProfile =
      '$apiVersion/partner/me'; // Get current partner's profile

  // Events Endpoints
  static const String events = '$apiVersion/manager/events';
  static String eventById(int id) => '$events/$id';
  static String eventOverview(int id) => '$events/$id/overview';
  static String eventLiveStats(int id) => '$events/$id/live-stats';
  static String eventFinanceSales(int id) => '$events/$id/finance/sales';
  static String eventFinanceBreakdown(int id) =>
      '$events/$id/finance/breakdown';
  static String eventWithdraw(int id) => '$events/$id/finance/withdraw';
  static String eventWithdrawals(int id) =>
      '$apiVersion/events/$id/withdrawals';

  // Basic finance endpoint (alternate)
  static String basicFinance(int id) => '$apiVersion/finance/$id';
  // Partners finance endpoint (manager/partner sales proxy)
  static const String partnersFinance = '$apiVersion/partners/finance';
  static String eventGenerateTicketQR(int id) =>
      '$events/$id/generate-ticket-qr';

  // Tickets Endpoints
  static const String ticketsVerify = '$apiVersion/tickets/verify';

  // File Upload Endpoints
  static const String upload = '$apiVersion/upload';
  static String deleteFile(String fileId) => '$upload/$fileId';

  // Admin Endpoints
  static const String adminPartnerRequests =
      '$apiVersion/admin/partner-requests';
  static const String adminPartnerRequestsApprove =
      '$apiVersion/admin/partner-requests/approve';
  static const String adminPartners = '$apiVersion/admin/partners';
  static String adminPartnerStatus(int id) => '$adminPartners/$id/status';
  static const String adminEvents = '$apiVersion/admin/events';
  static String adminEventReview(int id) => '$adminEvents/$id/review';
  static String adminEventMarkInactive(int id) =>
      '$adminEvents/$id/mark-inactive';
  static const String adminTicketPackages = '$apiVersion/admin/ticket-packages';
  static String adminTicketPackageReview(int id) =>
      '$adminTicketPackages/$id/review';

  static String partnerWithdraw(int id) => '$apiVersion/partners/withdraw/$id';
  static const String bankDetails = '$apiVersion/bank-details';
  static String deleteBankDetailsById(int id) => '$apiVersion/bank-details/$id';
  static String addBankDetails(int id) => '$apiVersion/bank-details/create';
  // Storage Keys

  // Generic storage keys (legacy / general usage)
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userTypeKey = 'user_type';
  static const String userIdKey = 'user_id';
  static const String userEmailKey = 'user_email';

  // Explicit token keys for the two login calls the frontend may make.
  // 1) Mobile / SpringBoot API (local)
  static const String mobileAccessTokenKey = 'mobile_access_token';
  static const String mobileRefreshTokenKey = 'mobile_refresh_token';

  // 2) Legacy UAT / Web API
  // Store the legacy web auth token (example response uses `data.token`).
  static const String legacyWebAuthTokenKey = 'legacy_web_auth_token';
  // Optional refresh token key for legacy web API (if provided later)
  static const String legacyWebRefreshTokenKey = 'legacy_web_refresh_token';
}
