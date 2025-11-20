import 'package:f1sync/core/constants/api_constants.dart';
import 'package:f1sync/core/network/api_client.dart';
import 'package:f1sync/features/weather/data/models/weather.dart';

/// Remote data source for weather data
class WeatherRemoteDataSource {
  final OpenF1ApiClient _apiClient;

  WeatherRemoteDataSource(this._apiClient);

  /// Get weather data from API with optional filters
  Future<List<Weather>> getWeather({
    dynamic sessionKey, // Can be int or 'latest'
  }) async {
    final queryParams = <String, dynamic>{};

    if (sessionKey != null) queryParams['session_key'] = sessionKey;

    return await _apiClient.getList<Weather>(
      endpoint: ApiConstants.weather,
      fromJson: Weather.fromJson,
      queryParams: queryParams.isNotEmpty ? queryParams : null,
    );
  }

  /// Get the latest weather reading for a session
  Future<Weather?> getLatestWeather({
    dynamic sessionKey, // Can be int or 'latest'
  }) async {
    final weatherList = await getWeather(
      sessionKey: sessionKey ?? ApiConstants.latest,
    );

    // Return the most recent weather entry
    if (weatherList.isNotEmpty) {
      weatherList.sort((a, b) => b.date.compareTo(a.date));
      return weatherList.first;
    }

    return null;
  }
}
