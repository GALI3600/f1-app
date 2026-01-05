import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'stint.freezed.dart';
part 'stint.g.dart';

/// Stint model representing tire stint data
@freezed
@JsonSerializable(createFactory: false)
class Stint with _$Stint {
  const Stint._();

  const factory Stint({
    @JsonKey(name: 'compound') @Default('UNKNOWN') String compound,
    @JsonKey(name: 'driver_number') required int driverNumber,
    @JsonKey(name: 'lap_end') int? lapEnd,
    @JsonKey(name: 'lap_start') @Default(1) int lapStart,
    @JsonKey(name: 'stint_number') @Default(1) int stintNumber,
    @JsonKey(name: 'tyre_age_at_start') @Default(0) int tyreAgeAtStart,
    @JsonKey(name: 'session_key') required int sessionKey,
    @JsonKey(name: 'meeting_key') required int meetingKey,
  }) = _Stint;

  factory Stint.fromJson(Map<String, dynamic> json) {
    return Stint(
      compound: json['compound'] as String? ?? 'UNKNOWN',
      driverNumber: (json['driver_number'] as num?)?.toInt() ?? 0,
      lapEnd: (json['lap_end'] as num?)?.toInt(),
      lapStart: (json['lap_start'] as num?)?.toInt() ?? 1,
      stintNumber: (json['stint_number'] as num?)?.toInt() ?? 1,
      tyreAgeAtStart: (json['tyre_age_at_start'] as num?)?.toInt() ?? 0,
      sessionKey: (json['session_key'] as num?)?.toInt() ?? 0,
      meetingKey: (json['meeting_key'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => _$StintToJson(this);
}
