# F1Sync Shared Widgets

A collection of reusable UI components following the F1 design system with animations and proper styling.

## Overview

All widgets in this directory follow the F1 design system and provide:
- ✅ Consistent F1 branding (colors, gradients, typography)
- ✅ Smooth 60fps animations
- ✅ Responsive design
- ✅ Hot reload support
- ✅ Comprehensive documentation

## Widgets

### 1. F1Card (`f1_card.dart`)

Card component with gradient border options.

**Variants:**
- `F1Card()` - Primary variant with solid cyan border
- `F1Card.primary()` - Explicit primary variant
- `F1Card.gradient()` - Gradient border (cyan → purple)
- `F1Card.elevated()` - Larger shadow for emphasis
- `F1Card.outlined()` - Transparent background with border only

**Usage:**
```dart
F1Card(
  child: Text('Content'),
  onTap: () => print('Tapped'),
)

F1Card.gradient(
  padding: EdgeInsets.all(20),
  child: Column(
    children: [
      Text('Gradient Card'),
      Text('With custom content'),
    ],
  ),
)
```

**Features:**
- Background: `F1Colors.navy`
- Border: Customizable (solid cyan or gradient)
- Border Radius: 12px (customizable)
- Padding: 16px (customizable)
- Shadow: Soft glow effect
- Interactive: Optional `onTap` callback

---

### 2. F1AppBar (`f1_app_bar.dart`)

App bar with gradient background.

**Variants:**
- `F1AppBar()` - Standard app bar
- `F1SliverAppBar()` - Scrollable sliver app bar

**Usage:**
```dart
F1AppBar(
  title: 'F1 Sync',
  actions: [
    IconButton(
      icon: Icon(Icons.search),
      onPressed: () {},
    ),
  ],
)

// In CustomScrollView
F1SliverAppBar(
  title: 'Drivers',
  expandedHeight: 200,
  pinned: true,
)
```

**Features:**
- Background: `F1Gradients.cianRoxo` (cyan → purple)
- Height: 56px (customizable)
- Elevation: 0
- Text/Icon Color: White
- Center Title: true by default

---

### 3. LoadingWidget (`loading_widget.dart`)

Shimmer loading skeleton with F1 branding.

**Variants:**
- `LoadingWidget()` - Basic loading widget
- `LoadingWidget.card()` - Card-shaped skeleton
- `LoadingWidget.listItem()` - List item skeleton
- `LoadingWidget.circle()` - Circular skeleton (for avatars)
- `LoadingWidget.text()` - Text line skeleton
- `LoadingListWidget()` - List of loading items
- `LoadingGridWidget()` - Grid of loading items
- `DriverCardLoadingWidget()` - Specialized driver card skeleton
- `RaceCardLoadingWidget()` - Specialized race card skeleton

**Usage:**
```dart
LoadingWidget.card()

LoadingWidget.circle(size: 64)

LoadingListWidget(itemCount: 5)

LoadingWidget.custom(
  child: Container(
    height: 200,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
    ),
  ),
)
```

**Features:**
- Base Color: `F1Colors.navy`
- Highlight Color: `F1Colors.ciano` with 0.3 opacity
- Animation: 1.5s loop
- Uses shimmer package

---

### 4. F1ErrorWidget (`error_widget.dart`)

Error display with optional retry action.

**Variants:**
- `F1ErrorWidget()` - Generic error
- `F1ErrorWidget.network()` - Network connection error
- `F1ErrorWidget.server()` - Server error
- `F1ErrorWidget.notFound()` - 404 not found
- `F1ErrorWidget.unauthorized()` - 401 unauthorized
- `F1CompactErrorWidget()` - Inline compact error

**Usage:**
```dart
F1ErrorWidget(
  title: 'Failed to load data',
  message: 'Please check your internet connection',
  onRetry: () => loadData(),
)

F1ErrorWidget.network(
  onRetry: () => retry(),
)

F1CompactErrorWidget(
  message: 'Connection failed',
  onRetry: () => retry(),
)
```

**Features:**
- Icon: Customizable (defaults to `error_outline`)
- Title: `F1TextStyles.headlineMedium`
- Message: `F1TextStyles.bodyMedium`
- Retry Button: ElevatedButton with `F1Colors.ciano`
- Debug Mode: Optional error details display

---

### 5. F1EmptyStateWidget (`empty_state_widget.dart`)

Empty state display with optional action.

**Variants:**
- `F1EmptyStateWidget()` - Generic empty state
- `F1EmptyStateWidget.noData()` - No data available
- `F1EmptyStateWidget.noResults()` - No search results
- `F1EmptyStateWidget.noRaces()` - No races scheduled
- `F1EmptyStateWidget.noDrivers()` - No drivers
- `F1EmptyStateWidget.noFavorites()` - No favorites
- `F1EmptyStateWidget.offline()` - Offline mode
- `F1CompactEmptyStateWidget()` - Inline compact empty state
- `F1CustomEmptyStateWidget()` - Custom illustration

**Usage:**
```dart
F1EmptyStateWidget(
  icon: Icons.inbox_outlined,
  title: 'No races yet',
  message: 'Check back later for upcoming races',
  onAction: () => refresh(),
  actionText: 'Refresh',
)

F1EmptyStateWidget.noResults()

F1CustomEmptyStateWidget(
  illustration: Image.asset('assets/empty.png'),
  title: 'No Data',
  message: 'Start by adding your first item',
)
```

**Features:**
- Icon: Customizable (64px by default)
- Title: `F1TextStyles.headlineSmall`
- Message: `F1TextStyles.bodyMedium`
- Action: Optional TextButton or ElevatedButton

---

### 6. DriverAvatar (`driver_avatar.dart`)

Circular avatar with team color border.

**Variants:**
- `DriverAvatar()` - Default avatar
- `DriverAvatar.small()` - 48px
- `DriverAvatar.medium()` - 64px
- `DriverAvatar.large()` - 96px
- `DriverAvatarWithPosition()` - Avatar with position badge

**Usage:**
```dart
DriverAvatar(
  imageUrl: driver.headshotUrl,
  teamColor: driver.teamColour,
  driverName: driver.fullName,
  size: DriverAvatarSize.large,
)

DriverAvatar.medium(
  imageUrl: 'https://example.com/image.jpg',
  teamColor: '00D9FF',
  driverName: 'Max Verstappen',
)

DriverAvatarWithPosition(
  imageUrl: driver.headshotUrl,
  teamColor: driver.teamColour,
  driverName: driver.fullName,
  position: 1,
  size: DriverAvatarSize.large,
)
```

**Features:**
- Sizes: 48px, 64px, 96px (customizable)
- Border Width: 3px (customizable)
- Border Color: Team color from hex
- Background: `F1Colors.navy` (if no image)
- Placeholder: Driver initials
- Uses `CachedNetworkImage`
- Position badge for podium positions

---

### 7. LiveIndicator (`live_indicator.dart`)

Pulsing indicator for live sessions.

**Variants:**
- `LiveIndicator()` - Dot only
- `LiveIndicator.withLabel()` - Dot with "LIVE" label
- `LiveIndicator.large()` - Larger indicator with label
- `LiveIndicatorBadge()` - Badge-style indicator
- `SessionStatusIndicator()` - Status indicator (live/upcoming/finished)

**Usage:**
```dart
LiveIndicator()

LiveIndicator.withLabel()

LiveIndicatorBadge()

SessionStatusIndicator(
  status: SessionStatus.live,
)

SessionStatusIndicator(
  status: SessionStatus.upcoming,
  labelText: 'STARTS IN 5 MIN',
)
```

**Features:**
- Size: 8px dot (customizable)
- Color: `F1Colors.vermelho` (red)
- Animation: Pulse (1.5s loop) with scale 1.0 ↔ 1.3
- Glow: BoxShadow with red opacity
- Label: Optional "LIVE" text in `F1TextStyles.liveIndicator`
- Label Position: Configurable (left/right/top/bottom)

---

### 8. TeamColorStrip (`team_color_strip.dart`)

Vertical/horizontal strip with team color.

**Variants:**
- `TeamColorStrip()` - Vertical strip
- `TeamColorStrip.thin()` - 2px wide
- `TeamColorStrip.medium()` - 4px wide (default)
- `TeamColorStrip.thick()` - 6px wide
- `TeamColorStrip.withGlow()` - Strip with glow effect
- `HorizontalTeamColorStrip()` - Horizontal strip
- `TeamColorCard()` - Card with leading team color strip
- `TeamColorDivider()` - Divider with team color

**Usage:**
```dart
Row(
  children: [
    TeamColorStrip(teamColor: driver.teamColour),
    Expanded(child: content),
  ],
)

TeamColorCard(
  teamColor: driver.teamColour,
  child: Text('Card with team strip'),
  onTap: () {},
)

HorizontalTeamColorStrip(
  teamColor: '00D9FF',
  height: 4,
)

TeamColorDivider(
  teamColor: driver.teamColour,
  thickness: 2,
)
```

**Features:**
- Width: 4px (vertical, customizable)
- Height: Match parent or custom
- Color: Team color from hex
- Position: Leading edge (vertical) or top/bottom (horizontal)
- Glow: Optional BoxShadow effect

---

## Design System Compliance

All widgets use:
- **Colors:** `F1Colors` (navy, ciano, roxo, vermelho, dourado)
- **Gradients:** `F1Gradients` (cianRoxo, roxoVermelho, etc.)
- **Typography:** `F1TextStyles` (headlineMedium, bodyMedium, etc.)
- **Animations:** 60fps smooth animations
- **Consistency:** Unified spacing, borders, and shadows

## Usage Example

```dart
import 'package:f1sync/shared/widgets/widgets.dart';

class MyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: F1AppBar(
        title: 'Drivers',
      ),
      body: F1Card.gradient(
        child: Column(
          children: [
            Row(
              children: [
                DriverAvatar.medium(
                  imageUrl: driver.headshotUrl,
                  teamColor: driver.teamColour,
                  driverName: driver.fullName,
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    driver.fullName,
                    style: F1TextStyles.headlineSmall,
                  ),
                ),
                LiveIndicator.withLabel(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

## Hot Reload

All widgets support Flutter's hot reload. Changes to widget properties will be reflected immediately during development.

## Testing

A test file `_widgets_test.dart` is included to verify all widgets compile correctly. This file should be removed before production.

## Next Steps

These widgets will be used in:
- Phase 6: Home Feature
- Phase 7: Drivers Feature
- Phase 8: Teams Feature
- Phase 9: Races Feature
- Phase 10: Live Timing Feature

## References

- Theme System: `lib/core/theme/`
- Design Specs: `THEME.md` in planning docs
- F1 Branding: Official F1 color palette and gradients
