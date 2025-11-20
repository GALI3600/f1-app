# 05 - Shared UI Components

**Phase:** 5
**Priority:** MEDIUM
**Status:** ⚪ TODO
**Estimated:** 6-7 hours

## Description

Create reusable UI components with F1 theme styling for consistent design across the app.

## Tasks

### Task 5.1: Core UI Widgets
**Status:** ⚪ TODO
**Time:** 6-7h
**Dependencies:** Task 1.2 (Theme System)

**Subtasks:**
- [ ] Create `F1Card` widget (gradient border)
- [ ] Create `F1AppBar` widget (cyan→purple gradient)
- [ ] Create `LoadingWidget` with shimmer effect
- [ ] Create `ErrorWidget` for error states
- [ ] Create `EmptyStateWidget` for empty lists
- [ ] Create `DriverAvatar` (team color border)
- [ ] Create `LiveIndicator` pulsing widget
- [ ] Create `TeamColorStrip` vertical bar

**Files:**
- `lib/shared/widgets/f1_card.dart`
- `lib/shared/widgets/f1_app_bar.dart`
- `lib/shared/widgets/loading_widget.dart`
- `lib/shared/widgets/error_widget.dart`
- `lib/shared/widgets/empty_state_widget.dart`
- `lib/shared/widgets/driver_avatar.dart`
- `lib/shared/widgets/live_indicator.dart`
- `lib/shared/widgets/team_color_strip.dart`

## Widget Specifications

### F1Card
```dart
F1Card(
  child: Widget,
  gradient: Gradient?, // Optional gradient border
  padding: EdgeInsets,
  onTap: VoidCallback?,
)
```
- Navy background
- Optional gradient border (1-2px)
- Border radius: 12px
- Elevation: 0 (use border for depth)

### F1AppBar
```dart
F1AppBar(
  title: String,
  actions: List<Widget>?,
  gradient: Gradient, // Default: cyan→purple
)
```
- Gradient background
- White text/icons
- Center title
- Height: 56px

### LoadingWidget
```dart
LoadingWidget(
  type: LoadingType, // shimmer, spinner, linear
)
```
- Shimmer effect with F1 colors
- Multiple loading types
- Respects theme

### DriverAvatar
```dart
DriverAvatar(
  imageUrl: String?,
  teamColorHex: String,
  size: double,
  fallbackText: String, // Acronym
)
```
- Circular
- Team color border (3px)
- Cached image
- Fallback to initials

### LiveIndicator
```dart
LiveIndicator(
  isLive: bool,
  text: String?, // Optional "LIVE" text
)
```
- Red pulsing dot (8px)
- Animated glow effect
- 1.5s pulse cycle

## Design System Integration

All widgets must:
- Use F1Colors for colors
- Use F1Gradients for gradients
- Use F1TextStyles for typography
- Support dark theme
- Be accessible (contrast, touch targets)

## Dependencies

- Task 1.2 (Theme System)
- shimmer package
- cached_network_image package

## Success Criteria

- [ ] All 8 widgets implemented
- [ ] Widgets match design specs
- [ ] Widgets reusable and configurable
- [ ] No visual bugs
- [ ] Performance optimized

## Next Steps

After completion, proceed to Phase 6: Home Feature
