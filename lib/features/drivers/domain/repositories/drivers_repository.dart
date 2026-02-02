import 'package:f1sync/features/drivers/data/models/driver.dart';

/// Repository interface for drivers
///
/// Uses Jolpica API for driver data. Drivers are fetched by season.
abstract class DriversRepository {
  /// Get list of drivers with optional filters
  ///
  /// [season] - Season year or 'current' (defaults to current)
  /// [driverNumber] - Filter by specific driver number
  Future<List<Driver>> getDrivers({
    dynamic season,
    int? driverNumber,
  });

  /// Get a single driver by number
  Future<Driver?> getDriverByNumber({
    required int driverNumber,
    dynamic season,
  });

  /// Get a single driver by ID (e.g., "max_verstappen")
  Future<Driver?> getDriverById({
    required String driverId,
    dynamic season,
  });
}
