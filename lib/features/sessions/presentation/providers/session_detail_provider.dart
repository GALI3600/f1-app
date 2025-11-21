import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../data/models/session.dart';
import '../../../drivers/data/models/driver.dart';
import '../../../weather/data/models/weather.dart';
import '../../../race_control/data/models/race_control.dart';
import '../../domain/repositories/sessions_repository.dart';
import '../../../drivers/domain/repositories/drivers_repository.dart';
import '../../../weather/domain/repositories/weather_repository.dart';
import '../../../race_control/domain/repositories/race_control_repository.dart';

part 'session_detail_provider.freezed.dart';

/// Combined state for session detail screen
@freezed
class SessionDetailState with _$SessionDetailState {
  const factory SessionDetailState({
    Session? session,
    List<Driver>? drivers,
    List<Weather>? weather,
    List<RaceControl>? raceControl,
    @Default(false) bool isLoading,
    @Default(false) bool isRefreshing,
    String? error,
  }) = _SessionDetailState;
}

/// Provider for session detail data with auto-refresh
class SessionDetailNotifier extends AutoDisposeAsyncNotifier<SessionDetailState> {
  Timer? _refreshTimer;
  int? _currentSessionKey;

  @override
  Future<SessionDetailState> build() async {
    // Cancel timer on dispose
    ref.onDispose(() {
      _refreshTimer?.cancel();
    });

    return const SessionDetailState();
  }

  /// Load session details by session key
  Future<void> loadSessionDetail(int sessionKey) async {
    _currentSessionKey = sessionKey;
    state = const AsyncValue.loading();

    try {
      final sessionData = await _fetchSessionData(sessionKey);
      state = AsyncValue.data(sessionData);

      // Start auto-refresh if session is live
      if (_isSessionLive(sessionData.session)) {
        _startAutoRefresh(sessionKey);
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Manually refresh data
  Future<void> refresh() async {
    if (_currentSessionKey == null) return;

    final currentState = state.valueOrNull;
    if (currentState == null) return;

    state = AsyncValue.data(currentState.copyWith(isRefreshing: true));

    try {
      final sessionData = await _fetchSessionData(_currentSessionKey!);
      state = AsyncValue.data(sessionData);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Fetch all session data in parallel
  Future<SessionDetailState> _fetchSessionData(int sessionKey) async {
    final sessionsRepo = ref.read(sessionsRepositoryProvider);
    final driversRepo = ref.read(driversRepositoryProvider);
    final weatherRepo = ref.read(weatherRepositoryProvider);
    final raceControlRepo = ref.read(raceControlRepositoryProvider);

    // Fetch all data in parallel
    final results = await Future.wait([
      sessionsRepo.getSessions(sessionKey: sessionKey),
      driversRepo.getDrivers(sessionKey: sessionKey),
      weatherRepo.getWeather(sessionKey: sessionKey),
      raceControlRepo.getRaceControlMessages(sessionKey: sessionKey),
    ]);

    final sessions = results[0] as List<Session>;
    final drivers = results[1] as List<Driver>;
    final weather = results[2] as List<Weather>;
    final raceControl = results[3] as List<RaceControl>;

    return SessionDetailState(
      session: sessions.isNotEmpty ? sessions.first : null,
      drivers: drivers,
      weather: weather,
      raceControl: raceControl,
    );
  }

  /// Check if session is currently live
  bool _isSessionLive(Session? session) {
    if (session == null) return false;

    final now = DateTime.now();
    return now.isAfter(session.dateStart) && now.isBefore(session.dateEnd);
  }

  /// Start auto-refresh timer (every 10 seconds for live sessions)
  void _startAutoRefresh(int sessionKey) {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 10),
      (timer) async {
        final currentSession = state.valueOrNull?.session;

        // Stop refresh if session ended
        if (!_isSessionLive(currentSession)) {
          timer.cancel();
          return;
        }

        await refresh();
      },
    );
  }
}

/// Provider instances
final sessionDetailProvider =
    AutoDisposeAsyncNotifierProvider<SessionDetailNotifier, SessionDetailState>(
  SessionDetailNotifier.new,
);

// Repository providers (these should be defined in their respective features)
final sessionsRepositoryProvider = Provider<SessionsRepository>((ref) {
  throw UnimplementedError('SessionsRepository provider not implemented');
});

final driversRepositoryProvider = Provider<DriversRepository>((ref) {
  throw UnimplementedError('DriversRepository provider not implemented');
});

final weatherRepositoryProvider = Provider<WeatherRepository>((ref) {
  throw UnimplementedError('WeatherRepository provider not implemented');
});

final raceControlRepositoryProvider = Provider<RaceControlRepository>((ref) {
  throw UnimplementedError('RaceControlRepository provider not implemented');
});
