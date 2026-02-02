import 'package:f1sync/features/laps/data/models/lap.dart';

/// Repository interface for laps
///
/// Laps are fetched from Jolpica API which provides historical lap data
/// for completed races. For Jolpica, sessionKey is computed as round * 100.
abstract class LapsRepository {
  /// Get list of laps with optional filters
  ///
  /// [round] - Race round number
  /// [sessionKey] - Session key (round * 100 for race) - for backwards compatibility
  /// [driverNumber] - Filter by driver number
  /// [lapNumber] - Filter by lap number
  /// [year] - Season year (defaults to current year)
  Future<List<Lap>> getLaps({
    int? round,
    dynamic sessionKey,
    int? driverNumber,
    int? lapNumber,
    int? year,
  });

  /// Get laps for a specific driver in a race
  Future<List<Lap>> getDriverLaps({
    required int driverNumber,
    required int round,
    int? year,
  });
}
