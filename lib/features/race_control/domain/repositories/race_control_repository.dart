import 'package:f1sync/features/race_control/data/models/race_control.dart';

/// Repository interface for race control messages
abstract class RaceControlRepository {
  /// Get race control messages with optional filters
  ///
  /// [sessionKey] - Filter by session key or 'latest'
  /// [category] - Filter by category (Flag, SafetyCar, etc.)
  /// [flag] - Filter by flag type (YELLOW, RED, etc.)
  Future<List<RaceControl>> getRaceControlMessages({
    dynamic sessionKey, // Can be int or 'latest'
    String? category,
    String? flag,
  });
}
