import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../data/models/session.dart';
import '../../../drivers/data/models/driver.dart';
import '../../../meetings/presentation/providers/meetings_providers.dart';
import '../../../../core/providers.dart' as core_providers;

part 'session_detail_provider.freezed.dart';

/// Combined state for session detail screen
///
/// Note: Weather and RaceControl have been removed as they are not available
/// in the Jolpica API.
@freezed
class SessionDetailState with _$SessionDetailState {
  const factory SessionDetailState({
    Session? session,
    List<Driver>? drivers,
    @Default(false) bool isLoading,
    @Default(false) bool isRefreshing,
    String? error,
  }) = _SessionDetailState;
}

/// Provider for session detail data
///
/// Fetches session and driver information from Jolpica API.
/// Auto-refresh is no longer needed as Jolpica provides historical data only.
class SessionDetailNotifier extends AutoDisposeAsyncNotifier<SessionDetailState> {
  int? _currentSessionKey;

  @override
  Future<SessionDetailState> build() async {
    return const SessionDetailState();
  }

  /// Load session details by session key
  Future<void> loadSessionDetail(int sessionKey) async {
    _currentSessionKey = sessionKey;
    state = const AsyncValue.loading();

    try {
      final sessionData = await _fetchSessionData(sessionKey);
      state = AsyncValue.data(sessionData);
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

  /// Fetch session data
  Future<SessionDetailState> _fetchSessionData(int sessionKey) async {
    final sessionsRepo = ref.read(core_providers.sessionsRepositoryProvider);
    final driversRepo = ref.read(core_providers.driversRepositoryProvider);
    final selectedYear = ref.read(selectedYearProvider);

    // Fetch session and drivers in parallel
    final results = await Future.wait([
      sessionsRepo.getSessions(sessionKey: sessionKey, year: selectedYear),
      driversRepo.getDrivers(season: selectedYear),
    ]);

    final sessions = results[0] as List<Session>;
    final drivers = results[1] as List<Driver>;

    return SessionDetailState(
      session: sessions.isNotEmpty ? sessions.first : null,
      drivers: drivers,
    );
  }
}

/// Provider instances
final sessionDetailProvider =
    AutoDisposeAsyncNotifierProvider<SessionDetailNotifier, SessionDetailState>(
  SessionDetailNotifier.new,
);
