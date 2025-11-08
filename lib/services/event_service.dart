import 'package:dio/dio.dart';
import 'package:spotseeker_app/models/event_model.dart';
import 'package:spotseeker_app/core/storage/secure_storage.dart';
import 'package:spotseeker_app/core/constants/api_constants.dart';

/// Response model for paginated events
class EventsResponse {
  final int total;
  final int limit;
  final int page;
  final List<EventModel> events;

  EventsResponse({
    required this.total,
    required this.limit,
    required this.page,
    required this.events,
  });
}

class EventService {
  static final SecureStorage _storage = SecureStorage();

  /// Fetch events from API using both access token and partner token
  /// Supports pagination with page and limit parameters
  static Future<EventsResponse> loadEventsWithPagination({
    int page = 0,
    int limit = 10,
  }) async {
    try {
      // Get tokens from secure storage
      final accessToken = await _storage.read(ApiConstants.accessTokenKey);
      final partnerToken =
          await _storage.read(ApiConstants.legacyWebAuthTokenKey);

      if (accessToken == null || accessToken.isEmpty) {
        print('EventService: No access token found');
        return EventsResponse(total: 0, limit: limit, page: page, events: []);
      }

      // Create Dio instance for API call
      final dio = Dio();

      final response = await dio.get(
        '${ApiConstants.mobileApiBaseUrl}/api/events/partner',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $accessToken',
            if (partnerToken != null && partnerToken.isNotEmpty)
              'spotseekerToken': partnerToken,
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final events = data['events'] as List<dynamic>?;

        return EventsResponse(
          total: data['total'] as int? ?? 0,
          limit: data['limit'] as int? ?? limit,
          page: data['page'] as int? ?? page,
          events:
              events?.map((json) => EventModel.fromJson(json)).toList() ?? [],
        );
      }

      return EventsResponse(total: 0, limit: limit, page: page, events: []);
    } catch (e, st) {
      print('EventService.loadEventsWithPagination error: $e\n$st');
      return EventsResponse(total: 0, limit: limit, page: page, events: []);
    }
  }

  /// Legacy method for backward compatibility - loads all events from first page
  static Future<List<EventModel>> loadEvents() async {
    final response = await loadEventsWithPagination(page: 0, limit: 100);
    return response.events;
  }

  /// Create new event
  static Future<Map<String, dynamic>> createEvent({
    required String name,
    required String description,
    required String organizer,
    required String manager,
    required String startDate,
    required String endDate,
    required String type,
    required String subType,
    required bool featured,
    required bool freeSeating,
    required String venue,
    required String invoice,
    String? bannerImgPath,
    String? thumbnailImgPath,
    String soldOutMsg = '',
    String handlingCost = '',
    bool handlingCostPerc = false,
    String currency = 'LKR',
    bool invitationFeature = false,
    String invitationCount = '',
    String invitationPackages =
        '[{"packageName":"","packageDesc":"","packageQty":"","packageAvailQty":"","packageSoldQty":"","packageAllocSeats":"","active":true,"deleted":false,"packageFreeSeating":true}]',
    bool addonsFeature = false,
    String addons =
        '[{"addonName":"","addonCategory":"","addonPrice":"","deleted":false}]',
    String trailerUrl = '',
    String paymentGateways =
        '[{"id":"","name":"","commission_rate":0,"apply_handling_fee":true,"deleted":false}]',
    String analyticsIds = '[]',
  }) async {
    try {
      // Get access token
      final accessToken = await _storage.read(ApiConstants.accessTokenKey);

      if (accessToken == null || accessToken.isEmpty) {
        throw Exception('No access token found');
      }

      // Create form data
      final formData = FormData.fromMap({
        'name': name,
        'description': description,
        'organizer': organizer,
        'manager': manager,
        'start_date': startDate,
        'end_date': endDate,
        'type': type,
        'sub_type': subType,
        'featured': featured.toString(),
        'free_seating': freeSeating.toString(),
        'venue': venue,
        'invoice': invoice,
        'sold_out_msg': soldOutMsg,
        'handling_cost': handlingCost,
        'handling_cost_perc': handlingCostPerc.toString(),
        'currency': currency,
        'invitation_feature': invitationFeature.toString(),
        'invitation_count': invitationCount,
        'invitation_packages': invitationPackages,
        'addons_feature': addonsFeature.toString(),
        'addons': addons,
        'trailer_url': trailerUrl,
        'payment_gateways': paymentGateways,
        'analytics_ids': analyticsIds,
      });

      // Add image files if provided
      if (bannerImgPath != null && bannerImgPath.isNotEmpty) {
        formData.files.add(MapEntry(
          'banner_img',
          await MultipartFile.fromFile(bannerImgPath),
        ));
      }

      if (thumbnailImgPath != null && thumbnailImgPath.isNotEmpty) {
        formData.files.add(MapEntry(
          'thumbnail_img',
          await MultipartFile.fromFile(thumbnailImgPath),
        ));
      }

      // Create Dio instance for API call
      final dio = Dio();

      final response = await dio.post(
        '${ApiConstants.mobileApiBaseUrl}/api/events',
        data: formData,
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to create event: ${response.statusCode}');
      }
    } catch (e, st) {
      print('EventService.createEvent error: $e\n$st');
      rethrow;
    }
  }

  // Filter events by category
  static List<EventModel> filterEventsByCategory(
      List<EventModel> events, String category) {
    if (category.toLowerCase() == 'all events') {
      return events;
    } else if (category.toLowerCase() == 'active events') {
      return events.where((event) => event.category == 'active').toList();
    } else if (category.toLowerCase() == 'inactive events') {
      return events.where((event) => event.category == 'inactive').toList();
    } else if (category.toLowerCase() == 'pending approval') {
      return events.where((event) => event.category == 'pending').toList();
    }
    return events;
  }
}
