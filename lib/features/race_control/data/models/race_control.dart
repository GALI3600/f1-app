import 'package:freezed_annotation/freezed_annotation.dart';

part 'race_control.freezed.dart';
part 'race_control.g.dart';

/// RaceControl model representing race control messages
@freezed
class RaceControl with _$RaceControl {
  const factory RaceControl({
    @JsonKey(name: 'date') required DateTime date,
    @JsonKey(name: 'category') required String category,
    @JsonKey(name: 'flag') String? flag,
    @JsonKey(name: 'lap_number') int? lapNumber,
    @JsonKey(name: 'message') required String message,
    @JsonKey(name: 'scope') String? scope,
    @JsonKey(name: 'sector') int? sector,
    @JsonKey(name: 'driver_number') int? driverNumber,
    @JsonKey(name: 'session_key') required int sessionKey,
    @JsonKey(name: 'meeting_key') required int meetingKey,
  }) = _RaceControl;

  factory RaceControl.fromJson(Map<String, dynamic> json) =>
      _$RaceControlFromJson(json);
}
