import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/session_result.dart';
import '../../domain/repositories/session_results_repository.dart';

/// Provider for session results with sorting
final sessionResultsProvider = FutureProvider.autoDispose
    .family<List<SessionResult>, int>((ref, sessionKey) async {
  final repository = ref.watch(sessionResultsRepositoryProvider);

  final results = await repository.getSessionResults(sessionKey: sessionKey);

  // Sort by position (already sorted in repository, but ensure it)
  results.sort((a, b) => a.position.compareTo(b.position));

  return results;
});

/// Provider for session results repository
final sessionResultsRepositoryProvider = Provider<SessionResultsRepository>((ref) {
  throw UnimplementedError('SessionResultsRepository provider not implemented');
});
