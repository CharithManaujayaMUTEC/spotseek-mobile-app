import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:spotseeker_app/core/api/api_client.dart';
import 'package:spotseeker_app/core/api/api_exception.dart';
import 'package:spotseeker_app/core/constants/api_constants.dart';
import 'package:spotseeker_app/models/event/event_models_new.dart';

/// Event Service (Refactored to use real API)
class EventServiceNew {
  final ApiClient _apiClient = ApiClient();

  /// Create Event (Multipart with complex JSON)
  Future<EventResponse> createEvent({
    required EventCreate event,
    required File bannerImage,
    required File thumbnailImage,
  }) async {
    try {
      final formData = FormData.fromMap({
        'name': event.name,
        'description': event.description,
        'organizer': event.organizer,
        'manager': event.manager,
        'start_date': event.start_date,
        'end_date': event.end_date,
        'type': event.type,
        'sub_type': event.sub_type,
        'featured': event.featured,
        'free_seating': event.free_seating,
        'venue': event.venue,
        'invoice': jsonEncode(event.invoice.map((e) => e.toJson()).toList()),
        'banner_img': await MultipartFile.fromFile(
          bannerImage.path,
          filename: bannerImage.path.split('/').last,
        ),
        'thumbnail_img': await MultipartFile.fromFile(
          thumbnailImage.path,
          filename: thumbnailImage.path.split('/').last,
        ),
        'sold_out_msg': event.sold_out_msg ?? '',
        'handling_cost': event.handling_cost ?? '',
        'handling_cost_perc': event.handling_cost_perc,
        'currency': event.currency,
        'invitation_feature': event.invitation_feature,
        'invitation_count': event.invitation_count ?? '',
        'invitation_packages': jsonEncode(
          event.invitation_packages?.map((e) => e.toJson()).toList() ?? [],
        ),
        'addons_feature': event.addons_feature,
        'addons': jsonEncode(
          event.addons?.map((e) => e.toJson()).toList() ?? [],
        ),
        'trailer_url': event.trailer_url ?? '',
        'payment_gateways': jsonEncode(
          event.payment_gateways.map((e) => e.toJson()).toList(),
        ),
        'analytics_ids': jsonEncode(event.analytics_ids),
      });

      final response = await _apiClient.postMultipart(
        ApiConstants.events,
        formData: formData,
      );

      return EventResponse.fromJson(response.data);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException.unknown();
    }
  }

  /// Update Event
  Future<EventResponse> updateEvent({
    required int eventId,
    required EventCreate event,
    File? bannerImage,
    File? thumbnailImage,
  }) async {
    try {
      final Map<String, dynamic> formDataMap = {
        'name': event.name,
        'description': event.description,
        'organizer': event.organizer,
        'manager': event.manager,
        'start_date': event.start_date,
        'end_date': event.end_date,
        'type': event.type,
        'sub_type': event.sub_type,
        'featured': event.featured,
        'free_seating': event.free_seating,
        'venue': event.venue,
        'invoice': jsonEncode(event.invoice.map((e) => e.toJson()).toList()),
        'sold_out_msg': event.sold_out_msg ?? '',
        'handling_cost': event.handling_cost ?? '',
        'handling_cost_perc': event.handling_cost_perc,
        'currency': event.currency,
        'invitation_feature': event.invitation_feature,
        'invitation_count': event.invitation_count ?? '',
        'invitation_packages': jsonEncode(
          event.invitation_packages?.map((e) => e.toJson()).toList() ?? [],
        ),
        'addons_feature': event.addons_feature,
        'addons': jsonEncode(
          event.addons?.map((e) => e.toJson()).toList() ?? [],
        ),
        'trailer_url': event.trailer_url ?? '',
        'payment_gateways': jsonEncode(
          event.payment_gateways.map((e) => e.toJson()).toList(),
        ),
        'analytics_ids': jsonEncode(event.analytics_ids),
      };

      if (bannerImage != null) {
        formDataMap['banner_img'] = await MultipartFile.fromFile(
          bannerImage.path,
          filename: bannerImage.path.split('/').last,
        );
      }

      if (thumbnailImage != null) {
        formDataMap['thumbnail_img'] = await MultipartFile.fromFile(
          thumbnailImage.path,
          filename: thumbnailImage.path.split('/').last,
        );
      }

      final formData = FormData.fromMap(formDataMap);

      final response = await _apiClient.putMultipart(
        ApiConstants.eventById(eventId),
        formData: formData,
      );

      return EventResponse.fromJson(response.data);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException.unknown();
    }
  }

  /// Get All Events (with pagination)
  Future<PaginatedEventsResponse> getEvents({
    int page = 0,
    int limit = 10,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.events,
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      return PaginatedEventsResponse.fromJson(response.data);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException.unknown();
    }
  }

  /// Get Event by ID
  Future<EventResponse> getEventById(int eventId) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.eventById(eventId),
      );

      return EventResponse.fromJson(response.data);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException.unknown();
    }
  }

  /// Delete Event
  Future<void> deleteEvent(int eventId) async {
    try {
      await _apiClient.delete(ApiConstants.eventById(eventId));
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException.unknown();
    }
  }
}
