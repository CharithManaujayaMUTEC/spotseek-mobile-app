# Login First-Time User Check Implementation

## Overview
Added functionality to check if a user is logging in for the first time and redirect them to the company profile setup page instead of the events dashboard.

## Changes Made

### 1. Updated User Model (`lib/models/auth/login_response.dart`)

Added `loggedInBefore` field to the `User` class:

```dart
@JsonSerializable()
class User {
  final String id;
  final String email;
  final String mobile;
  final String userType;
  final String status;
  final bool profileComplete;
  final String? loggedInBefore; // "true" or "false" string from API
  
  /// Returns true if user has logged in before
  bool get hasLoggedInBefore {
    if (loggedInBefore == null) return true; // Default to true if not provided
    return loggedInBefore?.toLowerCase() == 'true';
  }
}
```

**Key Features:**
- `loggedInBefore` field accepts string values "true" or "false" from the API
- `hasLoggedInBefore` getter converts the string to a boolean
- Defaults to `true` if the field is not provided (backward compatibility)

### 2. Updated Login Screen (`lib/screens/auth/login_screen.dart`)

Modified the login flow to check `loggedInBefore` status:

```dart
Future<void> _handleLogin() async {
  // ... login logic ...
  
  final loginResponse = await _authService.login(
    _emailController.text.trim(),
    _passwordController.text,
  );

  if (mounted) {
    // Check if user has logged in before
    if (!loginResponse.user.hasLoggedInBefore) {
      // First time login - navigate to company profile setup
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const CompanyProfilePage(),
        ),
        (route) => false,
      );
    } else {
      // Returning user - go directly to Events Board
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const EventsBoardScreen(),
        ),
        (route) => false,
      );
    }
  }
}
```

**Navigation Flow:**
1. User clicks "Access Copilot" button
2. Login API call to `{{base_url}}/api/auth/login`
3. Response includes `loggedInBefore` field in user object
4. If `loggedInBefore === "false"` → Navigate to **Company Profile Page**
5. If `loggedInBefore === "true"` → Navigate to **Events Board**

### 3. Added Import

Added import for the company profile page:
```dart
import 'package:spotseeker_app/screens/partner_form/pages/company_profile_page_new.dart';
```

## API Response Structure

The login API (`{{base_url}}/api/auth/login`) returns:

```json
{
  "accessToken": "eyJhbG...",
  "refreshToken": "b64d976c-8094-4f58-94ff-c5e57aec8123",
  "user": {
    "id": "23",
    "email": "manager.user@gmail.com",
    "mobile": "+94760000005",
    "userType": "partner",
    "status": "approved",
    "profileComplete": false,
    "loggedInBefore": "false"  // ← This field determines navigation
  }
}
```

## User Experience

### First-Time Login
1. User enters credentials and clicks "Access Copilot"
2. Loading indicator shows during authentication
3. On success, user is taken to **Company Profile Setup** page
4. User completes their profile information
5. On subsequent logins, they go directly to Events Board

### Returning User Login
1. User enters credentials and clicks "Access Copilot"
2. Loading indicator shows during authentication
3. On success, user is taken directly to **Events Board**

## Backward Compatibility

- If the API doesn't return `loggedInBefore` field, it defaults to `true`
- Existing users will continue to go to Events Board
- No breaking changes for existing functionality

## Testing Checklist

- [ ] Test first-time login (loggedInBefore: "false") → should navigate to Company Profile
- [ ] Test returning user (loggedInBefore: "true") → should navigate to Events Board
- [ ] Test with missing loggedInBefore field → should navigate to Events Board (default)
- [ ] Test error handling during login
- [ ] Verify JSON serialization works correctly after build_runner

## Next Steps

1. Run `dart run build_runner build --delete-conflicting-outputs` to regenerate JSON serialization code
2. Test the login flow with both first-time and returning users
3. Ensure Company Profile page properly handles first-time user onboarding
4. Add analytics tracking for first-time vs returning user logins (optional)

## Files Modified

1. `lib/models/auth/login_response.dart` - Added `loggedInBefore` field and getter
2. `lib/screens/auth/login_screen.dart` - Added navigation logic based on `loggedInBefore`
