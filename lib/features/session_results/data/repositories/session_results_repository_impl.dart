import '../../domain/repositories/session_results_repository.dart';
import '../datasources/session_results_remote_data_source.dart';
import '../models/session_result.dart';

/// Implementation of SessionResultsRepository
class SessionResultsRepositoryImpl implements SessionResultsRepository {
  final SessionResultsRemoteDataSource _remoteDataSource;

  SessionResultsRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<SessionResult>> getSessionResults({
    required int sessionKey,
    String? sessionType,
    int? driverNumber,
    int? position,
    int? year,
  }) async {
    try {
      final results = await _remoteDataSource.getSessionResults(
        sessionKey: sessionKey,
        sessionType: sessionType,
        driverNumber: driverNumber,
        position: position,
        year: year,
      );

      // Sort by position
      results.sort((a, b) => a.position.compareTo(b.position));

      return results;
    } catch (e) {
      throw Exception('Failed to get session results: $e');
    }
  }
}
