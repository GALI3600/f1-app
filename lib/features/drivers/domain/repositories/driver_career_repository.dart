import '../../data/models/driver_career.dart';

/// Repository interface for driver career statistics
abstract class DriverCareerRepository {
  /// Get career statistics for a driver by their Jolpica driver ID
  Future<DriverCareer?> getDriverCareer(String driverId);

  /// Get career statistics for a driver by their driver number
  Future<DriverCareer?> getDriverCareerByNumber(int driverNumber);
}
