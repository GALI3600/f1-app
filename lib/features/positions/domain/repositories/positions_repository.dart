import 'package:f1sync/features/positions/data/models/position.dart';

/// Repository interface for positions
abstract class PositionsRepository {
  /// Get list of positions with optional filters
  ///
  /// [sessionKey] - Filter by session key or 'latest'
  /// [driverNumber] - Filter by driver number
  /// [position] - Filter by position (e.g., top 3)
  Future<List<Position>> getPositions({
    dynamic sessionKey, // Can be int or 'latest'
    int? driverNumber,
    int? position,
  });

  /// Get current positions for a session
  Future<List<Position>> getCurrentPositions({
    dynamic sessionKey, // Can be int or 'latest'
  });
}
