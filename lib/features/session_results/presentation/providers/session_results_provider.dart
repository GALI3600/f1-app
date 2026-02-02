import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/session_result.dart';
import '../../../../core/providers.dart' as core_providers;
import '../../../meetings/presentation/providers/meetings_providers.dart';

/// Parameters for session results query
typedef SessionResultsParams = ({int sessionKey, String sessionType});

/// Provider for session results with sorting
///
/// Fetches appropriate results based on session type:
/// - Practice: No results (returns empty)
/// - Qualifying: Grid positions
/// - Sprint: Sprint race results
/// - Race: Full race results
final sessionResultsProvider = FutureProvider.autoDispose
    .family<List<SessionResult>, SessionResultsParams>((ref, params) async {
  final repository = ref.watch(core_providers.sessionResultsRepositoryProvider);
  final selectedYear = ref.watch(selectedYearProvider);

  final results = await repository.getSessionResults(
    sessionKey: params.sessionKey,
    sessionType: params.sessionType,
    year: selectedYear,
  );

  // Sort by position
  results.sort((a, b) => a.position.compareTo(b.position));

  return results;
});
