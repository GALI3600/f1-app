import 'package:freezed_annotation/freezed_annotation.dart';

part 'position.freezed.dart';
part 'position.g.dart';

/// Position model representing driver position during session
@freezed
class Position with _$Position {
  const factory Position({
    @JsonKey(name: 'date') required DateTime date,
    @JsonKey(name: 'driver_number') required int driverNumber,
    @JsonKey(name: 'position') required int position,
    @JsonKey(name: 'session_key') required int sessionKey,
    @JsonKey(name: 'meeting_key') required int meetingKey,
  }) = _Position;

  factory Position.fromJson(Map<String, dynamic> json) =>
      _$PositionFromJson(json);
}
