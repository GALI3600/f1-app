import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:f1sync/core/router/app_router.dart';
import 'package:f1sync/core/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure system UI overlay style (status bar, nav bar)
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0A1628), // F1Colors.navyDeep
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Lock orientation to portrait (optional, can be removed for tablet support)
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(
      const ProviderScope(
        child: F1SyncApp(),
      ),
    );
  });
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
    );
  }
}
