import 'package:freezed_annotation/freezed_annotation.dart';

part 'driver_race_result.freezed.dart';
part 'driver_race_result.g.dart';

/// DriverRaceResult model representing a driver's result in a specific race
///
/// Used for displaying the driver's race history
@freezed
class DriverRaceResult with _$DriverRaceResult {
  const DriverRaceResult._();

  const factory DriverRaceResult({
    /// Season year
    required int season,
    /// Round number in the season
    required int round,
    /// Race name (e.g., "Monaco Grand Prix")
    required String raceName,
    /// Race date
    required DateTime date,
    /// Circuit name
    required String circuitName,
    /// Country where the race took place
    required String country,
    /// Finishing position
    required int position,
    /// Grid/Starting position
    required int gridPosition,
    /// Points scored
    required double points,
    /// Number of laps completed
    required int laps,
    /// Finish status (e.g., "Finished", "Collision", "+1 Lap")
    required String status,
    /// Team/Constructor name
    required String teamName,
    /// Race time (if finished)
    String? time,
    /// Whether driver had fastest lap
    @Default(false) bool hasFastestLap,
    /// Whether this is a sprint result
    @Default(false) bool isSprint,
  }) = _DriverRaceResult;

  factory DriverRaceResult.fromJson(Map<String, dynamic> json) =>
      _$DriverRaceResultFromJson(json);

  /// Create DriverRaceResult from Jolpica API enriched result format
  factory DriverRaceResult.fromJolpica(Map<String, dynamic> json) {
    final circuit = json['Circuit'] as Map<String, dynamic>? ?? {};
    final location = circuit['Location'] as Map<String, dynamic>? ?? {};
    final constructor = json['Constructor'] as Map<String, dynamic>? ?? {};
    final time = json['Time'] as Map<String, dynamic>?;
    final fastestLap = json['FastestLap'] as Map<String, dynamic>?;

    final season = int.tryParse(json['season']?.toString() ?? '') ?? 0;
    final round = int.tryParse(json['round']?.toString() ?? '') ?? 0;
    final position = int.tryParse(json['position']?.toString() ?? '') ?? 0;
    final grid = int.tryParse(json['grid']?.toString() ?? '') ?? 0;
    final points = double.tryParse(json['points']?.toString() ?? '') ?? 0;
    final laps = int.tryParse(json['laps']?.toString() ?? '') ?? 0;

    // Parse date
    DateTime date;
    try {
      date = DateTime.parse(json['date'] as String? ?? '');
    } catch (_) {
      date = DateTime.now();
    }

    // Check for fastest lap
    bool hasFastestLap = false;
    if (fastestLap != null) {
      final rank = int.tryParse(fastestLap['rank']?.toString() ?? '');
      hasFastestLap = rank == 1;
    }

    return DriverRaceResult(
      season: season,
      round: round,
      raceName: json['raceName'] as String? ?? 'Unknown Race',
      date: date,
      circuitName: circuit['circuitName'] as String? ?? '',
      country: location['country'] as String? ?? '',
      position: position,
      gridPosition: grid,
      points: points,
      laps: laps,
      status: json['status'] as String? ?? '',
      teamName: constructor['name'] as String? ?? '',
      time: time?['time'] as String?,
      hasFastestLap: hasFastestLap,
    );
  }

  /// Create DriverRaceResult from Jolpica API sprint result format
  factory DriverRaceResult.fromJolpicaSprint(Map<String, dynamic> json) {
    final circuit = json['Circuit'] as Map<String, dynamic>? ?? {};
    final location = circuit['Location'] as Map<String, dynamic>? ?? {};
    final constructor = json['Constructor'] as Map<String, dynamic>? ?? {};
    final time = json['Time'] as Map<String, dynamic>?;

    final season = int.tryParse(json['season']?.toString() ?? '') ?? 0;
    final round = int.tryParse(json['round']?.toString() ?? '') ?? 0;
    final position = int.tryParse(json['position']?.toString() ?? '') ?? 0;
    final grid = int.tryParse(json['grid']?.toString() ?? '') ?? 0;
    final points = double.tryParse(json['points']?.toString() ?? '') ?? 0;
    final laps = int.tryParse(json['laps']?.toString() ?? '') ?? 0;

    DateTime date;
    try {
      date = DateTime.parse(json['date'] as String? ?? '');
    } catch (_) {
      date = DateTime.now();
    }

    return DriverRaceResult(
      season: season,
      round: round,
      raceName: json['raceName'] as String? ?? 'Unknown Sprint',
      date: date,
      circuitName: circuit['circuitName'] as String? ?? '',
      country: location['country'] as String? ?? '',
      position: position,
      gridPosition: grid,
      points: points,
      laps: laps,
      status: json['status'] as String? ?? '',
      teamName: constructor['name'] as String? ?? '',
      time: time?['time'] as String?,
      isSprint: true,
    );
  }

  /// Check if driver finished the race normally
  bool get finished => status == 'Finished' || status.startsWith('+');

  /// Check if driver DNF'd
  bool get dnf => !finished && status != 'Did not start' && status != 'DNS';

  /// Check if it's a podium finish
  bool get isPodium => position >= 1 && position <= 3;

  /// Check if it's a points finish
  bool get isPointsFinish => points > 0;

  /// Check if driver won the race
  bool get isWin => position == 1;

  /// Position change from grid to finish (positive = gained positions)
  int get positionChange => gridPosition - position;
}
