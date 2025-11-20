# Drivers Feature

Comprehensive driver browsing with detailed profiles, lap analysis, and stint visualization.

## Overview

The Drivers feature provides users with:
- **Grid/List view** of all F1 drivers
- **Filtering** by team and search
- **Sorting** by number, name, or team
- **Detailed profiles** with statistics
- **Lap time analysis** with interactive charts
- **Tire strategy** visualization

---

## Architecture

### Clean Architecture Layers

```
presentation/          # UI Layer
├── providers/        # State management (Riverpod)
├── widgets/          # Feature-specific UI components
└── screens/          # Full-screen views

domain/               # Business logic
└── repositories/     # Repository interfaces

data/                 # Data layer
├── models/          # Data models (Freezed)
├── datasources/     # API data sources
└── repositories/    # Repository implementations
```

---

## Screens

### 1. Drivers List Screen

**Route:** `/drivers`

**Features:**
- Grid view (default) or list view toggle
- Real-time search (name, acronym, team, number)
- Team filter chips
- Sort options (number, name, team)
- Pull-to-refresh
- Responsive grid (2-4 columns)

**State Management:**
```dart
// Watch drivers list
final driversAsync = ref.watch(driversListNotifierProvider());

// Watch filtered results
final filteredDrivers = ref.watch(filteredDriversProvider);

// Watch filter state
final filterState = ref.watch(driverFilterNotifierProvider);
```

**Navigation:**
```dart
// Tap on driver card
context.push('/drivers/${driver.driverNumber}');
```

---

### 2. Driver Detail Screen

**Route:** `/drivers/:driverNumber`

**Features:**
- Collapsing header with driver photo
- Hero animation
- 3 tabs: Profile, Lap Times, Strategy
- Team color theming throughout
- Sticky tab bar

**Tabs:**

#### Profile Tab
- Total laps
- Pit stops count
- Current position
- Position changes (+/-)
- Fastest lap card
- Average lap time

#### Lap Times Tab
- Interactive line chart (fl_chart)
- X-axis: Lap number
- Y-axis: Lap time (seconds)
- Fastest lap highlighted in gold
- Tooltips with formatted times
- Team color line

#### Strategy Tab
- Horizontal timeline visualization
- Proportional stint bars
- Color-coded compounds
- Detailed stint cards
- Compound legend

**State Management:**
```dart
// Fetch driver detail
final detailAsync = ref.watch(driverDetailNotifierProvider(
  driverNumber: driverNumber,
));

// Access computed properties
final detail = detailAsync.value;
final fastestLap = detail.fastestLap;
final avgTime = detail.averageLapTime;
```

---

## Providers

### DriverFilterProvider

**Purpose:** Manage filter and sort state

**State:**
```dart
class DriverFilterState {
  final DriverFilter filter;     // all, byTeam
  final DriverSort sort;          // byNumber, byName, byTeam
  final String? selectedTeam;
  final String searchQuery;
}
```

**Methods:**
```dart
// Set filter type
ref.read(driverFilterNotifierProvider.notifier).setFilter(DriverFilter.byTeam);

// Set sort
ref.read(driverFilterNotifierProvider.notifier).setSort(DriverSort.byName);

// Set team
ref.read(driverFilterNotifierProvider.notifier).setSelectedTeam('Red Bull Racing');

// Search
ref.read(driverFilterNotifierProvider.notifier).setSearchQuery('verstappen');

// Clear all
ref.read(driverFilterNotifierProvider.notifier).clearFilters();
```

---

### DriversListProvider

**Purpose:** Fetch and cache drivers list

**Providers:**
```dart
// Main drivers list
@riverpod
class DriversListNotifier extends _$DriversListNotifier {
  Future<List<Driver>> build({String sessionKey = 'latest'});
  Future<void> refresh();
}

// Filtered and sorted drivers
@riverpod
List<Driver> filteredDrivers(FilteredDriversRef ref);

// Unique team names
@riverpod
List<String> teamNames(TeamNamesRef ref);
```

**Usage:**
```dart
// Watch all drivers
final drivers = ref.watch(driversListNotifierProvider());

// Watch filtered drivers
final filtered = ref.watch(filteredDriversProvider);

// Refresh
await ref.read(driversListNotifierProvider().notifier).refresh();
```

**Caching:**
- TTL: 1 hour
- Automatic via DriversRepository

---

### DriverDetailProvider

**Purpose:** Aggregate driver data from multiple sources

**Data Class:**
```dart
class DriverDetailData {
  final Driver driver;
  final List<Lap> laps;
  final List<Stint> stints;
  final List<Position> positions;

  // Computed properties
  Lap? get fastestLap;
  double get averageLapTime;
  int get totalLaps;
  int get pitStops;
  int? get currentPosition;
  int get positionChanges;
}
```

**Providers:**
```dart
// Main detail provider
@riverpod
class DriverDetailNotifier extends _$DriverDetailNotifier {
  Future<DriverDetailData> build({
    required int driverNumber,
    String sessionKey = 'latest',
  });
  Future<void> refresh();
}

// Sorted laps
@riverpod
List<Lap> sortedLaps(SortedLapsRef ref, int driverNumber);

// Fastest lap
@riverpod
Lap? fastestLap(FastestLapRef ref, int driverNumber);
```

**Data Fetching:**
Fetches in parallel:
1. Driver info (`/drivers?driver_number={num}`)
2. Lap times (`/laps?driver_number={num}`)
3. Stints (`/stints?driver_number={num}`)
4. Positions (`/position?driver_number={num}`)

**Caching:**
- Drivers: 1 hour
- Laps: 5 minutes
- Stints: 1 hour
- Positions: 5 minutes

---

## Widgets

### DriverCard

**Purpose:** Display driver in grid view

**Props:**
```dart
DriverCard({
  required Driver driver,
  VoidCallback? onTap,
})
```

**Features:**
- 80px driver avatar with team color border
- Huge driver number (48px)
- Driver acronym
- Team name
- Team color strip (left edge)
- Glow effect

**Variant:**
```dart
DriverCardCompact({
  required Driver driver,
  VoidCallback? onTap,
})
```
- Horizontal layout
- 64px avatar
- Full name
- For list view

---

### DriverProfileHeader

**Purpose:** Hero header for detail screen

**Props:**
```dart
DriverProfileHeader({
  required Driver driver,
  double height = 300,
})
```

**Features:**
- Team color gradient background
- Driver headshot (right side)
- Driver number badge
- Full name (uppercase)
- Team name with color strip
- Country flag emoji

**Variant:**
```dart
DriverProfileHeaderCompact({
  required Driver driver,
})
```
- Compact horizontal layout
- For smaller screens

---

### LapTimesChart

**Purpose:** Visualize lap times

**Props:**
```dart
LapTimesChart({
  required List<Lap> laps,
  Color lineColor = F1Colors.ciano,
  Lap? fastestLap,
})
```

**Features:**
- Line chart (fl_chart)
- Team color line
- Gradient fill
- Fastest lap in gold
- Interactive tooltips
- Formatted times (M:SS.mmm)
- Auto-scaling axes
- Grid lines
- Legend

**Chart Configuration:**
- X-axis: Lap number (interval: 5)
- Y-axis: Lap time in seconds (interval: 2)
- Curve: Smooth (isCurved: true)
- Dots: Visible with special marker for fastest lap

---

### StintsTimeline

**Purpose:** Visualize tire strategy

**Props:**
```dart
StintsTimeline({
  required List<Stint> stints,
  required int totalLaps,
})
```

**Features:**
- Horizontal proportional bars
- Color-coded compounds:
  - Soft = Red
  - Medium = Yellow
  - Hard = White
  - Intermediate = Green
  - Wet = Blue
- Grid background
- Detailed stint cards
- Compound legend

**Layout:**
- Timeline: 80px height
- Stint bars: Proportional width
- Cards: Stint number + details

---

## Data Flow

### Drivers List Flow

```
User Action (Search/Filter/Sort)
    ↓
DriverFilterNotifier updates state
    ↓
filteredDriversProvider recomputes
    ↓
UI rebuilds with filtered results
```

### Driver Detail Flow

```
Navigate to /drivers/:driverNumber
    ↓
DriverDetailNotifier.build() called
    ↓
Parallel fetch:
  - DriversRepository.getDriverByNumber()
  - LapsRepository.getLaps()
  - StintsRepository.getStints()
  - PositionsRepository.getPositions()
    ↓
Aggregate into DriverDetailData
    ↓
Compute properties (fastestLap, avgTime, etc.)
    ↓
UI renders with tabs
```

---

## Styling

### Theme Integration

All widgets use F1 design system:

**Colors:**
- Primary: `F1Colors.ciano`
- Team colors: Dynamic from `driver.teamColour`
- Backgrounds: `F1Colors.navyDeep`, `F1Colors.navy`
- Fastest lap: `F1Colors.dourado`
- Success: `F1Colors.success`
- Error: `F1Colors.error`

**Typography:**
```dart
// Driver numbers
F1TextStyles.driverNumber  // 64px, bold, mono

// Lap times
F1TextStyles.lapTime       // 20px, mono, letter-spacing

// Headers
F1TextStyles.displayMedium // 36px, bold
F1TextStyles.headlineMedium // 20px, semi-bold

// Body
F1TextStyles.bodyLarge     // 16px
F1TextStyles.bodyMedium    // 14px
F1TextStyles.bodySmall     // 12px
```

**Shared Components:**
- `F1AppBar` - App bar with gradient
- `DriverAvatar` - Avatar with team border
- `TeamColorStrip` - Vertical color strip
- `LoadingWidget` - Shimmer loading
- `F1ErrorWidget` - Error states
- `F1EmptyStateWidget` - Empty states

---

## Error Handling

### Network Errors
```dart
driversAsync.when(
  data: (drivers) => /* Success */,
  loading: () => LoadingWidget(),
  error: (error, stack) => F1ErrorWidget.generic(
    error: error,
    onRetry: () => ref.invalidate(driversListNotifierProvider()),
  ),
);
```

### Empty States
```dart
if (filteredDrivers.isEmpty) {
  return F1EmptyStateWidget.noResults(
    message: 'No drivers match your filters',
    onAction: () => ref.read(driverFilterNotifierProvider.notifier).clearFilters(),
    actionLabel: 'Clear Filters',
  );
}
```

---

## Performance

### Optimizations
- **Lazy loading**: ListView.builder / GridView.builder
- **Caching**: Smart TTL-based caching
- **Computed providers**: Efficient filtering
- **Parallel fetching**: All driver data fetched concurrently
- **Image caching**: CachedNetworkImage for avatars
- **Downsampling**: For large lap datasets (if needed)

### Memory Management
- Auto-dispose providers when not in use
- Image cache limits via flutter_cache_manager
- Efficient list rendering with builders

---

## Accessibility

### Screen Reader Support
- Semantic labels on interactive elements
- ARIA-like descriptions for charts
- Descriptive button labels

### Contrast
- WCAG AA compliant color combinations
- Team colors validated for readability
- Text color adjusts based on background luminance

### Touch Targets
- Minimum 44x44px tap targets
- Adequate spacing between interactive elements

---

## Testing

### Unit Tests
```dart
// Test filtering logic
test('filters drivers by team', () {
  final filtered = /* apply filter */;
  expect(filtered.every((d) => d.teamName == 'Red Bull Racing'), true);
});

// Test sorting
test('sorts drivers by number', () {
  final sorted = /* apply sort */;
  expect(sorted, isSortedBy((d) => d.driverNumber));
});

// Test computed properties
test('calculates fastest lap', () {
  final detail = DriverDetailData(/* ... */);
  expect(detail.fastestLap.lapDuration, lessThan(90));
});
```

### Widget Tests
```dart
testWidgets('DriverCard displays driver info', (tester) async {
  await tester.pumpWidget(
    DriverCard(driver: mockDriver),
  );

  expect(find.text(mockDriver.nameAcronym), findsOneWidget);
  expect(find.text(mockDriver.driverNumber.toString()), findsOneWidget);
});
```

### Integration Tests
- Navigate to drivers list
- Search for driver
- Filter by team
- Navigate to detail
- Switch tabs

---

## Future Enhancements

### Phase 9+ Features
- **Compare drivers**: Side-by-side comparison
- **Season stats**: Championship standings
- **Historical data**: Past seasons
- **Favorite drivers**: Save favorites
- **Notifications**: Driver updates
- **Team radio**: Audio playback
- **Telemetry**: Speed, throttle, brake charts

### Nice-to-Haves
- **Export data**: Share lap times
- **Offline mode**: Cached data
- **Dark/Light themes**: Theme toggle
- **Animations**: Enhanced transitions
- **Haptic feedback**: iOS/Android vibrations

---

## Dependencies

### Required Packages
```yaml
flutter_riverpod: ^2.4.9      # State management
riverpod_annotation: ^2.3.3   # Code generation
go_router: ^13.0.0            # Navigation
fl_chart: ^0.66.0             # Charts
cached_network_image: ^3.3.1  # Image caching
freezed_annotation: ^2.4.1    # Immutable models
```

### Dev Dependencies
```yaml
riverpod_generator: ^2.3.9    # Provider generation
build_runner: ^2.4.7          # Code generation
```

---

## Code Generation

After modifying providers, run:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

This generates:
- `driver_filter_provider.g.dart`
- `drivers_list_provider.g.dart`
- `driver_detail_provider.g.dart`

---

## Examples

### Example 1: Basic Usage
```dart
class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      routerConfig: ref.watch(routerProvider),
    );
  }
}
```

### Example 2: Filter Drivers
```dart
// In your widget
final filterNotifier = ref.read(driverFilterNotifierProvider.notifier);

// Search
filterNotifier.setSearchQuery('hamilton');

// Filter by team
filterNotifier.setSelectedTeam('Mercedes');

// Sort
filterNotifier.setSort(DriverSort.byName);

// Clear
filterNotifier.clearFilters();
```

### Example 3: Show Driver Detail
```dart
// Navigate
context.push('/drivers/44'); // Lewis Hamilton

// Or using go_router directly
context.goNamed(
  'driver-detail',
  pathParameters: {'driverNumber': '44'},
);
```

### Example 4: Custom Chart Color
```dart
LapTimesChart(
  laps: detail.laps,
  lineColor: Color(0xFF00D9FF), // Custom team color
  fastestLap: detail.fastestLap,
)
```

---

## Troubleshooting

### Issue: Drivers not loading
**Solution:** Check network connectivity, verify API endpoint, check cache TTL

### Issue: Code generation fails
**Solution:** Run `flutter pub get`, then `flutter pub run build_runner clean`, then `flutter pub run build_runner build`

### Issue: Images not showing
**Solution:** Verify `headshotUrl` is valid, check network, clear image cache

### Issue: Chart not rendering
**Solution:** Ensure laps list is not empty, check for valid lap times, verify fl_chart dependency

---

## Maintainers

This feature was implemented as part of **Phase 8** of the F1Sync project.

**Related Documentation:**
- [PLANNING.md](../../../docs/PLANNING.md)
- [API_ANALYSIS.md](../../../docs/API_ANALYSIS.md)
- [THEME.md](../../../docs/THEME.md)
- [PHASE_8_IMPLEMENTATION.md](../../PHASE_8_IMPLEMENTATION.md)

---

**Version:** 1.0.0
**Last Updated:** 2025-11-20
