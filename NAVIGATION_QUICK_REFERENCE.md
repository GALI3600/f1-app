# Navigation Quick Reference Card

Quick copy-paste reference for F1Sync navigation.

---

## Import

```dart
import 'package:f1sync/core/router/route_extensions.dart';
```

---

## Navigation Methods

### Go (Replace Route)

```dart
context.goToHome()
context.goToMeetings()
context.goToDrivers()
context.goToMeetingDetail(meetingKey)
context.goToDriverDetail(driverNumber)
context.goToSessionDetail(sessionKey)
context.goToLatestSession()
```

### Push (Keep in Stack)

```dart
context.pushMeetingDetail(meetingKey)
context.pushDriverDetail(driverNumber)
context.pushSessionDetail(sessionKey)
```

### Back Navigation

```dart
context.goBackOrHome()        // Go back or home if can't go back
context.canNavigateBack()     // Check if can navigate back (bool)
```

---

## Common Patterns

### Card/List Item Navigation

```dart
Card(
  child: InkWell(
    onTap: () => context.goToDriverDetail(driver.driverNumber),
    child: // ... content
  ),
)
```

### Button Navigation

```dart
ElevatedButton(
  onPressed: () => context.goToMeetings(),
  child: Text('View All Meetings'),
)
```

### AppBar Back Button

```dart
AppBar(
  leading: IconButton(
    icon: Icon(Icons.arrow_back),
    onPressed: () => context.goBackOrHome(),
  ),
  title: Text('Screen Title'),
)
```

### List Item → Detail

```dart
ListView.builder(
  itemBuilder: (context, index) {
    final item = items[index];
    return ListTile(
      title: Text(item.name),
      onTap: () => context.goToItemDetail(item.id),
    );
  },
)
```

---

## Route Paths

| Path | Screen | Parameters |
|------|--------|------------|
| `/` | Home | - |
| `/meetings` | Meetings List | - |
| `/meetings/:meetingKey` | Meeting Detail | meetingKey (int) |
| `/drivers` | Drivers List | - |
| `/drivers/:driverNumber` | Driver Detail | driverNumber (int) |
| `/sessions/:sessionKey` | Session Detail | sessionKey (int) |
| `/sessions/latest` | Latest Session | - (redirects) |

---

## Named Routes

```dart
context.goNamed(Routes.home)
context.goNamed(Routes.meetings)
context.goNamed(Routes.drivers)

context.goNamed(
  Routes.driverDetail,
  pathParameters: {'driverNumber': '44'},
)
```

---

## Deep Links

### Custom Scheme

```
f1sync://meetings
f1sync://drivers/44
f1sync://sessions/9165
```

### App/Universal Links

```
https://f1sync.app/meetings
https://f1sync.app/drivers/44
https://f1sync.app/sessions/9165
```

---

## Error Handling

All routes automatically validate parameters:

```dart
// This will show error screen: "Invalid driver number"
context.goToDriverDetail(-1)  // Invalid
context.goToDriverDetail(0)   // Invalid

// This will show error screen: "Page not found"
context.go('/unknown-route')
```

---

## Transitions

### Automatic

- **Fade:** List screens (Home, Meetings, Drivers)
- **Slide+Fade:** Detail screens
- **Duration:** 300ms
- **Curve:** easeInOut

No manual configuration needed!

---

## Testing Commands

### Android

```bash
adb shell am start -W -a android.intent.action.VIEW -d "f1sync://drivers/44"
```

### iOS

```bash
xcrun simctl openurl booted "f1sync://drivers/44"
```

---

## Examples by Feature

### Home Screen Navigation

```dart
// Navigate to meetings
GridView(
  children: [
    Card(
      onTap: () => context.goToMeetings(),
      child: Text('Meetings'),
    ),
    Card(
      onTap: () => context.goToDrivers(),
      child: Text('Drivers'),
    ),
  ],
)
```

### Meetings Flow

```dart
// meetings_history_screen.dart
onTap: () => context.goToMeetingDetail(meeting.meetingKey)

// meeting_detail_screen.dart
onTap: () => context.pushSessionDetail(session.sessionKey)
```

### Drivers Flow

```dart
// drivers_list_screen.dart
onTap: () => context.goToDriverDetail(driver.driverNumber)

// driver_detail_screen.dart
AppBar(
  leading: IconButton(
    onPressed: () => context.goBackOrHome(),
    icon: Icon(Icons.arrow_back),
  ),
)
```

---

## Don't Use These ❌

```dart
// ❌ Don't use Navigator directly
Navigator.push(context, MaterialPageRoute(...))

// ✅ Use context extensions instead
context.goToDriverDetail(44)
```

```dart
// ❌ Don't construct routes manually
context.go('/drivers/${driver.driverNumber}')

// ✅ Use helper methods
context.goToDriverDetail(driver.driverNumber)
```

---

## Pro Tips

1. **Always import route extensions** in screens that navigate
2. **Use `go` for replacing**, `push` for stacking
3. **Let GoRouter handle back button** (it's automatic)
4. **Use `goBackOrHome()` for safety** (never gets stuck)
5. **Test with invalid parameters** to see error screens

---

## Common Mistakes

### ❌ Forgetting to import

```dart
// This will fail
context.goToDrivers()  // Method not found
```

```dart
// ✅ Add import
import 'package:f1sync/core/router/route_extensions.dart';

context.goToDrivers()  // Works!
```

### ❌ Using wrong navigation type

```dart
// ❌ Using go when you want to keep previous screen
context.goToSessionDetail(session.sessionKey)
// Back button will skip the previous screen

// ✅ Use push to keep previous screen
context.pushSessionDetail(session.sessionKey)
// Back button returns to previous screen
```

### ❌ Not handling null parameters

```dart
// ❌ This might crash
context.goToDriverDetail(driver?.driverNumber)

// ✅ Check for null first
if (driver != null) {
  context.goToDriverDetail(driver.driverNumber);
}
```

---

## Debug Checklist

If navigation isn't working:

- [ ] Imported `route_extensions.dart`?
- [ ] Using correct parameter type (int)?
- [ ] Parameter is not null?
- [ ] Route exists in `app_router.dart`?
- [ ] Check console for GoRouter logs

---

## Full Example

```dart
import 'package:flutter/material.dart';
import 'package:f1sync/core/router/route_extensions.dart';

class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => context.goBackOrHome(),
        ),
        title: Text('My Screen'),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () => context.goToHome(),
            child: Text('Go Home'),
          ),
          ElevatedButton(
            onPressed: () => context.goToDriverDetail(44),
            child: Text('View Lewis Hamilton'),
          ),
          ElevatedButton(
            onPressed: () => context.goToMeetings(),
            child: Text('View Meetings'),
          ),
        ],
      ),
    );
  }
}
```

---

**Need more details?** Check:
- `PHASE_10_README.md` - Overview
- `NAVIGATION_TESTING_GUIDE.md` - Testing
- `DEEP_LINKING_SETUP.md` - Deep linking

---

🏎️💨 **Happy Navigating!**
