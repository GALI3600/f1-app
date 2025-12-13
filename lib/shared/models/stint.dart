import 'package:freezed_annotation/freezed_annotation.dart';

part 'stint.freezed.dart';
part 'stint.g.dart';

/// Tire stint information
///
/// Represents a period during which a driver uses a specific set of tires.
/// See: API_ANALYSIS.md lines 878-926
@freezed
class Stint with _$Stint {
  const factory Stint({
    @Default('UNKNOWN') String compound,
    @JsonKey(name: 'driver_number') required int driverNumber,
    @JsonKey(name: 'lap_end') int? lapEnd,
    @JsonKey(name: 'lap_start') @Default(1) int lapStart,
    @JsonKey(name: 'stint_number') @Default(1) int stintNumber,
    @JsonKey(name: 'tyre_age_at_start') @Default(0) int tyreAgeAtStart,
    @JsonKey(name: 'session_key') required int sessionKey,
    @JsonKey(name: 'meeting_key') required int meetingKey,
  }) = _Stint;

  factory Stint.fromJson(Map<String, dynamic> json) => _$StintFromJson(json);
}
