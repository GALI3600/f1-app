# Build Instructions for F1Sync

## Prerequisites

- Flutter SDK installed
- Git bash or WSL2 for running commands on Windows

## Step 1: Get Dependencies

```bash
flutter pub get
```

This will download all required packages specified in `pubspec.yaml`.

## Step 2: Generate Code

Run build_runner to generate all Freezed and JSON serialization code:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

This command will generate:
- `.freezed.dart` files for all data models (immutable classes)
- `.g.dart` files for JSON serialization (fromJson/toJson)
- `.g.dart` files for Riverpod providers

### Expected Output

You should see messages like:
```
[INFO] Generating build script...
[INFO] Generating build script completed, took 2.1s

[INFO] Creating build script snapshot...
[INFO] Creating build script snapshot completed, took 8.3s

[INFO] Building new asset graph...
[INFO] Building new asset graph completed, took 1.2s

[INFO] Checking for unexpected pre-existing outputs...
[INFO] Checking for unexpected pre-existing outputs completed, took 0.1s

[INFO] Running build...
[INFO] Running build completed, took 45.2s

[INFO] Caching finalized dependency graph...
[INFO] Caching finalized dependency graph completed, took 0.3s

[SUCCESS] Build completed successfully!
```

## Step 3: Verify Build

Check for any errors:

```bash
flutter analyze
```

All errors should be resolved after code generation.

## Step 4: Run the App

```bash
flutter run
```

Or for a specific device:

```bash
flutter run -d chrome  # For web
flutter run -d windows # For Windows
flutter run -d android # For Android
```

## Troubleshooting

### Issue: "Conflicting outputs were detected..."

**Solution:** Use the `--delete-conflicting-outputs` flag:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Issue: Build runner fails with errors

**Solution 1:** Clean the build cache and retry:
```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

**Solution 2:** Delete generated files manually:
```bash
# On Windows (PowerShell)
Get-ChildItem -Recurse -Filter "*.g.dart" | Remove-Item
Get-ChildItem -Recurse -Filter "*.freezed.dart" | Remove-Item

# On Linux/Mac
find . -name "*.g.dart" -delete
find . -name "*.freezed.dart" -delete

# Then run build_runner again
flutter pub run build_runner build --delete-conflicting-outputs
```

### Issue: Import errors after build

**Solution:** Run `flutter pub get` again:
```bash
flutter pub get
```

Then restart your IDE/editor.

## Development Workflow

### Watch Mode (Recommended for Development)

Instead of manually running build_runner every time you change a model, use watch mode:

```bash
flutter pub run build_runner watch --delete-conflicting-outputs
```

This will automatically regenerate files whenever you save changes.

### One-time Build

For production builds or when you just need to generate files once:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## Generated Files Location

After running build_runner, you'll find generated files next to their source files:

```
lib/features/meetings/data/models/
├── meeting.dart          # Your source file
├── meeting.freezed.dart  # Generated Freezed code
└── meeting.g.dart        # Generated JSON serialization

lib/core/
├── providers.dart        # Your source file
└── providers.g.dart      # Generated Riverpod providers
```

## Next Steps

Once build_runner completes successfully:

1. ✅ All models will have `fromJson` and `toJson` methods
2. ✅ All models will have `copyWith`, `==`, and `toString` methods
3. ✅ All providers will be available for dependency injection
4. ✅ The app will compile without errors

You can then:
- Start implementing UI components (Phase 5)
- Write unit tests for repositories
- Create use cases for business logic
- Build screens that consume the repositories

## Useful Commands

```bash
# Get dependencies
flutter pub get

# Generate code
flutter pub run build_runner build --delete-conflicting-outputs

# Watch for changes
flutter pub run build_runner watch

# Analyze code
flutter analyze

# Format code
flutter format .

# Run tests
flutter test

# Clean build
flutter clean

# Run app
flutter run
```

## IDE Setup

### VS Code

Install these extensions:
- Flutter
- Dart
- Freezed

### Android Studio / IntelliJ

Install these plugins:
- Flutter
- Dart
- Freezed

Both IDEs will automatically detect changes and offer code actions for Freezed models.

---

**Note:** Build runner only needs to be run when you:
1. Add new models
2. Modify existing models
3. Add new providers
4. Clone the repository for the first time

It does NOT need to be run for UI changes or business logic changes.
