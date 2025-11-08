import 'package:spotseeker_app/core/api/api_exception.dart';
import 'package:spotseeker_app/core/constants/api_constants.dart';
import 'package:spotseeker_app/models/analytics/analytics_models.dart';
import 'package:spotseeker_app/models/event_model.dart';
import 'package:spotseeker_app/core/storage/secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:spotseeker_app/mocks/partners_finance_mock.dart';

/// Analytics Service
class AnalyticsService {
  final SecureStorage _storage = SecureStorage();

  /// Determine the base URL to use based on event type
  String _getBaseUrl(EventModel? event) {
    if (event != null && event.isLegacyEvent) {
      return ApiConstants.legacyWebApiBaseUrl;
    }
    return ApiConstants.mobileApiBaseUrl;
  }

  /// Get the appropriate auth token for the event
  Future<String?> _getAuthToken(EventModel? event) async {
    if (event != null && event.isLegacyEvent) {
      return await _storage.read(ApiConstants.legacyWebAuthTokenKey);
    }
    return await _storage.read(ApiConstants.mobileAccessTokenKey);
  }

  /// Make an API call with the correct base URL and auth token
  Future<Response> _makeRequest({
    required String endpoint,
    EventModel? event,
    Options? options,
  }) async {
    final baseUrl = _getBaseUrl(event);
    final token = await _getAuthToken(event);

    final dio = Dio();
    final mergedOptions = (options ?? Options()).copyWith(
      headers: {
        ...?options?.headers,
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
    );

    return await dio.get(
      '$baseUrl$endpoint',
      options: mergedOptions,
    );
  }

  /// Make a GET request to the mobile base URL while attaching BOTH tokens:
  /// - Authorization: Bearer <mobile access token>
  /// - partnerToken: <legacy web auth token>
  Future<Response> _makeRequestWithBothTokens({
    required String endpoint,
  }) async {
    final mobileToken = await _storage.read(ApiConstants.mobileAccessTokenKey);
    final legacyToken = await _storage.read(ApiConstants.legacyWebAuthTokenKey);

    final dio = Dio();
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (mobileToken != null && mobileToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer $mobileToken';
    }
    if (legacyToken != null && legacyToken.isNotEmpty) {
      headers['spotseekerToken'] = legacyToken;
    }

    return await dio.get(
      '${ApiConstants.mobileApiBaseUrl}$endpoint',
      options: Options(headers: headers),
    );
  }

  /// Get Event Overview derived from basicFinance payload
  Future<EventOverview> getEventOverview(int eventId,
      {EventModel? event}) async {
    try {
      // Prefer external_event_id for partner events
      final int idToUse = event?.externalEventId != null
          ? int.tryParse(event!.externalEventId!.toString()) ?? eventId
          : eventId;

      final response = await _makeRequestWithBothTokens(
        endpoint: ApiConstants.basicFinance(idToUse),
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        // total revenue
        final double totalSales = () {
          if (data['ticket_sales_sum_tot_amount'] is num) {
            return (data['ticket_sales_sum_tot_amount'] as num).toDouble();
          }
          final v = data['tot_sale']?.toString().replaceAll(',', '') ?? '0';
          return double.tryParse(v) ?? 0.0;
        }();

        // tickets sold and capacity
        final int ticketsSold = () {
          if (data['ticket_sales_sum_tot_ticket_count'] is num) {
            return (data['ticket_sales_sum_tot_ticket_count'] as num).toInt();
          }
          final pkgs = data['ticket_packages'];
          if (pkgs is List) {
            final sum = pkgs
                .whereType<Map<String, dynamic>>()
                .map((p) => p['sold_ticket_counts'])
                .map((v) => v is num
                    ? v.toInt()
                    : int.tryParse(v?.toString() ?? '0') ?? 0)
                .fold<int>(0, (a, b) => a + b);
            if (sum > 0) return sum;
          }
          if (data['completed_bookings'] is num) {
            return (data['completed_bookings'] as num).toInt();
          }
          return 0;
        }();

        final int totalCapacity = () {
          final pkgs = data['ticket_packages'];
          if (pkgs is List) {
            return pkgs
                .whereType<Map<String, dynamic>>()
                .map((p) => p['tot_tickets'])
                .map((v) => v is num
                    ? v.toInt()
                    : int.tryParse(v?.toString() ?? '0') ?? 0)
                .fold<int>(0, (a, b) => a + b);
          }
          return 0;
        }();

        final int totalCheckIns = () {
          final ls = data['liveStats'];
          if (ls is Map && ls['fansInside'] != null) {
            final v = ls['fansInside'];
            return v is num ? v.toInt() : int.tryParse(v.toString()) ?? 0;
          }
          return 0;
        }();

        // invites via zero-amount or invitation comment
        final int invites = () {
          final ts = data['ticket_sales'];
          if (ts is List) {
            return ts
                .whereType<Map<String, dynamic>>()
                .where((m) =>
                    (m['comment']?.toString().toLowerCase() ?? '')
                        .contains('invitation') ||
                    ((m['tot_amount'] is num) && (m['tot_amount'] as num) == 0))
                .length;
          }
          return 0;
        }();

        // Revenue chart buckets from sales_by_date
        Map<String, dynamic> additionalStats = {};
        final sbd = data['sales_by_date'];
        if (sbd is Map) {
          final entries = sbd.entries
              .map((e) => MapEntry(
                  e.key.toString(),
                  e.value is num
                      ? (e.value as num).toDouble()
                      : double.tryParse(e.value.toString()) ?? 0.0))
              .toList()
            ..sort((a, b) => a.key.compareTo(b.key));
          final values = entries.map((e) => e.value).toList();
          for (int i = 0; i < 5; i++) {
            additionalStats['week${i + 1}Revenue'] =
                (i < values.length) ? values[i] : 0.0;
          }
        } else {
          for (int i = 1; i <= 5; i++) {
            additionalStats['week${i}Revenue'] = 0.0;
          }
        }

        // Booking bars from tickets_count_by_date or package/day totals
        final tcb = data['tickets_count_by_date'];
        List<int> ticketCounts = [];
        if (tcb is Map) {
          ticketCounts = tcb.values
              .map(
                  (v) => v is num ? v.toInt() : int.tryParse(v.toString()) ?? 0)
              .toList();
        } else {
          final spd = data['tickets_count_by_package_and_date'];
          if (spd is Map) {
            final totalsPerDay = spd.values.map((pkgMap) {
              if (pkgMap is Map) {
                return pkgMap.values
                    .map((v) =>
                        v is num ? v.toInt() : int.tryParse(v.toString()) ?? 0)
                    .fold<int>(0, (a, b) => a + b);
              }
              return 0;
            }).toList();
            ticketCounts = totalsPerDay;
          }
        }
        for (int i = 0; i < 6; i++) {
          additionalStats['tier${i + 1}TicketsSold'] =
              (i < ticketCounts.length) ? ticketCounts[i].toDouble() : 0.0;
        }

        additionalStats['attendanceBreakdown'] = {
          'onlineTickets': ticketsSold,
          'spotseekerInvites': invites,
          'specialInvites': 0,
        };
        final double completion =
            (totalCapacity > 0) ? (ticketsSold / totalCapacity) : 0.0;
        additionalStats['salesSummary'] = {
          'ticketsSold': ticketsSold,
          'completionPercentage': completion,
        };

        return EventOverview(
          totalTicketsSold: ticketsSold,
          totalRevenue: totalSales,
          totalCheckIns: totalCheckIns,
          remainingTickets: (totalCapacity - ticketsSold) > 0
              ? (totalCapacity - ticketsSold)
              : 0,
          additionalStats: additionalStats,
        );
      }

      // Fallback
      return EventOverview(
        totalTicketsSold: 0,
        totalRevenue: 0.0,
        totalCheckIns: 0,
        remainingTickets: 0,
        additionalStats: const {},
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException.unknown();
    }
  }

  /// Get Live Stats
  Future<LiveStats> getLiveStats(int eventId, {EventModel? event}) async {
    try {
      final response = await _makeRequest(
        endpoint: ApiConstants.eventLiveStats(eventId),
        event: event,
      );

      // The backend may return multiple shapes. Example 1 (existing):
      // {
      //   currentCheckIns: ..., liveAttendance: ..., realtimeRevenue: ..., breakdown: {...}
      // }
      // Example 2 (partner API):
      // {
      //   totalAttendees: 0,
      //   insideCount: 0,
      //   toComeCount: 0,
      //   attendanceByPackage: [...],
      //   scanInsights: {...},
      // }
      final data = response.data;
      if (data is Map && data.containsKey('totalAttendees')) {
        // Map partner response to our LiveStats model
        final int liveAttendance = (data['totalAttendees'] is int)
            ? data['totalAttendees'] as int
            : int.tryParse(data['totalAttendees']?.toString() ?? '') ?? 0;
        final int currentCheckIns = (data['insideCount'] is int)
            ? data['insideCount'] as int
            : int.tryParse(data['insideCount']?.toString() ?? '') ?? 0;
        // Build a lightweight breakdown map combining useful fields
        final Map<String, dynamic> breakdown = {
          'attendanceByPackage': data['attendanceByPackage'] ?? [],
          'scanInsights': data['scanInsights'] ?? {},
          'fraudulentAlerts': data['fraudulentAlerts'] ?? [],
          'audienceDemographics': data['audienceDemographics'] ?? {},
        };

        return LiveStats(
          currentCheckIns: currentCheckIns,
          liveAttendance: liveAttendance,
          realtimeRevenue: 0.0,
          breakdown: breakdown,
        );
      }

      // Fallback to generated deserialization for the standard shape
      return LiveStats.fromJson(response.data);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException.unknown();
    }
  }

  /// Get Finance Sales
  Future<FinanceSales> getFinanceSales(int eventId, {EventModel? event}) async {
    try {
      final response = await _makeRequest(
        endpoint: ApiConstants.eventFinanceSales(eventId),
        event: event,
      );

      return FinanceSales.fromJson(response.data);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException.unknown();
    }
  }

  /// Get Basic Finance (alternate endpoint `/api/finance/{id}`)
  Future<FinanceSales> getBasicFinance(int eventId, {EventModel? event}) async {
    try {
      final int idToUse = event?.externalEventId != null
          ? int.tryParse(event!.externalEventId!.toString()) ?? eventId
          : eventId;

      final response = await _makeRequestWithBothTokens(
        endpoint: ApiConstants.basicFinance(idToUse),
      );

      return FinanceSales.fromJson(response.data);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException.unknown();
    }
  }

  /// Get Partners/Manager Finance summary
  /// This calls `/api/partners/finance` on the backend. If `partnerToken` is
  /// provided it will be sent as the `partnerToken` header so the backend can
  /// forward it to the external SpotSeeker API.
  Future<List<dynamic>> getPartnersFinance({String? partnerToken}) async {
    // During development we return mock data to avoid depending on the external
    // partners finance API. This makes it quick to prototype front-end UI.
    if (kDebugMode) {
      return partnersFinanceMock;
    }
    try {
      // Use legacy web API if we have a partner token, otherwise use mobile API
      final token = partnerToken ??
          await _storage.read(ApiConstants.legacyWebAuthTokenKey);
      final baseUrl = (token != null && token.isNotEmpty)
          ? ApiConstants.legacyWebApiBaseUrl
          : ApiConstants.mobileApiBaseUrl;

      final dio = Dio();
      final response = await dio.get(
        '$baseUrl${ApiConstants.partnersFinance}',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            if (token != null && token.isNotEmpty)
              'Authorization': 'Bearer $token',
          },
        ),
      );

      // Backend returns { "data": [ ... ] }
      final data = response.data;
      if (data is Map && data.containsKey('data')) {
        return (data['data'] as List<dynamic>?) ?? <dynamic>[];
      }

      // If shape is unexpected, try to return a list if possible
      if (data is List<dynamic>) return data;

      return <dynamic>[];
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException.unknown();
    }
  }

  /// Get Finance Breakdown
  Future<FinanceBreakdown> getFinanceBreakdown(int eventId,
      {EventModel? event}) async {
    try {
      final response = await _makeRequest(
        endpoint: ApiConstants.eventFinanceBreakdown(eventId),
        event: event,
      );

      return FinanceBreakdown.fromJson(response.data);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException.unknown();
    }
  }

  /// Request Withdrawal
  Future<void> requestWithdrawal({
    required int eventId,
    required double amount,
    String? note,
    EventModel? event,
  }) async {
    try {
      final baseUrl = _getBaseUrl(event);
      final token = await _getAuthToken(event);

      final dio = Dio();
      await dio.post(
        '$baseUrl${ApiConstants.eventWithdraw(eventId)}',
        data: {
          'amount': amount,
          if (note != null) 'note': note,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            if (token != null && token.isNotEmpty)
              'Authorization': 'Bearer $token',
          },
        ),
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException.unknown();
    }
  }

  /// Minimal raw finance shape expected by FinanceTab
  Future<Map<String, dynamic>> getFinanceSalesRaw(int eventId,
      {EventModel? event}) async {
    try {
      final sales = await getBasicFinance(eventId, event: event);
      final double total = sales.totalSales;
      return {
        'totalRevenue': total,
        'salesByPackage': (sales.salesByPackage ?? [])
            .map((e) => {
                  'packageName': e.packageName,
                  'revenue': e.revenue,
                  'percentage': total > 0.0 ? (e.revenue / total) * 100.0 : 0.0,
                  'color': '#888888',
                })
            .toList(),
        // Not available from basicFinance; provide empty list
        'packageDetails': <Map<String, dynamic>>[],
      };
    } catch (e) {
      return {
        'totalRevenue': 0.0,
        'salesByPackage': <Map<String, dynamic>>[],
        'packageDetails': <Map<String, dynamic>>[],
      };
    }
  }

  /// Fetch event by id using appropriate base URL/token. Fallback to input event.
  Future<EventModel> getEventById(int eventId, {EventModel? event}) async {
    try {
      final response = await _makeRequest(
        endpoint: ApiConstants.eventById(eventId),
        event: event,
      );
      final body = response.data;
      if (body is Map<String, dynamic>) {
        return EventModel.fromJson(body);
      }
      if (body is Map && body['data'] is Map<String, dynamic>) {
        return EventModel.fromJson(body['data'] as Map<String, dynamic>);
      }
      if (event != null) return event;
      throw ApiException.unknown();
    } catch (_) {
      if (event != null) return event;
      rethrow;
    }
  }

  /// Raw finance breakdown for FinanceTab (safe Map)
  Future<Map<String, dynamic>> getFinanceBreakdownRaw(int eventId,
      {EventModel? event}) async {
    try {
      // Prefer external_event_id
      final int idToUse = event?.externalEventId != null
          ? int.tryParse(event!.externalEventId!.toString()) ?? eventId
          : eventId;
      final response = await _makeRequestWithBothTokens(
        endpoint: ApiConstants.basicFinance(idToUse),
      );
      final data = response.data;
      if (data is! Map<String, dynamic>) return <String, dynamic>{};

      final double totalRevenue = () {
        if (data['ticket_sales_sum_tot_amount'] is num) {
          return (data['ticket_sales_sum_tot_amount'] as num).toDouble();
        }
        final v = data['tot_sale']?.toString().replaceAll(',', '') ?? '0';
        return double.tryParse(v) ?? 0.0;
      }();

      final List<double> revenueTimeline = () {
        final sbd = data['sales_by_date'];
        if (sbd is Map) {
          final entries = sbd.entries
              .map((e) => MapEntry(
                  e.key.toString(),
                  e.value is num
                      ? (e.value as num).toDouble()
                      : double.tryParse(e.value.toString()) ?? 0.0))
              .toList()
            ..sort((a, b) => a.key.compareTo(b.key));
          return entries.map((e) => e.value).toList();
        }
        return <double>[];
      }();

      return <String, dynamic>{
        'totalRevenue': totalRevenue,
        'revenueTimeline': revenueTimeline,
        'withdrawals': <Map<String, dynamic>>[],
      };
    } catch (e) {
      return <String, dynamic>{};
    }
  }

  /// Raw basic finance payload (includes ticket_packages)
  Future<Map<String, dynamic>> getBasicFinanceRaw(int eventId,
      {EventModel? event}) async {
    try {
      final int idToUse = event?.externalEventId != null
          ? int.tryParse(event!.externalEventId!.toString()) ?? eventId
          : eventId;
      final response = await _makeRequestWithBothTokens(
        endpoint: ApiConstants.basicFinance(idToUse),
      );
      final data = response.data;
      if (data is Map<String, dynamic>) return data;
      return <String, dynamic>{};
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  /// Raw withdrawals (mobile) for FinanceTab (safe Map)
  Future<Map<String, dynamic>> getEventWithdrawalsRawMobile(int eventId) async {
    try {
      final baseUrl = ApiConstants.mobileApiBaseUrl;
      final token = await _storage.read(ApiConstants.mobileAccessTokenKey);

      final dio = Dio();
      final response = await dio.get(
        '$baseUrl${ApiConstants.eventWithdrawals(eventId)}',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            if (token != null && token.isNotEmpty)
              'Authorization': 'Bearer $token',
          },
        ),
      );
      final data = response.data;
      if (data is Map<String, dynamic>) return data;
      return <String, dynamic>{};
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  /// Update event minimal fields; falls back to GET if no body
  Future<EventModel> updateEvent(
    int eventId, {
    required Map<String, dynamic> data,
    EventModel? event,
  }) async {
    try {
      final baseUrl = _getBaseUrl(event);
      final token = await _getAuthToken(event);

      final dio = Dio();
      Response response;
      try {
        response = await dio.post(
          '$baseUrl${ApiConstants.eventById(eventId)}',
          data: data,
          options: Options(
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              if (token != null && token.isNotEmpty)
                'Authorization': 'Bearer $token',
            },
          ),
        );
      } on DioException catch (e) {
        if (e.response?.statusCode == 405) {
          response = await dio.put(
            '$baseUrl${ApiConstants.eventById(eventId)}',
            data: data,
            options: Options(
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                if (token != null && token.isNotEmpty)
                  'Authorization': 'Bearer $token',
              },
            ),
          );
        } else {
          rethrow;
        }
      }

      if (response.statusCode == 204 || response.data == null) {
        return await getEventById(eventId, event: event);
      }
      final body = response.data;
      if (body is Map<String, dynamic>) return EventModel.fromJson(body);
      if (body is Map && body['data'] is Map<String, dynamic>) {
        return EventModel.fromJson(body['data'] as Map<String, dynamic>);
      }
      return await getEventById(eventId, event: event);
    } catch (e) {
      if (event != null) return event;
      rethrow;
    }
  }
}
