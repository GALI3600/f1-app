import 'package:freezed_annotation/freezed_annotation.dart';

part 'weather.freezed.dart';
part 'weather.g.dart';

/// Weather conditions at the track
///
/// Meteorological data updated approximately every minute during sessions.
/// See: API_ANALYSIS.md lines 973-1025
@freezed
class Weather with _$Weather {
  const factory Weather({
    required DateTime date,
    @JsonKey(name: 'air_temperature') required double airTemperature,
    required int humidity,
    required double pressure,
    required int rainfall,
    @JsonKey(name: 'track_temperature') required double trackTemperature,
    @JsonKey(name: 'wind_direction') required int windDirection,
    @JsonKey(name: 'wind_speed') required double windSpeed,
    @JsonKey(name: 'session_key') required int sessionKey,
    @JsonKey(name: 'meeting_key') required int meetingKey,
  }) = _Weather;

  factory Weather.fromJson(Map<String, dynamic> json) =>
      _$WeatherFromJson(json);
}
