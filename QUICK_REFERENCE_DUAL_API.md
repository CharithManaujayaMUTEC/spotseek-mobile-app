# Quick Reference: Using Analytics Service with Dual APIs

## For Developers

### When to Pass the Event Model

**Always** pass the `event` parameter when calling analytics service methods if you have access to the `EventModel`:

```dart
// ✅ GOOD - Passes event for proper API routing
final sales = await analyticsService.getFinanceSales(
  eventId, 
  event: myEvent,
);

// ⚠️ WORKS BUT NOT IDEAL - Defaults to mobile API
final sales = await analyticsService.getFinanceSales(eventId);
```

### Using Providers

When using Riverpod providers, create `EventAnalyticsParams`:

```dart
// Create params with event
final params = EventAnalyticsParams(
  eventId: event.id,
  event: event,  // Optional but recommended
);

// Use with provider
final salesAsync = ref.watch(financeSalesProvider(params));
```

### Checking Event Source

```dart
// Check if event is from legacy API
if (event.isLegacyEvent) {
  print('This event is from the legacy web API');
} else {
  print('This event is from the mobile API');
}

// Access the external event ID
final externalId = event.externalEventId; // null for mobile events
```

### Common Patterns

#### Pattern 1: Loading Event Analytics
```dart
class MyEventWidget extends StatefulWidget {
  final EventModel event;
  
  @override
  State<MyEventWidget> createState() => _MyEventWidgetState();
}

class _MyEventWidgetState extends State<MyEventWidget> {
  final _analyticsService = AnalyticsService();
  
  Future<void> loadData() async {
    // Always pass the event
    final stats = await _analyticsService.getLiveStats(
      widget.event.id,
      event: widget.event,
    );
    
    final sales = await _analyticsService.getFinanceSales(
      widget.event.id,
      event: widget.event,
    );
  }
}
```

#### Pattern 2: Using with Riverpod
```dart
class MyEventWidget extends ConsumerWidget {
  final EventModel event;
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final params = EventAnalyticsParams(
      eventId: event.id,
      event: event,
    );
    
    final statsAsync = ref.watch(liveStatsProvider(params));
    
    return statsAsync.when(
      data: (stats) => Text('Attendees: ${stats.liveAttendance}'),
      loading: () => CircularProgressIndicator(),
      error: (err, stack) => Text('Error: $err'),
    );
  }
}
```

#### Pattern 3: Partners Finance (Special Case)
```dart
// Partners finance automatically determines API based on token presence
final partnerToken = await AuthService().getPartnerToken();
final financeData = await analyticsService.getPartnersFinance(
  partnerToken: partnerToken,
);
```

### Token Management

#### Storing Tokens After Login

**Mobile API:**
```dart
// After successful mobile API login
await storage.write(ApiConstants.mobileAccessTokenKey, accessToken);
await storage.write(ApiConstants.mobileRefreshTokenKey, refreshToken);
```

**Legacy Web API:**
```dart
// After successful legacy API login
await storage.write(ApiConstants.legacyWebAuthTokenKey, authToken);
```

#### Reading Tokens
```dart
// Mobile API token
final mobileToken = await storage.read(ApiConstants.mobileAccessTokenKey);

// Legacy API token
final legacyToken = await storage.read(ApiConstants.legacyWebAuthTokenKey);
```

### Debugging

#### Enable Logging
The analytics service already includes extensive logging. Check console output:

```
I/flutter: OverviewTab: trying getBasicFinance for event 10
I/flutter: ╔╣ Request ║ GET 
I/flutter: ║  http://192.168.8.142:8081/api/finance/10
I/flutter: ╟ Authorization: Bearer eyJhbG...
```

#### Common Issues

**Issue**: "An unexpected error occurred (Status: null)"
- **Cause**: Wrong API or missing token
- **Fix**: Verify event has correct `external_event_id` and proper token is stored

**Issue**: Events not loading finance data
- **Cause**: Not passing event model to service methods
- **Fix**: Always pass `event: myEvent` parameter

**Issue**: 401 Unauthorized
- **Cause**: Token expired or using wrong token for event type
- **Fix**: Re-login to get fresh token, ensure correct token storage key

### Testing Locally

```dart
// Test mobile API event (no external_event_id)
final mobileEvent = EventModel(
  id: 10,
  externalEventId: null, // Mobile event
  // ... other fields
);

// Test legacy API event (has external_event_id)
final legacyEvent = EventModel(
  id: 46,
  externalEventId: '6795ff72ded53', // Legacy event
  // ... other fields
);

// Both should work correctly
await analyticsService.getFinanceSales(mobileEvent.id, event: mobileEvent);
await analyticsService.getFinanceSales(legacyEvent.id, event: legacyEvent);
```

### API Response Formats

Both APIs return similar structures, but with slight differences:

**Finance Sales Response (Both APIs):**
```json
{
  "totalRevenue": 0.0,
  "salesByPackage": [...],
  "packageDetails": [...]
}
```

**Live Stats Response:**
- Mobile API: `{ currentCheckIns, liveAttendance, realtimeRevenue, breakdown }`
- Legacy API: `{ totalAttendees, insideCount, toComeCount, attendanceByPackage, ... }`

The service automatically normalizes these to the `LiveStats` model.

### Best Practices

1. **Always pass the event model** when available
2. **Check event source** before making assumptions about data format
3. **Handle both API responses** gracefully with fallbacks
4. **Log API calls** for debugging (already implemented)
5. **Store tokens separately** for each API
6. **Test with both event types** before deploying

### Migration Checklist

When migrating code to use dual API support:

- [ ] Update all `analyticsService` calls to include `event:` parameter
- [ ] Update provider usage to use `EventAnalyticsParams`
- [ ] Verify tokens are stored with correct keys
- [ ] Test with both mobile and legacy events
- [ ] Check console logs for correct API routing
- [ ] Handle API-specific error cases
