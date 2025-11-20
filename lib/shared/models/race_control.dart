import 'package:freezed_annotation/freezed_annotation.dart';

part 'race_control.freezed.dart';
part 'race_control.g.dart';

/// Race control messages (flags, safety car, incidents)
///
/// Messages from race direction including flags, safety car, and incident reports.
/// See: API_ANALYSIS.md lines 664-715
@freezed
class RaceControl with _$RaceControl {
  const factory RaceControl({
    required DateTime date,
    required String category,
    String? flag,
    @JsonKey(name: 'lap_number') int? lapNumber,
    required String message,
    String? scope,
    int? sector,
    @JsonKey(name: 'driver_number') int? driverNumber,
    @JsonKey(name: 'session_key') required int sessionKey,
    @JsonKey(name: 'meeting_key') required int meetingKey,
  }) = _RaceControl;

  factory RaceControl.fromJson(Map<String, dynamic> json) =>
      _$RaceControlFromJson(json);
}
