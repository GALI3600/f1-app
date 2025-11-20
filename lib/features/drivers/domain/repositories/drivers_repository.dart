import 'package:f1sync/features/drivers/data/models/driver.dart';

/// Repository interface for drivers
abstract class DriversRepository {
  /// Get list of drivers with optional filters
  ///
  /// [sessionKey] - Filter by session key or 'latest'
  /// [driverNumber] - Filter by specific driver number
  Future<List<Driver>> getDrivers({
    dynamic sessionKey, // Can be int or 'latest'
    int? driverNumber,
  });

  /// Get a single driver by number
  Future<Driver?> getDriverByNumber({
    required int driverNumber,
    dynamic sessionKey, // Can be int or 'latest'
  });
}
