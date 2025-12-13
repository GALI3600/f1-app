import 'package:freezed_annotation/freezed_annotation.dart';

part 'position.freezed.dart';
part 'position.g.dart';

/// Driver position changes during a session
///
/// Tracks position changes throughout the session for leaderboard and analysis.
/// See: API_ANALYSIS.md lines 619-660
@freezed
class Position with _$Position {
  const factory Position({
    DateTime? date,
    @JsonKey(name: 'driver_number') required int driverNumber,
    required int position,
    @JsonKey(name: 'session_key') required int sessionKey,
    @JsonKey(name: 'meeting_key') required int meetingKey,
  }) = _Position;

  factory Position.fromJson(Map<String, dynamic> json) =>
      _$PositionFromJson(json);
}
