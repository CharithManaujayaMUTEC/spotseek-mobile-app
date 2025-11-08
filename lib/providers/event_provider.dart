import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spotseeker_app/models/event/event_models_new.dart';
import 'package:spotseeker_app/services/event_service_new.dart';

/// Event Service Provider
final eventServiceProvider = Provider<EventServiceNew>((ref) {
  return EventServiceNew();
});

/// Events List Provider (with pagination)
final eventsProvider = FutureProvider.family<PaginatedEventsResponse, EventsQueryParams>(
  (ref, params) async {
    final eventService = ref.watch(eventServiceProvider);
    return await eventService.getEvents(
      page: params.page,
      limit: params.limit,
    );
  },
);

/// Single Event Provider
final eventByIdProvider = FutureProvider.family<EventResponse, int>(
  (ref, eventId) async {
    final eventService = ref.watch(eventServiceProvider);
    return await eventService.getEventById(eventId);
  },
);

/// Events Query Parameters
class EventsQueryParams {
  final int page;
  final int limit;

  EventsQueryParams({
    this.page = 0,
    this.limit = 10,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventsQueryParams &&
          runtimeType == other.runtimeType &&
          page == other.page &&
          limit == other.limit;

  @override
  int get hashCode => page.hashCode ^ limit.hashCode;
}
