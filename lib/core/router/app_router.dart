import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:f1sync/features/home/presentation/screens/home_screen.dart';
import 'package:f1sync/features/meetings/presentation/screens/meetings_history_screen.dart';
import 'package:f1sync/features/meetings/presentation/screens/meeting_detail_screen.dart';
import 'package:f1sync/features/drivers/presentation/screens/drivers_list_screen.dart';
import 'package:f1sync/features/drivers/presentation/screens/driver_detail_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),

      // Meetings routes
      GoRoute(
        path: '/meetings',
        name: 'meetings',
        builder: (context, state) => const MeetingsHistoryScreen(),
      ),
      GoRoute(
        path: '/meetings/:meetingKey',
        name: 'meeting-detail',
        builder: (context, state) {
          final meetingKey = int.parse(state.pathParameters['meetingKey']!);
          return MeetingDetailScreen(meetingKey: meetingKey);
        },
      ),

      // Drivers routes
      GoRoute(
        path: '/drivers',
        name: 'drivers',
        builder: (context, state) => const DriversListScreen(),
      ),
      GoRoute(
        path: '/drivers/:driverNumber',
        name: 'driver-detail',
        builder: (context, state) {
          final driverNumber = int.parse(state.pathParameters['driverNumber']!);
          return DriverDetailScreen(driverNumber: driverNumber);
        },
      ),
    ],
  );
});
