import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'position.freezed.dart';
part 'position.g.dart';

/// Position model representing driver position during session
@freezed
@JsonSerializable(createFactory: false)
class Position with _$Position {
  const Position._();

  const factory Position({
    @JsonKey(name: 'date') DateTime? date,
    @JsonKey(name: 'driver_number') required int driverNumber,
    @JsonKey(name: 'position') @Default(0) int position,
    @JsonKey(name: 'session_key') required int sessionKey,
    @JsonKey(name: 'meeting_key') required int meetingKey,
  }) = _Position;

  factory Position.fromJson(Map<String, dynamic> json) {
    return Position(
      date: json['date'] != null ? DateTime.parse(json['date'] as String) : null,
      driverNumber: (json['driver_number'] as num?)?.toInt() ?? 0,
      position: (json['position'] as num?)?.toInt() ?? 0,
      sessionKey: (json['session_key'] as num?)?.toInt() ?? 0,
      meetingKey: (json['meeting_key'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => _$PositionToJson(this);
}
