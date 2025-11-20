import 'package:freezed_annotation/freezed_annotation.dart';

part 'session_result.freezed.dart';
part 'session_result.g.dart';

/// SessionResult model representing final positions/results for a session
@freezed
class SessionResult with _$SessionResult {
  const factory SessionResult({
    @JsonKey(name: 'driver_number') required int driverNumber,
    @JsonKey(name: 'position') required int position,
    @JsonKey(name: 'dnf') required bool dnf,
    @JsonKey(name: 'dns') required bool dns,
    @JsonKey(name: 'dsq') required bool dsq,
    @JsonKey(name: 'duration') required double duration,
    @JsonKey(name: 'gap_to_leader') required double gapToLeader,
    @JsonKey(name: 'number_of_laps') required int numberOfLaps,
    @JsonKey(name: 'session_key') required int sessionKey,
    @JsonKey(name: 'meeting_key') required int meetingKey,
  }) = _SessionResult;

  factory SessionResult.fromJson(Map<String, dynamic> json) =>
      _$SessionResultFromJson(json);
}
