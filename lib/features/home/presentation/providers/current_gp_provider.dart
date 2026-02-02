import 'package:f1sync/core/providers.dart';
import 'package:f1sync/features/meetings/data/models/meeting.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'current_gp_provider.g.dart';

/// Provider for the current/latest Grand Prix
///
/// Fetches the latest meeting from the Jolpica API.
/// This provider uses AsyncNotifierProvider to handle loading, error, and data states.
///
/// Cache: 7 days (handled by repository layer with CacheTTL.long)
/// Auto-refresh: Can be triggered manually via refresh()
@riverpod
class CurrentGP extends _$CurrentGP {
  @override
  Future<Meeting> build() async {
    final repo = ref.watch(meetingsRepositoryProvider);

    // Use getLatestMeeting convenience method
    final meeting = await repo.getLatestMeeting();

    if (meeting == null) {
      throw Exception('No current Grand Prix found');
    }

    return meeting;
  }

  /// Refresh the current GP data
  /// Forces a cache bypass and fetches fresh data from the API
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build());
  }
}
