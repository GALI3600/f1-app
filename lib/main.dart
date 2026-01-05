import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:f1sync/core/router/app_router.dart';
import 'package:f1sync/core/theme/app_theme.dart';
import 'package:f1sync/core/error/global_error_handler.dart';
import 'package:f1sync/shared/services/cache/cache_service.dart';
import 'package:f1sync/shared/services/providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize global error handler
  GlobalErrorHandler.initialize();

  // Initialize cache service before app starts
  final cacheService = CacheService();
  await cacheService.init();

  // Configure system UI overlay style (status bar, nav bar)
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0A1628), // F1Colors.navyDeep
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Allow all orientations for landscape support
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  runApp(
    ProviderScope(
      overrides: [
        // Use the pre-initialized cache service
        cacheServiceProvider.overrideWithValue(cacheService),
      ],
      child: const F1SyncApp(),
    ),
  );
}

class F1SyncApp extends ConsumerWidget {
  const F1SyncApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'F1Sync',
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark, // Always use dark theme for Phase 1
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      // Global scaffold messenger key for error notifications
      scaffoldMessengerKey: GlobalErrorHandler.scaffoldMessengerKey,
    );
  }
}
