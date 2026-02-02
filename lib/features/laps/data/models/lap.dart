import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:f1sync/core/constants/jolpica_constants.dart';

part 'lap.freezed.dart';
part 'lap.g.dart';

/// Helper to safely parse int from nullable num
int _safeInt(dynamic value, [int defaultValue = 0]) =>
    (value as num?)?.toInt() ?? defaultValue;

/// Lap model representing lap timing data
///
/// Uses Jolpica API format (Timings) for lap data.
/// Jolpica format:
/// - driverId: string (e.g., "max_verstappen")
/// - position: int
/// - time: string (e.g., "1:30.456")
/// - lapNumber: int (from parent Laps object)
@freezed
@JsonSerializable(createFactory: false)
class Lap with _$Lap {
  const Lap._();

  const factory Lap({
    @JsonKey(name: 'date_start') DateTime? dateStart,
    @JsonKey(name: 'driver_number') required int driverNumber,
    @JsonKey(name: 'lap_number') required int lapNumber,
    @JsonKey(name: 'lap_duration') @Default(0) double lapDuration,
    @JsonKey(name: 'is_pit_out_lap') @Default(false) bool isPitOutLap,
    @JsonKey(name: 'duration_sector_1') double? durationSector1,
    @JsonKey(name: 'duration_sector_2') double? durationSector2,
    @JsonKey(name: 'duration_sector_3') double? durationSector3,
    @JsonKey(name: 'segments_sector_1') @Default([]) List<int> segmentsSector1,
    @JsonKey(name: 'segments_sector_2') @Default([]) List<int> segmentsSector2,
    @JsonKey(name: 'segments_sector_3') @Default([]) List<int> segmentsSector3,
    @JsonKey(name: 'i1_speed') int? i1Speed,
    @JsonKey(name: 'i2_speed') int? i2Speed,
    @JsonKey(name: 'st_speed') int? stSpeed,
    @JsonKey(name: 'session_key') required int sessionKey,
    @JsonKey(name: 'meeting_key') required int meetingKey,
    /// Position at the end of this lap (from Jolpica)
    int? position,
    /// Driver ID string (from Jolpica, e.g., "max_verstappen")
    String? driverId,
  }) = _Lap;

  factory Lap.fromJson(Map<String, dynamic> json) {
    // Handle nullable numeric fields that the API may return as null
    return Lap(
      dateStart: json['date_start'] != null
          ? DateTime.parse(json['date_start'] as String)
          : null,
      driverNumber: _safeInt(json['driver_number']),
      lapNumber: _safeInt(json['lap_number']),
      lapDuration: (json['lap_duration'] as num?)?.toDouble() ?? 0,
      isPitOutLap: json['is_pit_out_lap'] as bool? ?? false,
      durationSector1: (json['duration_sector_1'] as num?)?.toDouble(),
      durationSector2: (json['duration_sector_2'] as num?)?.toDouble(),
      durationSector3: (json['duration_sector_3'] as num?)?.toDouble(),
      segmentsSector1: (json['segments_sector_1'] as List<dynamic>?)
              ?.whereType<num>()
              .map((e) => e.toInt())
              .toList() ??
          const [],
      segmentsSector2: (json['segments_sector_2'] as List<dynamic>?)
              ?.whereType<num>()
              .map((e) => e.toInt())
              .toList() ??
          const [],
      segmentsSector3: (json['segments_sector_3'] as List<dynamic>?)
              ?.whereType<num>()
              .map((e) => e.toInt())
              .toList() ??
          const [],
      i1Speed: (json['i1_speed'] as num?)?.toInt(),
      i2Speed: (json['i2_speed'] as num?)?.toInt(),
      stSpeed: (json['st_speed'] as num?)?.toInt(),
      sessionKey: _safeInt(json['session_key']),
      meetingKey: _safeInt(json['meeting_key']),
      position: json['position'] as int?,
      driverId: json['driverId'] as String?,
    );
  }

  /// Create Lap from Jolpica API Timing format
  ///
  /// The enrichedTiming map should contain:
  /// - driverId: string
  /// - position: int
  /// - time: string (lap time)
  /// - lapNumber: int
  /// - round: int
  /// - season: dynamic
  factory Lap.fromJolpica(Map<String, dynamic> json) {
    final driverId = json['driverId'] as String? ?? '';
    final position = int.tryParse(json['position']?.toString() ?? '') ?? 0;
    final timeStr = json['time'] as String? ?? '';
    final lapNumber = json['lapNumber'] as int? ?? 0;
    final round = json['round'] as int? ?? 0;

    // Parse lap time string (e.g., "1:30.456" or "1.456")
    final lapDuration = _parseLapTime(timeStr);

    // Get driver number from driverId using the mapping
    final driverNumber = _getDriverNumber(driverId);

    return Lap(
      driverNumber: driverNumber,
      lapNumber: lapNumber,
      lapDuration: lapDuration,
      sessionKey: round * 100, // Race session
      meetingKey: round,
      position: position,
      driverId: driverId,
    );
  }

  Map<String, dynamic> toJson() => _$LapToJson(this);
}

/// Parse lap time string to seconds
/// Handles formats like "1:30.456" or "30.456"
double _parseLapTime(String timeStr) {
  if (timeStr.isEmpty) return 0;

  try {
    if (timeStr.contains(':')) {
      final parts = timeStr.split(':');
      final minutes = int.parse(parts[0]);
      final seconds = double.parse(parts[1]);
      return minutes * 60 + seconds;
    } else {
      return double.parse(timeStr);
    }
  } catch (e) {
    return 0;
  }
}

/// Get driver number from driver ID using the reverse mapping
int _getDriverNumber(String driverId) {
  // Reverse lookup in the driverIdMap
  for (final entry in JolpicaConstants.driverIdMap.entries) {
    if (entry.value == driverId) {
      return entry.key;
    }
  }
  return 0;
}
