import 'package:f1sync/features/weather/data/models/weather.dart';

/// Repository interface for weather data
abstract class WeatherRepository {
  /// Get weather data with optional filters
  ///
  /// [sessionKey] - Filter by session key or 'latest'
  Future<List<Weather>> getWeather({
    dynamic sessionKey, // Can be int or 'latest'
  });

  /// Get the latest weather reading for a session
  Future<Weather?> getLatestWeather({
    dynamic sessionKey, // Can be int or 'latest'
  });
}
