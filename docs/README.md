# F1Sync Documentation

**Version:** 1.0
**Last Updated:** 2025-11-20

---

## Quick Start

### Run the App

```bash
# Development mode
flutter run

# Profile mode (for performance testing)
flutter run --profile

# Release mode
flutter run --release
```

### Run Code Analysis

```bash
# Check for issues
flutter analyze

# Format code
flutter format lib/ test/

# Get dependencies
flutter pub get
```

### Build Release

```bash
# Android APK (split by architecture - recommended)
flutter build apk --release --split-per-abi

# Android App Bundle (for Play Store)
flutter build appbundle --release

# iOS
flutter build ios --release
```

---

## Documentation Index

### Planning Documentation
Located in: `/var/tmp/automagik-forge/worktrees/f07a-planning/docs/`

- **PLANNING.md** - Complete project planning with architecture and phases
- **API_ANALYSIS.md** - Detailed OpenF1 API documentation
- **THEME.md** - F1 design system (colors, gradients, typography)

### Phase 12 Documentation
Located in: `docs/`

- **TESTING_GUIDE.md** - Comprehensive testing procedures and checklists
- **BUILD_OPTIMIZATION.md** - Build configuration and APK optimization
- **PHASE_12_SUMMARY.md** - Phase 12 completion summary and status

---

## Project Structure

```
lib/
├── core/                         # Core functionality
│   ├── cache/                    # Cache service (legacy)
│   ├── config/                   # App configuration
│   ├── constants/                # API and app constants
│   ├── error/                    # Error handling
│   ├── network/                  # HTTP client and networking
│   ├── router/                   # Navigation configuration
│   ├── theme/                    # F1 theme (colors, gradients, text)
│   └── utils/                    # Utilities
│       ├── performance_monitor.dart  # Performance tracking
│       └── responsive_utils.dart     # Responsive layout helpers
├── features/                     # Feature modules
│   ├── drivers/                  # Driver profiles
│   ├── home/                     # Dashboard
│   ├── laps/                     # Lap times
│   ├── meetings/                 # GPs/Races
│   ├── positions/                # Position data
│   ├── race_control/             # Race control messages
│   ├── session_results/          # Session results
│   ├── sessions/                 # Session details
│   ├── stints/                   # Stint data
│   └── weather/                  # Weather data
├── shared/                       # Shared code
│   ├── models/                   # Shared data models
│   ├── services/                 # Shared services
│   │   ├── cache/               # Cache implementation
│   │   │   ├── cache_service.dart    # Unified cache
│   │   │   ├── memory_cache.dart     # In-memory cache
│   │   │   ├── disk_cache.dart       # Persistent cache
│   │   │   └── cache_entry.dart      # Cache entry model
│   │   ├── connectivity_service.dart # Network monitoring
│   │   └── providers.dart           # Service providers
│   └── widgets/                  # Shared widgets
│       ├── offline_banner.dart   # Offline mode UI
│       ├── f1_app_bar.dart      # Custom app bar
│       ├── loading_widget.dart   # Loading states
│       ├── error_widget.dart     # Error states
│       └── empty_state_widget.dart # Empty states
└── main.dart                     # App entry point
```

---

## Key Features

### ✅ Implemented

- **Multi-Layer Caching** - Memory + Disk with TTL
- **Offline Mode** - Full offline support with banner
- **Performance Monitoring** - Track API, cache, and timing
- **Responsive Layouts** - Adapts to phone/tablet/desktop
- **Rate Limiting** - 60 req/min API limit
- **Retry Logic** - Exponential backoff for failures
- **Error Handling** - Comprehensive error mapping
- **Dark Theme** - F1-inspired design system

### 🔄 Future Enhancements

- Unit tests
- Integration tests
- Firebase Performance Monitoring
- Crash reporting with Sentry
- Live timing feature
- Push notifications

---

## Performance Targets

| Metric | Target | Status |
|--------|--------|--------|
| API Response | < 2s | ✅ Ready |
| Cache Hit Rate | > 70% | ✅ Ready |
| App Startup | < 3s | ✅ Ready |
| Frame Rate | 60 FPS | ✅ Ready |
| APK Size | < 50 MB | ⚠️ To verify |

---

## Testing

### Automated

```bash
# Run static analysis
flutter analyze

# Run tests (when added)
flutter test

# Check code coverage (when tests added)
flutter test --coverage
```

### Manual

See **TESTING_GUIDE.md** for complete testing procedures:
- Platform testing (Android/iOS)
- Functionality testing
- Performance testing
- Offline mode testing
- Responsive layout testing

### Performance Monitoring

```dart
import 'package:f1sync/core/utils/performance_monitor.dart';

// Measure operation
final data = await PerformanceMonitor.measure(
  'api_call',
  () => apiClient.getData(),
  warnThreshold: 2000,
);

// Track cache
PerformanceMonitor.trackCacheHit('key');

// Log summary
PerformanceMonitor.logSummary();
```

---

## Development Workflow

### 1. Start Development

```bash
# Get dependencies
flutter pub get

# Run app
flutter run
```

### 2. Make Changes

- Follow clean architecture pattern
- Add features in `lib/features/`
- Use Riverpod for state management
- Document public APIs

### 3. Verify Code Quality

```bash
# Run analyzer
flutter analyze

# Format code
flutter format .

# Check for issues
flutter pub run dart_code_metrics:metrics analyze lib
```

### 4. Test Changes

- Test on emulator/simulator
- Test on physical device
- Test offline mode
- Check performance with DevTools

### 5. Commit Changes

```bash
git add .
git commit -m "Description of changes"
```

---

## Dependencies

### Production

- `flutter_riverpod` ^2.4.9 - State management
- `go_router` ^13.0.0 - Navigation
- `dio` ^5.4.0 - HTTP client
- `hive` ^2.2.3 - Local database
- `connectivity_plus` ^5.0.2 - Network monitoring
- `fl_chart` ^0.66.0 - Charts
- `shimmer` ^3.0.0 - Loading animations
- `cached_network_image` ^3.3.1 - Image caching

### Development

- `flutter_lints` ^3.0.0 - Linting rules
- `build_runner` ^2.4.7 - Code generation
- `riverpod_generator` ^2.3.9 - Provider generation

---

## API

F1Sync uses the **OpenF1 API** (https://openf1.org):
- Base URL: `https://api.openf1.org/v1`
- No authentication required
- Rate limit: 60 requests/minute (client-side)
- Timeout: 30 seconds

See **API_ANALYSIS.md** for detailed endpoint documentation.

---

## Cache Strategy

### TTL Configuration

- **Short (5 min)**: Live data (weather, race control)
- **Medium (1 hour)**: Session data, driver lists
- **Long (7 days)**: Historical data, past GPs
- **Permanent (365 days)**: Final results

### Storage Layers

1. **Memory Cache**: Fast, 500 entries max, LRU eviction
2. **Disk Cache**: Persistent, Hive database
3. **Network**: Fetch from API on cache miss

---

## Troubleshooting

### Common Issues

**Issue: flutter analyze shows errors**
```bash
# Run pub get
flutter pub get

# Clean build
flutter clean
```

**Issue: Cache not working**
```dart
// Check cache initialization
final cacheService = ref.read(cacheServiceProvider);
await cacheService.init();
```

**Issue: Offline mode not showing**
```dart
// Verify connectivity service
final connectivity = ref.read(connectivityServiceProvider);
final status = await connectivity.currentStatus;
print(status); // Should show current status
```

**Issue: Performance issues**
```bash
# Run in profile mode
flutter run --profile

# Open DevTools
# Check Performance tab
```

---

## Support

### Resources

- Flutter Documentation: https://docs.flutter.dev
- Riverpod Documentation: https://riverpod.dev
- OpenF1 API: https://openf1.org
- F1Sync Testing Guide: `docs/TESTING_GUIDE.md`

### Report Issues

Check the following before reporting:
1. Run `flutter doctor` - ensure environment is set up
2. Run `flutter clean && flutter pub get`
3. Check Flutter and Dart SDK versions
4. Review error logs in console

---

## License

[Add your license here]

---

## Contributors

[Add contributors here]

---

**Last Updated:** 2025-11-20
**Flutter Version:** 3.x
**Dart Version:** 3.x
