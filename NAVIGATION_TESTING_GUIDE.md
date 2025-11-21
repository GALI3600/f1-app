# F1Sync Navigation Testing Guide

Quick reference for testing all navigation flows in the app.

---

## Quick Test Commands

### Build and Run

```bash
# Clean build
flutter clean
flutter pub get

# Run on device/emulator
flutter run

# Run with verbose logging
flutter run -v
```

---

## Manual Testing Checklist

### ✅ Basic Navigation

- [ ] **Home Screen**
  - App launches to home screen
  - No errors on initial load
  - All navigation cards are tappable

- [ ] **Meetings Flow**
  - [ ] Home → Meetings (tap "Meetings" card)
  - [ ] Verify meetings list loads
  - [ ] Tap on a meeting → Meeting Detail screen
  - [ ] Verify meeting data loads
  - [ ] Tap on a session → Session Detail screen
  - [ ] Verify session data loads
  - [ ] Back button: Session → Meeting → Meetings → Home

- [ ] **Drivers Flow**
  - [ ] Home → Drivers (tap "Drivers" card)
  - [ ] Verify drivers list loads
  - [ ] Tap on a driver → Driver Detail screen
  - [ ] Verify driver data loads
  - [ ] Back button: Driver Detail → Drivers → Home

- [ ] **Direct Session Access**
  - [ ] Navigate directly to `/sessions/:sessionKey`
  - [ ] Verify session detail loads
  - [ ] Back button goes to home (no previous screen)

### ✅ Transitions

- [ ] **Fade Transitions** (List screens)
  - Home → Meetings (should fade in)
  - Home → Drivers (should fade in)
  - Transition should be smooth (300ms)

- [ ] **Slide Transitions** (Detail screens)
  - Meetings → Meeting Detail (should slide up + fade)
  - Drivers → Driver Detail (should slide up + fade)
  - Meeting Detail → Session Detail (should slide up + fade)
  - Transition should be smooth (300ms)

### ✅ Error Handling

- [ ] **Invalid Parameters**
  - [ ] Navigate to `/drivers/abc` (invalid number)
  - [ ] Should show "Invalid driver number" error
  - [ ] Tap "Retry" → Goes to `/drivers`
  - [ ] Navigate to `/meetings/xyz` (invalid key)
  - [ ] Should show "Invalid meeting key" error
  - [ ] Tap "Retry" → Goes to `/meetings`

- [ ] **404 Routes**
  - [ ] Navigate to `/unknown-route`
  - [ ] Should show "Page not found" error
  - [ ] Shows the attempted path in error message
  - [ ] Tap "Retry" → Goes to home

### ✅ Back Button Behavior

- [ ] **Android Back Button** (Android only)
  - [ ] On home screen → exits app
  - [ ] On detail screen → goes back
  - [ ] On list screen → goes to home

- [ ] **iOS Swipe Back** (iOS only)
  - [ ] Swipe from left edge on detail screen
  - [ ] Should go back smoothly
  - [ ] Swipe on home screen → no effect

- [ ] **AppBar Back Button**
  - [ ] All detail screens have back button
  - [ ] Tapping back button goes to previous screen
  - [ ] Home screen has no back button

### ✅ Navigation Helpers

Test the extension methods by adding temporary buttons:

```dart
// Add to any screen for testing
Column(
  children: [
    ElevatedButton(
      onPressed: () => context.goToHome(),
      child: Text('Go Home'),
    ),
    ElevatedButton(
      onPressed: () => context.goToMeetings(),
      child: Text('Go Meetings'),
    ),
    ElevatedButton(
      onPressed: () => context.goToDrivers(),
      child: Text('Go Drivers'),
    ),
    ElevatedButton(
      onPressed: () => context.goToDriverDetail(44),
      child: Text('Go to Driver #44'),
    ),
    ElevatedButton(
      onPressed: () => context.goToMeetingDetail(1239),
      child: Text('Go to Meeting 1239'),
    ),
    ElevatedButton(
      onPressed: () => context.goToSessionDetail(9165),
      child: Text('Go to Session 9165'),
    ),
  ],
)
```

- [ ] All helper methods work correctly
- [ ] Navigation happens instantly
- [ ] No errors in console

---

## Deep Link Testing

### Prerequisites

When android/ios folders are added:

```bash
# Create platform folders
flutter create --platforms=android,ios .

# Then apply configurations from DEEP_LINKING_SETUP.md
```

### Android Deep Link Tests

```bash
# Make sure app is installed on device/emulator first
flutter install

# Test custom scheme
adb shell am start -W -a android.intent.action.VIEW -d "f1sync://meetings"
adb shell am start -W -a android.intent.action.VIEW -d "f1sync://meetings/1239"
adb shell am start -W -a android.intent.action.VIEW -d "f1sync://drivers"
adb shell am start -W -a android.intent.action.VIEW -d "f1sync://drivers/44"
adb shell am start -W -a android.intent.action.VIEW -d "f1sync://sessions/9165"

# Test app links (if domain configured)
adb shell am start -W -a android.intent.action.VIEW -d "https://f1sync.app/meetings"
adb shell am start -W -a android.intent.action.VIEW -d "https://f1sync.app/drivers/44"
```

### iOS Deep Link Tests

```bash
# Get device ID
xcrun simctl list devices | grep Booted

# Test custom scheme
xcrun simctl openurl booted "f1sync://meetings"
xcrun simctl openurl booted "f1sync://meetings/1239"
xcrun simctl openurl booted "f1sync://drivers"
xcrun simctl openurl booted "f1sync://drivers/44"
xcrun simctl openurl booted "f1sync://sessions/9165"

# Test universal links (if domain configured)
xcrun simctl openurl booted "https://f1sync.app/meetings"
xcrun simctl openurl booted "https://f1sync.app/drivers/44"
```

### Expected Behavior

- [ ] App opens (or comes to foreground)
- [ ] Navigates to correct screen
- [ ] Data loads properly
- [ ] Back button behavior correct

---

## Performance Testing

### Transition Smoothness

1. Enable performance overlay:
   ```bash
   flutter run --profile
   ```

2. In the app:
   - Open DevTools
   - Navigate between screens
   - Check for frame drops
   - Target: 60 FPS (16ms per frame)

### Memory Usage

```bash
# Run with memory profiling
flutter run --profile

# In DevTools → Memory tab
# Navigate between screens multiple times
# Check for memory leaks
```

**Expected:**
- Memory usage should stabilize after navigation
- No continuous memory growth
- Proper cleanup when screens are disposed

---

## Automated Testing (Future)

### Widget Tests

Create `test/navigation_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:f1sync/main.dart';

void main() {
  testWidgets('Navigate to drivers screen', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: F1SyncApp()),
    );
    await tester.pumpAndSettle();

    // Find and tap drivers button
    final driversButton = find.text('Drivers');
    expect(driversButton, findsOneWidget);
    await tester.tap(driversButton);
    await tester.pumpAndSettle();

    // Verify we're on drivers screen
    expect(find.text('Drivers'), findsWidgets);
  });
}
```

Run tests:
```bash
flutter test test/navigation_test.dart
```

---

## Common Issues & Solutions

### Issue: "Page not found" on valid route

**Cause:** Route not registered in app_router.dart

**Solution:** Check that route exists in `routes` list

### Issue: Parameters not being parsed

**Cause:** Parameter name mismatch

**Solution:** Check that path parameter matches extraction:
```dart
// Path must match extraction
path: '/drivers/:driverNumber'  // ← Must match ↓
final driverNumber = state.pathParameters['driverNumber']
```

### Issue: Transition not showing

**Cause:** Using `builder` instead of `pageBuilder`

**Solution:** Use `pageBuilder` with CustomTransitionPage

### Issue: Back button not working

**Cause:** Using `go()` instead of `push()`

**Solution:**
- Use `go()` for replacing navigation
- Use `push()` for stacking navigation

### Issue: White flash between screens

**Cause:** Background color mismatch

**Solution:** Ensure all screens have consistent background color (F1Colors.navyDeep)

---

## Debug Tips

### Enable GoRouter Logging

Already enabled in app_router.dart:
```dart
GoRouter(
  debugLogDiagnostics: true,
  // ...
)
```

Check console for navigation logs.

### Print Navigation Events

Add to any screen:
```dart
@override
void initState() {
  super.initState();
  print('📍 Navigated to: ${widget.runtimeType}');
}
```

### Check Current Route

```dart
// In any widget
print('Current route: ${GoRouter.of(context).location}');
```

---

## Test Coverage Goals

- [ ] **100%** of routes accessible
- [ ] **100%** of navigation helpers tested
- [ ] **100%** of error scenarios handled
- [ ] **Zero** navigation-related crashes
- [ ] **Smooth** 60 FPS transitions

---

## Sign-off Checklist

Before considering Phase 10 complete:

- [ ] All routes work correctly
- [ ] All transitions are smooth
- [ ] Error handling works for invalid routes
- [ ] Error handling works for invalid parameters
- [ ] Back button works on Android
- [ ] Swipe back works on iOS
- [ ] Extension helpers work correctly
- [ ] No console errors during navigation
- [ ] Documentation is complete
- [ ] Deep linking setup guide is accurate

---

## Next Steps

After Phase 10 is verified:

1. **Create git commit**
   ```bash
   git add .
   git commit -m "Phase 10: Navigation & Routing - Complete routing with GoRouter, transitions, and deep linking support"
   ```

2. **Test on physical devices**
   - Android device
   - iOS device (if available)

3. **Move to Phase 11**
   - Polish & Error Handling
   - Hero animations
   - Advanced transitions

---

**Happy Testing! 🏎️💨**
