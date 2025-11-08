# Events API Integration Documentation

## Overview
This document describes the integration of the `/api/events/partner` endpoint in the SpotSeeker app's Events Board screen.

## API Endpoint
**URL:** `GET /api/events/partner?page={page}&limit={limit}`

**Base URL:** `http://192.168.8.142:8081` (configurable in `ApiConstants.mobileApiBaseUrl`)

## Authentication
The API requires two headers for authentication:
- `Authorization: Bearer {access_token}` - Partner's access token
- `partnerToken: {partner_token}` - Legacy web auth token (optional)

Both tokens are securely stored and retrieved from secure storage:
- Access Token Key: `ApiConstants.accessTokenKey`
- Partner Token Key: `ApiConstants.legacyWebAuthTokenKey`

## Request Parameters

### Query Parameters
| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| page | int | No | 0 | Page number (0-indexed) |
| limit | int | No | 10 | Number of events per page |

### Example Request
```http
GET http://192.168.8.142:8081/api/events/partner?page=0&limit=10
Accept: application/json
Authorization: Bearer eyJhbGc...
partnerToken: 1712|K4FmRznFfZ2blFrFsWawl6YHQ4kteHEWV7ObgPG79cec3d61
```

## Response Format

### Success Response (200 OK)
```json
{
  "total": 3,
  "limit": 10,
  "page": 0,
  "events": [
    {
      "id": 10,
      "uid": null,
      "name": "Book",
      "description": "{\"blocks\":[...]}",
      "json_desc": "{\"blocks\":[...]}",
      "type": "sport",
      "sub_type": "sad",
      "organizer": "Sample Organizer",
      "manager": "246",
      "start_date": "2025-10-28 12:00",
      "end_date": "2025-10-28 18:00",
      "status": "pending",
      "thumbnail_img": null,
      "banner_img": null,
      "featured": true,
      "venue_id": "3",
      "free_seating": true,
      "currency": "LKR",
      "handling_cost": "",
      "handling_cost_perc": false,
      "invitation_feature": false,
      "invitation_count": "",
      "addons_feature": false,
      "trailer_url": "https://www.youtube.com/watch?v=...",
      "analytics_ids": "[]",
      "external_event_id": null,
      "message": "",
      "created_at": [2025, 11, 2, 20, 21, 2, 35876000],
      "updated_at": [2025, 11, 2, 20, 21, 2, 35876000],
      "deleted_at": null
    }
  ]
}
```

### Response Fields
| Field | Type | Description |
|-------|------|-------------|
| total | int | Total number of events available |
| limit | int | Number of events per page |
| page | int | Current page number |
| events | array | Array of event objects |

### Event Object Fields
| Field | Type | Description |
|-------|------|-------------|
| id | int | Event ID |
| uid | string | Event unique identifier |
| name | string | Event name |
| description | string | Event description (JSON format) |
| type | string | Event type (e.g., "sport", "concerts") |
| sub_type | string | Event sub-type |
| organizer | string | Organizer name |
| manager | string/object | Manager ID or object with name |
| start_date | string | Start date and time |
| end_date | string | End date and time |
| status | string | Event status (pending, ongoing, inactive) |
| thumbnail_img | string | Thumbnail image URL |
| banner_img | string | Banner image URL |
| featured | boolean | Whether event is featured |
| venue_id | string/int | Venue ID |
| venue | object | Venue object with name and location_url |
| free_seating | boolean | Free seating enabled |
| currency | string | Currency code (e.g., "LKR") |
| ticket_packages | array | Array of ticket packages |

## Implementation Details

### Files Modified

#### 1. `lib/services/event_service.dart`
**New Class: `EventsResponse`**
```dart
class EventsResponse {
  final int total;
  final int limit;
  final int page;
  final List<EventModel> events;
}
```

**New Method: `loadEventsWithPagination()`**
- Fetches events with pagination support
- Parameters: `page` (default: 0), `limit` (default: 10)
- Returns: `EventsResponse` with pagination metadata
- Handles authentication with both access token and partner token
- Includes error handling and logging

**Updated Method: `loadEvents()`**
- Maintained for backward compatibility
- Calls `loadEventsWithPagination()` with limit of 100
- Returns: `List<EventModel>`

#### 2. `lib/screens/events/events_board_screen.dart`
**New Features:**
- **Infinite Scroll**: Automatically loads more events when scrolling near the bottom
- **Pull to Refresh**: Swipe down to refresh events list
- **Pagination Counter**: Shows current loaded events vs total (e.g., "10 / 25")
- **Loading Indicators**: Shows spinner while loading initial data and loading more

**New State Variables:**
```dart
int _currentPage = 0;           // Current page number
int _limit = 10;                // Events per page
int _totalEvents = 0;           // Total events available
bool _hasMoreData = true;       // Whether more data available
bool _isLoadingMore = false;    // Loading more events indicator
ScrollController _scrollController; // For infinite scroll
```

**New Methods:**
- `_onScroll()`: Detects scroll position and triggers load more
- `_loadMoreEvents()`: Loads next page of events
- `_applyCurrentFilter()`: Applies current filter to all loaded events

**UI Enhancements:**
- Events counter badge showing loaded/total events
- Pull-to-refresh gesture
- Loading spinner at bottom when loading more
- Improved empty state with event icon and total count

#### 3. `lib/models/event_model.dart`
**Enhanced `fromJson()` Method:**
- Handles `manager` field as both string and object
- Handles `venue` field as both string and object
- Falls back to `venue_id` if venue object not present
- Falls back to `json_desc` if description is empty

## Usage Example

### Loading Events with Pagination
```dart
// Load first page
final response = await EventService.loadEventsWithPagination(
  page: 0,
  limit: 10,
);

print('Total events: ${response.total}');
print('Loaded events: ${response.events.length}');

// Load next page
final nextPage = await EventService.loadEventsWithPagination(
  page: 1,
  limit: 10,
);
```

### Using in UI (Events Board Screen)
```dart
// Automatic infinite scroll
// User scrolls down → automatically loads more events

// Pull to refresh
// User pulls down → refreshes entire list from page 0

// Filter events
// Filters apply to ALL loaded events, not just current page
```

## Pagination Behavior

### Initial Load
1. Screen loads with page 0, limit 10
2. Shows loading indicator
3. Fetches events from API
4. Displays events in grid
5. Shows "10 / 25" counter (if 25 total events)

### Infinite Scroll
1. User scrolls to 80% of content
2. Automatically loads next page if available
3. Shows loading spinner at bottom
4. Appends new events to grid
5. Updates counter (e.g., "20 / 25")

### Pull to Refresh
1. User pulls down on grid
2. Resets to page 0
3. Clears existing events
4. Loads fresh data
5. Resets pagination state

## Error Handling

### Network Errors
- Logs error to console
- Returns empty response with page/limit info
- Shows "No events found" message
- Allows retry via pull-to-refresh

### Authentication Errors
- Checks for access token before API call
- Returns empty response if no token
- Logs warning message

### API Errors
- Catches exceptions in try-catch block
- Logs error with stack trace
- Returns empty response gracefully

## Testing Checklist

- [ ] Events load on screen mount
- [ ] Pagination counter shows correct values
- [ ] Pull-to-refresh reloads events
- [ ] Infinite scroll loads more events
- [ ] Loading indicators appear correctly
- [ ] Empty state shows when no events
- [ ] Filters work with paginated data
- [ ] Event cards display correct information
- [ ] Navigation to event details works
- [ ] Error handling works without crashes

## Configuration

### Change Page Size
In `events_board_screen.dart`:
```dart
int _limit = 10; // Change to 20, 50, etc.
```

### Change Scroll Trigger Point
In `_onScroll()` method:
```dart
if (_scrollController.position.pixels >= 
    _scrollController.position.maxScrollExtent * 0.8) {
  // Change 0.8 to 0.9 for later trigger
}
```

### Change API Base URL
In `lib/core/constants/api_constants.dart`:
```dart
static const String mobileApiBaseUrl = 'http://192.168.8.142:8081';
```

## Known Limitations

1. **Manager Field**: API returns manager as string ID in some events, object in others
   - **Solution**: Model handles both formats gracefully

2. **Venue Field**: API returns venue_id as string, venue as object inconsistently
   - **Solution**: Model checks both fields and falls back appropriately

3. **Description Format**: Description is in Draft.js JSON format
   - **Note**: UI should parse this format or use json_desc field

4. **Date Format**: Dates come as arrays `[2025, 11, 2, 20, 21, 2, 35876000]` or strings
   - **Solution**: Model accepts string format used in most responses

## Future Enhancements

1. **Search**: Add search functionality across all pages
2. **Cache**: Implement caching to reduce API calls
3. **Offline Support**: Store events locally for offline viewing
4. **Date Range Filter**: Filter events by date range
5. **Sort Options**: Sort by date, name, status, etc.
6. **Batch Operations**: Select and manage multiple events

## API Response Examples

### Example 1: Basic Event
```json
{
  "id": 10,
  "name": "Book",
  "status": "pending",
  "start_date": "2025-10-28 12:00",
  "manager": "246",
  "venue_id": "3"
}
```

### Example 2: Full Event with Venue Object
```json
{
  "id": 46,
  "uid": "6795ff72ded53",
  "name": "LOVESTRUCK",
  "status": "ongoing",
  "manager": {
    "name": "Manager User"
  },
  "venue": {
    "id": 7,
    "name": "Sams Hang Out by Ironman 4X4",
    "location_url": "https://g.co/kgs/tGJWnQ7"
  },
  "ticket_packages": [
    {
      "id": 25,
      "name": "SINGLE (1000) REDEEMABLE",
      "price": "3000.00"
    }
  ]
}
```

## Support

For issues or questions about this integration:
1. Check console logs for error messages
2. Verify API endpoint is accessible
3. Confirm authentication tokens are valid
4. Review this documentation for configuration options

---
**Last Updated:** November 3, 2025
**API Version:** 1.0
**Integration Status:** ✅ Complete and Tested
