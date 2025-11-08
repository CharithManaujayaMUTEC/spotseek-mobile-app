# Events Feature - Banner Images Required

Please add the following banner images to the `assets/` folder:

## Required Images:

1. **events_made_smart_banner.png** or **events_made_smart_banner.jpg**
   - Dimensions: Flexible (will be displayed in a 180px height container)
   - Content: "EVENTS MADE SMART" banner with tagline "Plan, track & grow with insights"
   - Used in: Events Board Screen (home/dashboard)

2. **kickstart_your_event_banner.png** or **kickstart_your_event_banner.jpg**
   - Dimensions: Flexible (will be displayed in a 180px height container)
   - Content: "KICKSTART YOUR EVENT" banner with tagline "Plan, schedule & launch in real"
   - Used in: Add Event Screen (event creation form)

## Current Implementation:

The banners are currently implemented as gradient backgrounds with text overlay in the code. Once you provide the actual banner images, you can replace the gradient containers with:

### For Events Board Screen (`lib/screens/events/events_board_screen.dart`):
Replace the `_buildBanner()` method's Container with:
```dart
Image.asset(
  'assets/events_made_smart_banner.png',
  height: 180,
  fit: BoxFit.cover,
)
```

### For Add Event Screen (`lib/screens/events/add_event_screen.dart`):
Replace the `_buildBanner()` method's Container with:
```dart
Image.asset(
  'assets/kickstart_your_event_banner.png',
  height: 180,
  fit: BoxFit.cover,
)
```

## Features Implemented:

✅ Events Board Screen with grid layout
✅ Filter chips (All Events, Active Events, Inactive Events, Pending Approval)
✅ Event cards with date badges and status labels
✅ Red circular floating action button (+) to add new events
✅ Add Event Screen with complete form
✅ Ticket package dialog for adding multiple packages
✅ Date/Time pickers for event scheduling
✅ Dropdown fields for event type, category, and Koko payment
✅ Navigation from "Submit Contract & Access Copilot" to Events Board
✅ JSON-based event data structure (easily replaceable with API)

## Event Data Structure:

Events are currently loaded from `assets/events_data.json`. To replace with API:
1. Open `lib/services/event_service.dart`
2. Uncomment and implement the `fetchEventsFromApi()` method
3. Replace the `loadEvents()` call in screens with `fetchEventsFromApi()`
