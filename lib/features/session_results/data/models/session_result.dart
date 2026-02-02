import 'package:freezed_annotation/freezed_annotation.dart';

part 'session_result.freezed.dart';
part 'session_result.g.dart';

/// SessionResult model representing final positions/results for a session
///
/// Uses Jolpica API format (Results) for session results data.
@freezed
class SessionResult with _$SessionResult {
  const SessionResult._();

  const factory SessionResult({
    @JsonKey(name: 'driver_number') required int driverNumber,
    @JsonKey(name: 'position') required int position,
    @JsonKey(name: 'dnf') @Default(false) bool dnf,
    @JsonKey(name: 'dns') @Default(false) bool dns,
    @JsonKey(name: 'dsq') @Default(false) bool dsq,
    @JsonKey(name: 'duration') @Default(0) double duration,
    @JsonKey(name: 'gap_to_leader') @Default(0) double gapToLeader,
    @JsonKey(name: 'number_of_laps') @Default(0) int numberOfLaps,
    @JsonKey(name: 'session_key') required int sessionKey,
    @JsonKey(name: 'meeting_key') required int meetingKey,
    /// Points scored (from Jolpica)
    @Default(0) double points,
    /// Driver ID (from Jolpica)
    String? driverId,
    /// Team/Constructor name (from Jolpica)
    String? teamName,
    /// Finish status text (from Jolpica, e.g., "Finished", "+1 Lap", "Collision")
    String? status,
    /// Grid position (from Jolpica)
    int? gridPosition,
    /// Fastest lap rank (from Jolpica, 1 = fastest)
    int? fastestLapRank,
  }) = _SessionResult;

  factory SessionResult.fromJson(Map<String, dynamic> json) =>
      _$SessionResultFromJson(json);

  /// Create SessionResult from Jolpica API Result format
  factory SessionResult.fromJolpica(Map<String, dynamic> json, int round) {
    final driver = json['Driver'] as Map<String, dynamic>? ?? {};
    final constructor = json['Constructor'] as Map<String, dynamic>? ?? {};
    final time = json['Time'] as Map<String, dynamic>?;
    final fastestLap = json['FastestLap'] as Map<String, dynamic>?;

    final driverId = driver['driverId'] as String? ?? '';
    final position = int.tryParse(json['position']?.toString() ?? '') ?? 0;
    final points = double.tryParse(json['points']?.toString() ?? '') ?? 0;
    final grid = int.tryParse(json['grid']?.toString() ?? '') ?? 0;
    final laps = int.tryParse(json['laps']?.toString() ?? '') ?? 0;
    final status = json['status'] as String? ?? '';

    // Parse time - P1 gets duration, others get gap
    double duration = 0;
    double gapToLeader = 0;
    if (time != null) {
      final timeStr = time['time'] as String? ?? '';
      if (position == 1) {
        // P1: time is the race duration
        duration = _parseRaceTime(timeStr);
      } else {
        // P2+: time is the gap (e.g., "+5.856")
        gapToLeader = _parseGapTime(timeStr);
      }
    }

    // Determine finish status
    final dnf = status != 'Finished' && !status.startsWith('+');
    final dns = status == 'Did not start' || status == 'DNS';
    final dsq = status == 'Disqualified' || status == 'DSQ';

    // Get driver number from API response (permanentNumber)
    final driverNumber = int.tryParse(driver['permanentNumber']?.toString() ?? '') ?? 0;

    // Get fastest lap rank
    int? fastestLapRank;
    if (fastestLap != null) {
      fastestLapRank = int.tryParse(fastestLap['rank']?.toString() ?? '');
    }

    return SessionResult(
      driverNumber: driverNumber,
      position: position,
      dnf: dnf,
      dns: dns,
      dsq: dsq,
      duration: duration,
      gapToLeader: gapToLeader,
      numberOfLaps: laps,
      sessionKey: round * 100, // Race session
      meetingKey: round,
      points: points,
      driverId: driverId,
      teamName: constructor['name'] as String?,
      status: status,
      gridPosition: grid,
      fastestLapRank: fastestLapRank,
    );
  }

  /// Check if driver finished the race
  bool get finished => !dnf && !dns && !dsq;

  /// Check if driver has the fastest lap
  bool get hasFastestLap => fastestLapRank == 1;
}

/// Parse race time string to seconds
/// Handles formats like "1:30:45.678" (hours:minutes:seconds) or "1:30.456" (minutes:seconds)
double _parseRaceTime(String timeStr) {
  if (timeStr.isEmpty) return 0;

  try {
    final parts = timeStr.split(':');
    if (parts.length == 3) {
      // Hours:Minutes:Seconds
      final hours = int.parse(parts[0]);
      final minutes = int.parse(parts[1]);
      final seconds = double.parse(parts[2]);
      return hours * 3600 + minutes * 60 + seconds;
    } else if (parts.length == 2) {
      // Minutes:Seconds
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

/// Parse gap time string to seconds
/// Handles formats like "+5.856" (seconds) or "+1:05.234" (minutes:seconds)
double _parseGapTime(String gapStr) {
  if (gapStr.isEmpty) return 0;

  try {
    // Remove the leading '+' if present
    String cleanStr = gapStr.startsWith('+') ? gapStr.substring(1) : gapStr;

    // Check if it contains a colon (minutes:seconds format)
    if (cleanStr.contains(':')) {
      final parts = cleanStr.split(':');
      final minutes = int.parse(parts[0]);
      final seconds = double.parse(parts[1]);
      return minutes * 60 + seconds;
    } else {
      // Just seconds
      return double.parse(cleanStr);
    }
  } catch (e) {
    // Could be "+1 Lap" or other non-numeric format
    return 0;
  }
}

