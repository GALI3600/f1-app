import 'package:freezed_annotation/freezed_annotation.dart';

part 'weather.freezed.dart';
part 'weather.g.dart';

/// Weather model representing track weather conditions
@freezed
class Weather with _$Weather {
  const factory Weather({
    @JsonKey(name: 'date') required DateTime date,
    @JsonKey(name: 'air_temperature') required double airTemperature,
    @JsonKey(name: 'humidity') required int humidity,
    @JsonKey(name: 'pressure') required double pressure,
    @JsonKey(name: 'rainfall') required int rainfall,
    @JsonKey(name: 'track_temperature') required double trackTemperature,
    @JsonKey(name: 'wind_direction') required int windDirection,
    @JsonKey(name: 'wind_speed') required double windSpeed,
    @JsonKey(name: 'session_key') required int sessionKey,
    @JsonKey(name: 'meeting_key') required int meetingKey,
  }) = _Weather;

  factory Weather.fromJson(Map<String, dynamic> json) =>
      _$WeatherFromJson(json);
}
