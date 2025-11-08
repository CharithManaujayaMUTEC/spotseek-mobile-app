# Dual API Integration - Mobile & Legacy Web APIs

## Overview
This document describes the implementation of dual API support for handling events from both:
1. **Mobile API** (SpringBoot backend at `http://192.168.8.142:8081`)
2. **Legacy Web API** (Original SpotSeeker backend at `https://uatapi.spotseeker.lk`)

## Problem Statement
The application needs to support events coming from two different backend systems:
- Events created in the mobile API (event 10) - identifiable by `external_event_id` being `null`
- Events synced from the legacy web API (event 46) - identifiable by having an `external_event_id`

Each backend requires different:
- Base URLs
- Authentication tokens
- API endpoints (though paths are similar)

## Solution Architecture

### 1. Event Source Identification
**File**: `lib/models/event_model.dart`

Added fields to identify event source:
```dart
final String? externalEventId;

/// Returns true if this event is from the legacy web API
bool get isLegacyEvent => externalEventId != null && externalEventId!.isNotEmpty;
```

Events with an `external_event_id` are from the legacy web API, others are from the mobile API.

### 2. API Constants
**File**: `lib/core/constants/api_constants.dart`

Defined two base URLs:
```dart
// Mobile API (SpringBoot)
static const String mobileApiBaseUrl = 'http://192.168.8.142:8081';

// Legacy Web API  
static const String legacyWebApiBaseUrl = 'https://uatapi.spotseeker.lk';
```

And corresponding token storage keys:
```dart
// Mobile API tokens
static const String mobileAccessTokenKey = 'mobile_access_token';
static const String mobileRefreshTokenKey = 'mobile_refresh_token';

// Legacy Web API tokens
static const String legacyWebAuthTokenKey = 'legacy_web_auth_token';
static const String legacyWebRefreshTokenKey = 'legacy_web_refresh_token';
```

### 3. Analytics Service Updates
**File**: `lib/services/analytics_service.dart`

#### Base URL Selection
```dart
String _getBaseUrl(EventModel? event) {
  if (event != null && event.isLegacyEvent) {
    return ApiConstants.legacyWebApiBaseUrl;
  }
  return ApiConstants.mobileApiBaseUrl;
}
```

#### Token Selection
```dart
Future<String?> _getAuthToken(EventModel? event) async {
  if (event != null && event.isLegacyEvent) {
    return await _storage.read(ApiConstants.legacyWebAuthTokenKey);
  }
  return await _storage.read(ApiConstants.mobileAccessTokenKey);
}
```

#### Dynamic API Calls
```dart
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
```

#### Updated Service Methods
All analytics methods now accept an optional `EventModel? event` parameter:
- `getEventOverview(int eventId, {EventModel? event})`
- `getLiveStats(int eventId, {EventModel? event})`
- `getFinanceSales(int eventId, {EventModel? event})`
- `getBasicFinance(int eventId, {EventModel? event})`
- `getFinanceBreakdown(int eventId, {EventModel? event})`
- `requestWithdrawal({required int eventId, required double amount, String? note, EventModel? event})`

### 4. Partners Finance Endpoint
Special handling for the partners/finance endpoint:
```dart
Future<List<dynamic>> getPartnersFinance({String? partnerToken}) async {
  final token = partnerToken ?? await _storage.read(ApiConstants.legacyWebAuthTokenKey);
  final baseUrl = (token != null && token.isNotEmpty) 
      ? ApiConstants.legacyWebApiBaseUrl 
      : ApiConstants.mobileApiBaseUrl;
  
  // Makes request to appropriate base URL
}
```

### 5. Provider Updates
**File**: `lib/providers/analytics_provider.dart`

Created a parameter class to pass both event ID and model:
```dart
class EventAnalyticsParams {
  final int eventId;
  final EventModel? event;

  const EventAnalyticsParams({
    required this.eventId,
    this.event,
  });
}
```

Updated providers to use the new parameter:
```dart
final financeSalesProvider = FutureProvider.family<FinanceSales, EventAnalyticsParams>(
  (ref, params) async {
    final analyticsService = ref.watch(analyticsServiceProvider);
    return await analyticsService.getFinanceSales(params.eventId, event: params.event);
  },
);
```

### 6. UI Integration
**File**: `lib/screens/events/dashboard_tabs/overview_tab.dart`

Updated to pass event model to service calls:
```dart
sales = await _analyticsService.getBasicFinance(
  widget.event.id, 
  event: widget.event  // Pass the event for API routing
);

LiveStats live = await _analyticsService.getLiveStats(
  widget.event.id, 
  event: widget.event
);
```

## API Endpoints

### Mobile API Endpoints
All endpoints use base URL: `http://192.168.8.142:8081`

| Endpoint | Method | Auth |
|----------|--------|------|
| `/api/events/partner?page=0&limit=10` | GET | Bearer (mobile_access_token) |
| `/api/finance/{id}` | GET | Bearer (mobile_access_token) |
| `/api/events/{id}/finance/sales` | GET | Bearer (mobile_access_token) |
| `/api/events/{id}/live-stats` | GET | Bearer (mobile_access_token) |

### Legacy Web API Endpoints
All endpoints use base URL: `https://uatapi.spotseeker.lk`

| Endpoint | Method | Auth |
|----------|--------|------|
| `/api/finance/{id}` | GET | Bearer (legacy_web_auth_token) |
| `/api/partners/finance` | GET | Bearer (legacy_web_auth_token) |
| `/api/events/{id}/live-stats` | GET | Bearer (legacy_web_auth_token) |

## Authentication Flow

### Mobile API Login
1. Login at `/api/auth/login`
2. Receive `accessToken` and `refreshToken`
3. Store as `mobile_access_token` and `mobile_refresh_token`

### Legacy Web API Login
1. Login at `/api/login` (different path!)
2. Receive token (format: `{ "data": { "token": "..." } }`)
3. Store as `legacy_web_auth_token`

## Testing

### Mobile API Event (ID: 10)
- No `external_event_id`
- Uses `http://192.168.8.142:8081`
- Uses `mobile_access_token`
- Should successfully load finance data

### Legacy API Event (ID: 46)
- Has `external_event_id` value
- Uses `https://uatapi.spotseeker.lk`
- Uses `legacy_web_auth_token`
- Should successfully load finance data

## Logging
The implementation includes extensive logging:
```
OverviewTab: trying getBasicFinance for event 46
OverviewTab: getBasicFinance succeeded/failed
```

This helps track which API is being called and whether it succeeds.

## Future Improvements

1. **Error Handling**: Add more specific error messages for API-specific failures
2. **Caching**: Implement caching strategy for frequently accessed data
3. **Migration**: Plan for eventual migration of all events to single API
4. **Monitoring**: Add analytics to track API usage patterns
5. **Token Refresh**: Implement automatic token refresh for legacy API

## Migration Path

When all events are migrated to the mobile API:
1. Remove `external_event_id` field checks
2. Remove legacy API base URL constant
3. Remove legacy token storage keys
4. Simplify `_getBaseUrl()` and `_getAuthToken()` methods
5. Remove dual API logic from analytics service
