import 'package:f1sync/features/stints/data/models/stint.dart';

/// Repository interface for tire stints
abstract class StintsRepository {
  /// Get stints with optional filters
  ///
  /// [sessionKey] - Filter by session key or 'latest'
  /// [driverNumber] - Filter by driver number
  Future<List<Stint>> getStints({
    dynamic sessionKey, // Can be int or 'latest'
    int? driverNumber,
  });

  /// Get stints for a specific driver in a session
  Future<List<Stint>> getDriverStints({
    required int driverNumber,
    dynamic sessionKey, // Can be int or 'latest'
  });
}
