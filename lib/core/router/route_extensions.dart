import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Extension methods for easy navigation throughout the app
///
/// Usage:
/// ```dart
/// context.goToMeetingDetail(meetingKey);
/// context.goToDriverDetail(driverNumber);
/// context.goToSessionDetail(sessionKey);
/// ```
extension GoRouterX on BuildContext {
  // ===== Home =====

  /// Navigate to home screen
  void goToHome() => go('/');

  // ===== Meetings =====

  /// Navigate to meetings history screen
  void goToMeetings() => go('/meetings');

  /// Navigate to meeting detail screen
  ///
  /// [meetingKey] - The unique identifier for the meeting
  void goToMeetingDetail(int meetingKey) => go('/meetings/$meetingKey');

  /// Push meeting detail screen (keep previous screen in stack)
  void pushMeetingDetail(int meetingKey) => push('/meetings/$meetingKey');

  // ===== Drivers =====

  /// Navigate to drivers list screen
  void goToDrivers() => go('/drivers');

  /// Navigate to driver detail screen
  ///
  /// [driverNumber] - The driver's racing number
  void goToDriverDetail(int driverNumber) => go('/drivers/$driverNumber');

  /// Push driver detail screen (keep previous screen in stack)
  void pushDriverDetail(int driverNumber) => push('/drivers/$driverNumber');

  // ===== Sessions =====

  /// Navigate to session detail screen
  ///
  /// [sessionKey] - The unique identifier for the session
  void goToSessionDetail(int sessionKey) => go('/sessions/$sessionKey');

  /// Push session detail screen (keep previous screen in stack)
  void pushSessionDetail(int sessionKey) => push('/sessions/$sessionKey');

  /// Navigate to the latest session
  void goToLatestSession() => go('/sessions/latest');

  // ===== Navigation Helpers =====

  /// Navigate back if possible, otherwise go to home
  void goBackOrHome() {
    if (canPop()) {
      pop();
    } else {
      goToHome();
    }
  }

  /// Check if can navigate back
  bool canNavigateBack() => canPop();
}

/// Named route constants for type-safe navigation
///
/// Usage:
/// ```dart
/// context.goNamed(Routes.home);
/// context.goNamed(Routes.meetingDetail, pathParameters: {'meetingKey': '123'});
/// ```
class Routes {
  Routes._(); // Private constructor to prevent instantiation

  // Route names
  static const String home = 'home';
  static const String meetings = 'meetings';
  static const String meetingDetail = 'meeting-detail';
  static const String drivers = 'drivers';
  static const String driverDetail = 'driver-detail';
  static const String sessionDetail = 'session-detail';
  static const String sessionLatest = 'session-latest';

  // Route paths
  static const String homePath = '/';
  static const String meetingsPath = '/meetings';
  static const String meetingDetailPath = '/meetings/:meetingKey';
  static const String driversPath = '/drivers';
  static const String driverDetailPath = '/drivers/:driverNumber';
  static const String sessionDetailPath = '/sessions/:sessionKey';
  static const String sessionLatestPath = '/sessions/latest';
}

/// Helper methods for building route URIs
class RouteBuilder {
  RouteBuilder._(); // Private constructor to prevent instantiation

  /// Build URI for meeting detail
  static String meetingDetail(int meetingKey) => '/meetings/$meetingKey';

  /// Build URI for driver detail
  static String driverDetail(int driverNumber) => '/drivers/$driverNumber';

  /// Build URI for session detail
  static String sessionDetail(int sessionKey) => '/sessions/$sessionKey';

  /// Build URI for latest session
  static String latestSession() => '/sessions/latest';
}
