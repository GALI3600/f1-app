import 'package:freezed_annotation/freezed_annotation.dart';

part 'lap.freezed.dart';
part 'lap.g.dart';

/// Lap model representing lap timing data
@freezed
class Lap with _$Lap {
  const factory Lap({
    @JsonKey(name: 'date_start') required DateTime dateStart,
    @JsonKey(name: 'driver_number') required int driverNumber,
    @JsonKey(name: 'lap_number') required int lapNumber,
    @JsonKey(name: 'lap_duration') required double lapDuration,
    @JsonKey(name: 'is_pit_out_lap') required bool isPitOutLap,
    @JsonKey(name: 'duration_sector_1') required double durationSector1,
    @JsonKey(name: 'duration_sector_2') required double durationSector2,
    @JsonKey(name: 'duration_sector_3') required double durationSector3,
    @JsonKey(name: 'segments_sector_1') required List<int> segmentsSector1,
    @JsonKey(name: 'segments_sector_2') required List<int> segmentsSector2,
    @JsonKey(name: 'segments_sector_3') required List<int> segmentsSector3,
    @JsonKey(name: 'i1_speed') int? i1Speed,
    @JsonKey(name: 'i2_speed') int? i2Speed,
    @JsonKey(name: 'st_speed') int? stSpeed,
    @JsonKey(name: 'session_key') required int sessionKey,
    @JsonKey(name: 'meeting_key') required int meetingKey,
  }) = _Lap;

  factory Lap.fromJson(Map<String, dynamic> json) => _$LapFromJson(json);
}
