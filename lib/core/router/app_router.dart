import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:f1sync/features/home/presentation/screens/home_screen.dart';
import 'package:f1sync/features/meetings/presentation/screens/meetings_history_screen.dart';
import 'package:f1sync/features/meetings/presentation/screens/meeting_detail_screen.dart';
import 'package:f1sync/features/drivers/presentation/screens/drivers_list_screen.dart';
import 'package:f1sync/features/drivers/presentation/screens/driver_detail_screen.dart';
import 'package:f1sync/features/sessions/presentation/screens/session_detail_screen.dart';
import 'package:f1sync/shared/widgets/error_widget.dart' as custom;

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,

    // Error handler for invalid routes
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(
        title: const Text('Error'),
        backgroundColor: Colors.transparent,
      ),
      body: custom.ErrorWidget(
        message: 'Page not found: ${state.uri.path}',
        onRetry: () => context.go('/'),
      ),
    ),

    routes: [
      // Home route
      GoRoute(
        path: '/',
        name: 'home',
        pageBuilder: (context, state) => _buildPageWithFadeTransition(
          context: context,
          state: state,
          child: const HomeScreen(),
        ),
      ),

      // Meetings routes
      GoRoute(
        path: '/meetings',
        name: 'meetings',
        pageBuilder: (context, state) => _buildPageWithFadeTransition(
          context: context,
          state: state,
          child: const MeetingsHistoryScreen(),
        ),
      ),
      GoRoute(
        path: '/meetings/:meetingKey',
        name: 'meeting-detail',
        pageBuilder: (context, state) {
          final meetingKey = int.tryParse(state.pathParameters['meetingKey'] ?? '');
          if (meetingKey == null) {
            return _buildPageWithFadeTransition(
              context: context,
              state: state,
              child: Scaffold(
                body: custom.ErrorWidget(
                  message: 'Invalid meeting key',
                  onRetry: () => context.go('/meetings'),
                ),
              ),
            );
          }
          return _buildPageWithSlideTransition(
            context: context,
            state: state,
            child: MeetingDetailScreen(meetingKey: meetingKey),
          );
        },
      ),

      // Drivers routes
      GoRoute(
        path: '/drivers',
        name: 'drivers',
        pageBuilder: (context, state) => _buildPageWithFadeTransition(
          context: context,
          state: state,
          child: const DriversListScreen(),
        ),
      ),
      GoRoute(
        path: '/drivers/:driverNumber',
        name: 'driver-detail',
        pageBuilder: (context, state) {
          final driverNumber = int.tryParse(state.pathParameters['driverNumber'] ?? '');
          if (driverNumber == null) {
            return _buildPageWithFadeTransition(
              context: context,
              state: state,
              child: Scaffold(
                body: custom.ErrorWidget(
                  message: 'Invalid driver number',
                  onRetry: () => context.go('/drivers'),
                ),
              ),
            );
          }
          return _buildPageWithSlideTransition(
            context: context,
            state: state,
            child: DriverDetailScreen(driverNumber: driverNumber),
          );
        },
      ),

      // Session routes
      GoRoute(
        path: '/sessions/:sessionKey',
        name: 'session-detail',
        pageBuilder: (context, state) {
          final sessionKey = int.tryParse(state.pathParameters['sessionKey'] ?? '');
          if (sessionKey == null) {
            return _buildPageWithFadeTransition(
              context: context,
              state: state,
              child: Scaffold(
                body: custom.ErrorWidget(
                  message: 'Invalid session key',
                  onRetry: () => context.go('/'),
                ),
              ),
            );
          }
          return _buildPageWithSlideTransition(
            context: context,
            state: state,
            child: SessionDetailScreen(sessionKey: sessionKey),
          );
        },
      ),

      // Latest session route (redirects to actual session)
      GoRoute(
        path: '/sessions/latest',
        name: 'session-latest',
        redirect: (context, state) {
          // This would typically fetch the latest session key from an API
          // For now, we'll redirect to home
          // In a real implementation, you'd fetch the latest session key here
          return '/';
        },
      ),
    ],
  );
});

/// Creates a page with fade transition animation
Page<dynamic> _buildPageWithFadeTransition({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: child,
      );
    },
  );
}

/// Creates a page with slide (bottom-to-top) transition animation
/// Used for detail screens
Page<dynamic> _buildPageWithSlideTransition({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(0.0, 0.1);
      const end = Offset.zero;
      const curve = Curves.easeInOut;

      final tween = Tween(begin: begin, end: end).chain(
        CurveTween(curve: curve),
      );

      return SlideTransition(
        position: animation.drive(tween),
        child: FadeTransition(
          opacity: animation,
          child: child,
        ),
      );
    },
  );
}
