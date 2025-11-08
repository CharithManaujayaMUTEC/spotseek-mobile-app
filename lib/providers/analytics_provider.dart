import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spotseeker_app/models/analytics/analytics_models.dart';
import 'package:spotseeker_app/models/event_model.dart';
import 'package:spotseeker_app/services/analytics_service.dart';

/// Analytics Service Provider
final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService();
});

/// Parameters for event-related analytics
class EventAnalyticsParams {
  final int eventId;
  final EventModel? event;

  const EventAnalyticsParams({
    required this.eventId,
    this.event,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventAnalyticsParams &&
          runtimeType == other.runtimeType &&
          eventId == other.eventId;

  @override
  int get hashCode => eventId.hashCode;
}

/// Event Overview Provider
final eventOverviewProvider = FutureProvider.family<EventOverview, EventAnalyticsParams>(
  (ref, params) async {
    final analyticsService = ref.watch(analyticsServiceProvider);
    return await analyticsService.getEventOverview(params.eventId, event: params.event);
  },
);

/// Live Stats Provider
final liveStatsProvider = FutureProvider.family<LiveStats, EventAnalyticsParams>(
  (ref, params) async {
    final analyticsService = ref.watch(analyticsServiceProvider);
    return await analyticsService.getLiveStats(params.eventId, event: params.event);
  },
);

/// Finance Sales Provider
final financeSalesProvider = FutureProvider.family<FinanceSales, EventAnalyticsParams>(
  (ref, params) async {
    final analyticsService = ref.watch(analyticsServiceProvider);
    return await analyticsService.getFinanceSales(params.eventId, event: params.event);
  },
);

/// Finance Breakdown Provider
final financeBreakdownProvider = FutureProvider.family<FinanceBreakdown, EventAnalyticsParams>(
  (ref, params) async {
    final analyticsService = ref.watch(analyticsServiceProvider);
    return await analyticsService.getFinanceBreakdown(params.eventId, event: params.event);
  },
);
