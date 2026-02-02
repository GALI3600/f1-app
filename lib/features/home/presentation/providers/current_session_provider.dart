import 'package:f1sync/core/providers.dart';
import 'package:f1sync/features/sessions/data/models/session.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'current_session_provider.g.dart';

/// Provider for the current/latest Session
///
/// Fetches the latest session from the Jolpica API.
/// Returns null if there is no active session.
///
/// Cache: 1 hour (handled by repository layer with CacheTTL.medium)
/// Auto-refresh: Can be triggered manually via refresh()
@riverpod
class CurrentSession extends _$CurrentSession {
  @override
  Future<Session?> build() async {
    final repo = ref.watch(sessionsRepositoryProvider);

    // Use getLatestSession convenience method
    final session = await repo.getLatestSession();

    // Can return null if no active session
    return session;
  }

  /// Refresh the current session data
  /// Forces a cache bypass and fetches fresh data from the API
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build());
  }
}
