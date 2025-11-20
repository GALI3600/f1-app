import 'package:f1sync/features/laps/data/models/lap.dart';

/// Repository interface for laps
abstract class LapsRepository {
  /// Get list of laps with optional filters
  ///
  /// [sessionKey] - Filter by session key or 'latest'
  /// [driverNumber] - Filter by driver number
  /// [lapNumber] - Filter by lap number
  Future<List<Lap>> getLaps({
    dynamic sessionKey, // Can be int or 'latest'
    int? driverNumber,
    int? lapNumber,
  });

  /// Get laps for a specific driver in a session
  Future<List<Lap>> getDriverLaps({
    required int driverNumber,
    dynamic sessionKey, // Can be int or 'latest'
  });
}
