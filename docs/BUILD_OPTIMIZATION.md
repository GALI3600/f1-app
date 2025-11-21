# F1Sync - Build & APK Optimization Guide

**Version:** 1.0
**Date:** 2025-11-20

---

## Overview

This guide provides instructions for optimizing the F1Sync app's build size and startup performance to meet Phase 12 targets.

---

## Performance Targets

| Metric | Target | Status |
|--------|--------|--------|
| APK Size | < 50 MB | ⚠️ To be verified |
| Startup Time | < 3s | ⚠️ To be verified |
| App Size (installed) | < 150 MB | ⚠️ To be verified |

---

## Android Build Optimization

### 1. Initialize Android Project

If not already done:

```bash
cd /var/tmp/automagik-forge/worktrees/d25d-phase-12-testing
flutter create --platforms=android,ios .
```

### 2. Configure ProGuard/R8 (Code Shrinking)

Edit `android/app/build.gradle`:

```gradle
android {
    ...
    buildTypes {
        release {
            // Enable code shrinking and resource shrinking
            minifyEnabled true
            shrinkResources true

            // Use ProGuard rules
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'

            // Signing config (configure as needed)
            signingConfig signingConfigs.debug
        }
    }
}
```

### 3. Create ProGuard Rules

Create `android/app/proguard-rules.pro`:

```proguard
# Keep F1Sync app classes
-keep class com.example.f1sync.** { *; }

# Keep Flutter framework
-keep class io.flutter.** { *; }
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }

# Keep Riverpod
-keep class com.riverpod.** { *; }

# Keep Hive
-keep class io.hivedb.** { *; }
-keep class * extends io.hivedb.TypeAdapter {
    <init>();
}

# Keep Dio
-keep class com.dio.** { *; }

# Keep JSON serialization classes
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}
-keep class * implements com.google.gson.TypeAdapter
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

# Keep model classes with JSON serialization
-keepclassmembers class ** {
    @com.google.gson.annotations.SerializedName <fields>;
}

# Keep Parcelable classes
-keep class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}

# Keep enums
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}
```

### 4. Split APKs by ABI (Recommended)

Build separate APKs for each CPU architecture:

```bash
# Split by ABI (smaller APKs for each architecture)
flutter build apk --release --split-per-abi

# Result:
# app-armeabi-v7a-release.apk  (~15-20 MB)
# app-arm64-v8a-release.apk    (~18-22 MB)
# app-x86_64-release.apk       (~20-25 MB)
```

Benefits:
- Users only download their architecture
- Smaller download size
- Play Store automatically selects correct APK

### 5. Build App Bundle (Recommended for Play Store)

```bash
# Build Android App Bundle
flutter build appbundle --release

# Result: build/app/outputs/bundle/release/app-release.aab
# Play Store will generate optimized APKs for each device
```

Benefits:
- Play Store generates optimized APKs
- Automatic configuration splits
- Even smaller downloads for users
- Dynamic feature modules support

---

## iOS Build Optimization

### 1. Enable Bitcode (if applicable)

Edit `ios/Runner.xcodeproj/project.pbxproj` or use Xcode:

```
ENABLE_BITCODE = YES
```

### 2. Set Optimization Level

In Xcode, under Build Settings:
- Optimization Level (Release): `-O3` (Aggressive Size)
- Strip Debug Symbols: `YES`
- Strip Swift Symbols: `YES`

### 3. Build IPA

```bash
flutter build ios --release

# Or for App Store
flutter build ipa --release
```

---

## Startup Performance Optimization

### 1. Defer Heavy Initialization

Current `main.dart` is already optimized:

```dart
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Only critical initialization here
  GlobalErrorHandler.initialize();

  // System UI setup
  SystemChrome.setSystemUIOverlayStyle(...);

  // Defer heavy work until after first frame
  runApp(const ProviderScope(child: F1SyncApp()));
}
```

### 2. Initialize Services Lazily

Services are initialized lazily via Riverpod providers:

```dart
// Cache initialized on first use
final cacheServiceProvider = Provider<CacheService>((ref) {
  final service = CacheService();
  service.init(); // Async initialization
  return service;
});
```

### 3. Use `runApp` Immediately

Don't await async operations before `runApp()`. Show a splash screen instead:

```dart
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Fast initialization only
  GlobalErrorHandler.initialize();

  // Show app immediately
  runApp(const ProviderScope(child: F1SyncApp()));

  // Heavy initialization happens in background
  // (via providers and lazy loading)
}
```

### 4. Reduce Initial Route Complexity

Keep home screen simple and fast to render:
- Lazy load lists
- Use placeholders/skeletons
- Defer network calls until after first frame

---

## Dependency Optimization

### 1. Analyze Dependency Sizes

```bash
# See dependency tree
flutter pub deps --style=compact

# Analyze what's taking space
flutter build apk --analyze-size
```

### 2. Current Dependencies (Already Optimized)

✅ All dependencies are necessary and lightweight:
- `flutter_riverpod` - State management (small)
- `go_router` - Navigation (small)
- `dio` - HTTP client (medium, necessary)
- `hive` - Database (small)
- `fl_chart` - Charts (medium, necessary for features)

❌ No bloated dependencies like:
- Firebase (unless needed)
- Heavy UI libraries
- Unused icon packs

### 3. Remove Unused Dependencies

```bash
# Check for unused dependencies
flutter pub deps --json | grep unused

# Remove any unused dependencies from pubspec.yaml
```

---

## Asset Optimization

### 1. Images (When Added)

**Use WebP format:**
```bash
# Convert PNG/JPG to WebP
cwebp input.png -q 80 -o output.webp

# In pubspec.yaml
flutter:
  assets:
    - assets/images/logo.webp
```

**Provide multiple resolutions:**
```
assets/
  images/
    logo.webp       (1x)
    2.0x/
      logo.webp     (2x)
    3.0x/
      logo.webp     (3x)
```

### 2. Fonts

Only include used font weights:

```yaml
# BAD - includes all weights
fonts:
  - family: Roboto
    fonts:
      - asset: fonts/Roboto-Thin.ttf
      - asset: fonts/Roboto-Light.ttf
      - asset: fonts/Roboto-Regular.ttf
      - asset: fonts/Roboto-Medium.ttf
      - asset: fonts/Roboto-Bold.ttf
      - asset: fonts/Roboto-Black.ttf

# GOOD - only used weights
fonts:
  - family: Roboto
    fonts:
      - asset: fonts/Roboto-Regular.ttf
      - asset: fonts/Roboto-Bold.ttf
```

Currently, F1Sync uses system fonts (no custom fonts = smaller size).

### 3. Icons

Use Flutter's built-in Material Icons instead of custom icon fonts when possible.

---

## Build Commands Reference

### Development Builds

```bash
# Debug build (for testing)
flutter run

# Profile build (for performance testing)
flutter run --profile

# Release build (for final testing)
flutter run --release
```

### Production Builds

```bash
# Android APK (universal)
flutter build apk --release

# Android APK (split by architecture) - RECOMMENDED
flutter build apk --release --split-per-abi

# Android App Bundle (for Play Store) - RECOMMENDED
flutter build appbundle --release

# iOS
flutter build ios --release
flutter build ipa --release
```

### Analyze Build Size

```bash
# Analyze APK size
flutter build apk --release --analyze-size

# Output shows size breakdown by package
```

---

## Testing Build Performance

### 1. Measure APK Size

```bash
# Build release APK
flutter build apk --release

# Check size
ls -lh build/app/outputs/flutter-apk/app-release.apk

# Or with split ABIs
ls -lh build/app/outputs/flutter-apk/*.apk
```

**Target:** < 50 MB per APK

### 2. Measure Startup Time

**Using Flutter DevTools:**

```bash
# Run in profile mode
flutter run --profile

# Open DevTools
# Go to Performance tab
# Restart app
# Check "Time to First Frame" in timeline
```

**Target:** < 3 seconds

**Manual Testing:**
1. Close app completely
2. Clear from recent apps
3. Launch app
4. Time until interactive (can scroll/tap)

### 3. Measure Installed Size

```bash
# Install APK on device
adb install build/app/outputs/flutter-apk/app-release.apk

# Check installed size
adb shell pm path com.example.f1sync
adb shell du -h /data/app/com.example.f1sync-*/base.apk
```

**Target:** < 150 MB installed

---

## Optimization Checklist

### Before Release Build

- [ ] Run `flutter clean`
- [ ] Run `flutter pub get`
- [ ] Run `flutter analyze` (should be 0 issues)
- [ ] Update version in `pubspec.yaml`
- [ ] Remove all debug code/logs
- [ ] Test in `--profile` mode first

### Build Configuration

- [ ] ProGuard/R8 enabled (`minifyEnabled true`)
- [ ] Resource shrinking enabled (`shrinkResources true`)
- [ ] ProGuard rules configured
- [ ] Signing configured (for production)

### Build Options

- [ ] Use `--split-per-abi` for APKs
- [ ] OR use `appbundle` for Play Store
- [ ] Enable `--obfuscate` for security (optional)
- [ ] Use `--split-debug-info` for crash reports (optional)

### Post-Build Verification

- [ ] Check APK size (< 50 MB)
- [ ] Test on physical device
- [ ] Verify startup time (< 3s)
- [ ] Check installed size (< 150 MB)
- [ ] Test all features work
- [ ] No crashes or errors

---

## Advanced Optimizations

### 1. Tree Shaking (Automatic)

Flutter automatically removes unused code in release builds. No configuration needed.

### 2. Deferred Loading (Future Enhancement)

For very large apps, split features into separate modules:

```dart
// Load feature on demand
import 'package:f1sync/features/live_timing.dart' deferred as live_timing;

// Later, when needed:
await live_timing.loadLibrary();
```

Currently not needed for F1Sync.

### 3. Web Assembly (Web Build)

For web builds, Flutter uses Web Assembly for better performance:

```bash
flutter build web --release --wasm
```

### 4. Obfuscation (Security)

Obfuscate code to make reverse engineering harder:

```bash
flutter build apk --release --obfuscate --split-debug-info=./debug-info
```

Store `debug-info/` for crash symbolication.

---

## Troubleshooting

### APK Too Large (> 50 MB)

1. **Check dependency sizes:**
   ```bash
   flutter build apk --analyze-size
   ```

2. **Remove unused dependencies**

3. **Use split APKs:**
   ```bash
   flutter build apk --release --split-per-abi
   ```

4. **Check assets:**
   - Remove unused images
   - Compress images
   - Use WebP format

### Slow Startup (> 3s)

1. **Profile with DevTools:**
   ```bash
   flutter run --profile
   ```

2. **Check initialization code:**
   - Move heavy work after `runApp()`
   - Use lazy initialization
   - Defer network calls

3. **Check widget complexity:**
   - Simplify home screen
   - Use `const` constructors
   - Minimize initial route depth

### Build Errors with ProGuard

1. **Add keep rules** for problematic packages
2. **Check ProGuard logs:** `build/app/outputs/mapping/release/`
3. **Disable temporarily** to isolate issue

---

## Continuous Monitoring

### During Development

```dart
// Use PerformanceMonitor
import 'package:f1sync/core/utils/performance_monitor.dart';

void main() {
  // Track app startup
  final stopwatch = PerformanceMonitor.start('app_startup');

  WidgetsFlutterBinding.ensureInitialized();
  // ... initialization ...

  runApp(const ProviderScope(child: F1SyncApp()));

  PerformanceMonitor.stop(stopwatch, 'app_startup', warnThreshold: 3000);
}
```

### In Production (Future)

Consider adding:
- Firebase Performance Monitoring
- Sentry for crash reports
- Custom analytics events

---

## Summary

Current optimization status:

✅ **Code Quality:**
- Clean codebase with 0 analyzer issues
- Well-structured architecture
- Efficient state management

✅ **Dependencies:**
- Minimal, necessary dependencies
- No bloat
- Tree shaking enabled automatically

✅ **Performance:**
- Lazy initialization
- Multi-layer caching
- Efficient rendering

⚠️ **To Verify:**
- Build and measure actual APK size
- Test startup time on physical devices
- Configure ProGuard/R8 for Android

**Next Steps:**
1. Initialize Android/iOS projects if not done
2. Configure ProGuard rules
3. Build release APK/IPA
4. Measure and verify targets
5. Optimize based on results

---

**For Questions:**
- Check build output in `build/app/outputs/`
- Review ProGuard logs for shrinking reports
- Use DevTools for performance profiling
- Analyze size with `--analyze-size` flag
