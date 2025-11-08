import 'package:dio/dio.dart';
import 'package:spotseeker_app/core/constants/api_constants.dart';
import 'package:spotseeker_app/core/storage/secure_storage.dart';

class FinanceService {
  final Dio _dio;
  final SecureStorage _storage;

  FinanceService({Dio? dio, SecureStorage? storage})
      : _dio = dio ?? Dio(),
        _storage = storage ?? SecureStorage();

  Map<String, String> _headers(String? token) => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      };

  Future<List<Map<String, dynamic>>> listBankDetails() async {
    try {
      String? token = await _storage.read(ApiConstants.mobileAccessTokenKey);

      final url = ApiConstants.mobileApiBaseUrl + ApiConstants.bankDetails;
      final resp =
          await _dio.get(url, options: Options(headers: _headers(token)));
      final data = resp.data;
      if (data is List) {
        return data
            .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
            .toList();
      }
      if (data is Map && data['data'] is List) {
        return (data['data'] as List)
            .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
            .toList();
      }
      return <Map<String, dynamic>>[];
    } on DioException {
      // Fallback to legacy token/base if mobile fails (e.g., 500s)
      try {
        final partnerToken =
            await _storage.read(ApiConstants.legacyWebAuthTokenKey);
        final legacyUrl =
            ApiConstants.legacyWebApiBaseUrl + ApiConstants.bankDetails;
        final resp2 = await _dio.get(legacyUrl,
            options: Options(headers: _headers(partnerToken)));
        final data2 = resp2.data;
        if (data2 is List) {
          return data2
              .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
              .toList();
        }
        if (data2 is Map && data2['data'] is List) {
          return (data2['data'] as List)
              .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
              .toList();
        }
        return <Map<String, dynamic>>[];
      } catch (_) {
        return <Map<String, dynamic>>[];
      }
    }
  }

  Future<Map<String, dynamic>> addBankDetails({
    required String bankName,
    required String accountNumber,
    required String accountName,
    String? branch,
  }) async {
    final body = {
      'bankName': bankName,
      'accountNumber': accountNumber,
      'accountName': accountName,
      if (branch != null && branch.isNotEmpty) 'branch': branch,
    };
    // Try mobile API first
    try {
      final token = await _storage.read(ApiConstants.mobileAccessTokenKey);
      final url =
          ApiConstants.mobileApiBaseUrl + ApiConstants.addBankDetails(0);
      try {
        final masked = (token == null || token.isEmpty)
            ? 'EMPTY'
            : (token.length > 8
                ? '${token.substring(0, 4)}...${token.substring(token.length - 4)}'
                : '***');
        print('[FinanceService.addBankDetails] POST Mobile URL: ' + url);
        print('[FinanceService.addBankDetails] Auth: Bearer ' + masked);
        print('[FinanceService.addBankDetails] Body: ' + body.toString());
      } catch (_) {}
      final resp = await _dio.post(url,
          data: body, options: Options(headers: _headers(token)));
      try {
        print('[FinanceService.addBankDetails] Mobile status: ' +
            (resp.statusCode?.toString() ?? 'null'));
        print('[FinanceService.addBankDetails] Mobile resp: ' +
            resp.data.toString());
      } catch (_) {}
      return (resp.data is Map<String, dynamic>)
          ? (resp.data as Map<String, dynamic>)
          : <String, dynamic>{};
    } on DioException catch (e) {
      // Fallback to legacy partner base/token
      final partnerToken =
          await _storage.read(ApiConstants.legacyWebAuthTokenKey);
      final legacyUrl =
          ApiConstants.legacyWebApiBaseUrl + ApiConstants.addBankDetails(0);
      try {
        final masked = (partnerToken == null || partnerToken.isEmpty)
            ? 'EMPTY'
            : (partnerToken.length > 8
                ? '${partnerToken.substring(0, 4)}...${partnerToken.substring(partnerToken.length - 4)}'
                : '***');
        print('[FinanceService.addBankDetails] Mobile failed: ' +
            (e.response?.statusCode?.toString() ?? e.message ?? 'error'));
        print('[FinanceService.addBankDetails] Mobile err body: ' +
            (e.response?.data?.toString() ?? 'null'));
        print('[FinanceService.addBankDetails] POST Legacy URL: ' + legacyUrl);
        print('[FinanceService.addBankDetails] Auth: Bearer ' + masked);
        print('[FinanceService.addBankDetails] Body: ' + body.toString());
      } catch (_) {}
      final resp2 = await _dio.post(legacyUrl,
          data: body, options: Options(headers: _headers(partnerToken)));
      try {
        print('[FinanceService.addBankDetails] Legacy status: ' +
            (resp2.statusCode?.toString() ?? 'null'));
        print('[FinanceService.addBankDetails] Legacy resp: ' +
            resp2.data.toString());
      } catch (_) {}
      return (resp2.data is Map<String, dynamic>)
          ? (resp2.data as Map<String, dynamic>)
          : <String, dynamic>{};
    }
  }

  Future<Map<String, dynamic>> updateBankDetails({
    required int id,
    required String bankName,
    required String accountNumber,
    required String accountName,
    String? branch,
  }) async {
    final token = await _storage.read(ApiConstants.mobileAccessTokenKey);
    final url =
        ApiConstants.mobileApiBaseUrl + '${ApiConstants.bankDetails}/$id';
    final body = {
      'bankName': bankName,
      'accountNumber': accountNumber,
      'accountName': accountName,
      if (branch != null && branch.isNotEmpty) 'branch': branch,
    };
    final resp = await _dio.put(url,
        data: body, options: Options(headers: _headers(token)));
    return (resp.data is Map<String, dynamic>)
        ? (resp.data as Map<String, dynamic>)
        : <String, dynamic>{};
  }

  Future<void> deleteBankDetailsById(int id) async {
    final token = await _storage.read(ApiConstants.mobileAccessTokenKey);
    final url =
        ApiConstants.mobileApiBaseUrl + ApiConstants.deleteBankDetailsById(id);
    await _dio.delete(url, options: Options(headers: _headers(token)));
  }

  Future<void> createWithdrawal({
    required String eventId,
    required double amount,
    required Map<String, dynamic> bankDetails,
    String? note,
  }) async {
    final token = await _storage.read(ApiConstants.mobileAccessTokenKey);
    final url = ApiConstants.mobileApiBaseUrl +
        ApiConstants.partnerWithdraw(int.parse(eventId));
    final body = {
      'amount': amount,
      'bankDetails': {
        'bankName': bankDetails['bankName'],
        'accountNumber': bankDetails['accountNumber'],
        'accountName': bankDetails['accountName'],
        if (bankDetails['branch'] != null && bankDetails['branch'].isNotEmpty)
          'branch': bankDetails['branch'],
      },
      if (note != null && note.isNotEmpty) 'note': note,
    };
    await _dio.post(url,
        data: body, options: Options(headers: _headers(token)));
  }
}
