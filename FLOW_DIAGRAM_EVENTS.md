# Events API Integration - Flow Diagram

## Data Flow Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                      Events Board Screen                         │
│                    (events_board_screen.dart)                    │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ├─── initState()
                              │    └─> _loadEvents() ──┐
                              │                        │
                              ├─── Pull to Refresh     │
                              │    └─> _loadEvents() ──┤
                              │                        │
                              └─── Scroll to 80%       │
                                   └─> _loadMoreEvents()│
                                                        │
                                                        ▼
┌─────────────────────────────────────────────────────────────────┐
│                        Event Service                             │
│                     (event_service.dart)                         │
│                                                                  │
│  loadEventsWithPagination(page, limit)                          │
│    ├─> Get access token from secure storage                     │
│    ├─> Get partner token from secure storage                    │
│    ├─> Create Dio HTTP client                                   │
│    └─> GET /api/events/partner?page={page}&limit={limit}       │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                      API Endpoint                                │
│         http://192.168.8.142:8081/api/events/partner            │
│                                                                  │
│  Headers:                                                        │
│    - Authorization: Bearer {access_token}                        │
│    - partnerToken: {partner_token}                               │
│    - Accept: application/json                                    │
│                                                                  │
│  Query Params:                                                   │
│    - page: 0, 1, 2, ...                                         │
│    - limit: 10 (default)                                        │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                      API Response                                │
│                                                                  │
│  {                                                               │
│    "total": 25,         ← Total events available                │
│    "limit": 10,         ← Events per page                       │
│    "page": 0,           ← Current page number                   │
│    "events": [...]      ← Array of event objects                │
│  }                                                               │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                      EventsResponse                              │
│                                                                  │
│  EventsResponse(                                                 │
│    total: 25,                                                    │
│    limit: 10,                                                    │
│    page: 0,                                                      │
│    events: [EventModel, EventModel, ...]                        │
│  )                                                               │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                      Event Model                                 │
│                     (event_model.dart)                           │
│                                                                  │
│  EventModel.fromJson(json)                                       │
│    ├─> Parse id, uid, name                                      │
│    ├─> Handle manager (string or object)                        │
│    ├─> Handle venue (string or object)                          │
│    ├─> Parse dates, status, images                              │
│    └─> Parse ticket packages                                     │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                      UI Rendering                                │
│                                                                  │
│  GridView (2 columns)                                            │
│    ├─> Event Card 1                                             │
│    ├─> Event Card 2                                             │
│    ├─> Event Card 3                                             │
│    ├─> ...                                                       │
│    ├─> Event Card 10                                            │
│    └─> Loading Indicator (if loading more)                      │
│                                                                  │
│  Pagination Counter: "10 / 25"                                   │
└─────────────────────────────────────────────────────────────────┘
```

## Pagination Flow

### Initial Load
```
User Opens Screen
       │
       ▼
┌──────────────┐
│ Page 0       │  _currentPage = 0
│ Limit 10     │  GET /api/events/partner?page=0&limit=10
└──────────────┘
       │
       ▼
┌──────────────┐
│ Response:    │  total: 25
│ 10 events    │  events: [event1...event10]
└──────────────┘
       │
       ▼
┌──────────────┐
│ UI Shows:    │  Display 10 events
│ 10 / 25      │  Show counter badge
└──────────────┘
```

### Infinite Scroll
```
User Scrolls Down (80% of content)
       │
       ▼
┌──────────────┐
│ Check:       │  if (!_isLoadingMore && _hasMoreData)
│ Can load?    │  _hasMoreData = (10 < 25) = true
└──────────────┘
       │
       ▼
┌──────────────┐
│ Page 1       │  _currentPage = 1
│ Limit 10     │  GET /api/events/partner?page=1&limit=10
└──────────────┘
       │
       ▼
┌──────────────┐
│ Response:    │  total: 25
│ 10 events    │  events: [event11...event20]
└──────────────┘
       │
       ▼
┌──────────────┐
│ Append:      │  _allEvents.addAll(newEvents)
│ _allEvents   │  Now have 20 events
└──────────────┘
       │
       ▼
┌──────────────┐
│ UI Shows:    │  Display 20 events
│ 20 / 25      │  Update counter badge
└──────────────┘
```

### Pull to Refresh
```
User Pulls Down
       │
       ▼
┌──────────────┐
│ Reset:       │  _currentPage = 0
│ Clear Data   │  _allEvents.clear()
└──────────────┘
       │
       ▼
┌──────────────┐
│ Page 0       │  _currentPage = 0
│ Limit 10     │  GET /api/events/partner?page=0&limit=10
└──────────────┘
       │
       ▼
┌──────────────┐
│ Response:    │  total: 25
│ 10 events    │  events: [event1...event10] (fresh data)
└──────────────┘
       │
       ▼
┌──────────────┐
│ UI Shows:    │  Display 10 events
│ 10 / 25      │  Show counter badge
└──────────────┘
```

## State Management

```
┌─────────────────────────────────────────────────────────┐
│              Events Board State Variables               │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  _allEvents: List<EventModel>                           │
│    └─> All loaded events from all pages                 │
│                                                          │
│  _filteredEvents: List<EventModel>                      │
│    └─> Filtered subset of _allEvents                    │
│                                                          │
│  _currentPage: int                                       │
│    └─> Current page number (0, 1, 2, ...)              │
│                                                          │
│  _limit: int = 10                                        │
│    └─> Events per page                                  │
│                                                          │
│  _totalEvents: int                                       │
│    └─> Total events from API response                   │
│                                                          │
│  _hasMoreData: bool                                      │
│    └─> _allEvents.length < _totalEvents                 │
│                                                          │
│  _isLoading: bool                                        │
│    └─> Initial load indicator                           │
│                                                          │
│  _isLoadingMore: bool                                    │
│    └─> Load more indicator                              │
│                                                          │
│  _selectedFilter: String                                 │
│    └─> Current filter ('All Events', 'Active', etc.)    │
│                                                          │
│  _scrollController: ScrollController                     │
│    └─> Monitors scroll position for infinite scroll     │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

## Filter Logic with Pagination

```
All Events Loaded (Pages 0, 1, 2)
         │
         ├─> Event 1 (status: active)
         ├─> Event 2 (status: pending)
         ├─> Event 3 (status: active)
         ├─> Event 4 (status: inactive)
         ├─> Event 5 (status: active)
         └─> ... (more events)
                  │
                  ▼
        ┌────────────────────┐
        │ User Selects       │
        │ "Active Events"    │
        └────────────────────┘
                  │
                  ▼
        ┌────────────────────┐
        │ Apply Filter       │
        │ to _allEvents      │
        └────────────────────┘
                  │
                  ▼
        ┌────────────────────┐
        │ _filteredEvents =  │
        │ [Event 1,          │
        │  Event 3,          │
        │  Event 5, ...]     │
        └────────────────────┘
                  │
                  ▼
        ┌────────────────────┐
        │ Display Filtered   │
        │ Events in Grid     │
        └────────────────────┘
```

## Error Handling Flow

```
API Call Made
      │
      ├─────────── Success ────────────┐
      │                                 │
      │                                 ▼
      │                    ┌─────────────────────┐
      │                    │ Parse Response      │
      │                    │ Return EventsResponse│
      │                    └─────────────────────┘
      │
      └─────────── Error ──────────────┐
                                       │
                                       ▼
                          ┌─────────────────────┐
                          │ No Access Token     │
                          │ Network Error       │
                          │ API Error           │
                          └─────────────────────┘
                                       │
                                       ▼
                          ┌─────────────────────┐
                          │ Log Error           │
                          │ print(error)        │
                          └─────────────────────┘
                                       │
                                       ▼
                          ┌─────────────────────┐
                          │ Return Empty        │
                          │ EventsResponse(     │
                          │   total: 0,         │
                          │   events: []        │
                          │ )                   │
                          └─────────────────────┘
                                       │
                                       ▼
                          ┌─────────────────────┐
                          │ UI Shows            │
                          │ "No events found"   │
                          │ Pull to retry       │
                          └─────────────────────┘
```

## Component Interaction

```
┌─────────────────────────────────────────────────────────────────┐
│                     Events Board Screen                         │
│                                                                  │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐         │
│  │   Header     │  │  Banner      │  │  Title +     │         │
│  │   - Logo     │  │  - Image     │  │  Counter     │         │
│  │   - Profile  │  │              │  │  "10 / 25"   │         │
│  └──────────────┘  └──────────────┘  └──────────────┘         │
│                                                                  │
│  ┌─────────────────────────────────────────────────────┐       │
│  │             Filter Chips (Horizontal)                │       │
│  │  [All] [Active] [Inactive] [Pending]               │       │
│  └─────────────────────────────────────────────────────┘       │
│                                                                  │
│  ┌─────────────────────────────────────────────────────┐       │
│  │           Events Grid (2 columns)                    │       │
│  │  ┌─────────┐  ┌─────────┐                           │       │
│  │  │ Event 1 │  │ Event 2 │                           │       │
│  │  │ + Image │  │ + Image │                           │       │
│  │  │ + Info  │  │ + Info  │                           │       │
│  │  └─────────┘  └─────────┘                           │       │
│  │                                                       │       │
│  │  ┌─────────┐  ┌─────────┐                           │       │
│  │  │ Event 3 │  │ Event 4 │                           │       │
│  │  └─────────┘  └─────────┘                           │       │
│  │                                                       │       │
│  │       ... (scroll down) ...                          │       │
│  │                                                       │       │
│  │  ┌──────────────────────────┐                       │       │
│  │  │  Loading Indicator...    │ ← Load More          │       │
│  │  └──────────────────────────┘                       │       │
│  └─────────────────────────────────────────────────────┘       │
│                                                                  │
│  ┌──────────────┐                                               │
│  │     FAB      │  ← Add New Event                            │
│  │      +       │                                               │
│  └──────────────┘                                               │
└─────────────────────────────────────────────────────────────────┘
```

---
**Visual Guide to Pagination Implementation**
**Last Updated:** November 3, 2025
