import 'package:freezed_annotation/freezed_annotation.dart';

part 'driver_career.freezed.dart';

/// Driver career statistics from Jolpica API
@freezed
class DriverCareer with _$DriverCareer {
  const factory DriverCareer({
    required String driverId,
    required String fullName,
    required String nationality,
    String? dateOfBirth,
    String? permanentNumber,
    @Default(0) int totalRaces,
    @Default(0) int wins,
    @Default(0) int podiums,
    @Default(0) int poles,
    @Default(0) int fastestLaps,
    @Default(0) int championships,
    @Default(0) int seasons,
    @Default(0.0) double careerPoints,
    int? currentSeasonPosition,
    double? currentSeasonPoints,
    List<int>? championshipYears,
    String? firstRace,
    String? lastRace,
  }) = _DriverCareer;

  factory DriverCareer.fromJolpicaJson({
    required Map<String, dynamic> driverInfo,
    int wins = 0,
    int podiums = 0,
    int poles = 0,
    int totalRaces = 0,
    int seasons = 0,
    List<int>? championshipYears,
    int? currentPosition,
    double? currentPoints,
  }) {
    final driver = driverInfo['Driver'] ?? driverInfo;

    return DriverCareer(
      driverId: driver['driverId'] as String? ?? '',
      fullName: '${driver['givenName'] ?? ''} ${driver['familyName'] ?? ''}'.trim(),
      nationality: driver['nationality'] as String? ?? '',
      dateOfBirth: driver['dateOfBirth'] as String?,
      permanentNumber: driver['permanentNumber'] as String?,
      totalRaces: totalRaces,
      wins: wins,
      podiums: podiums,
      poles: poles,
      fastestLaps: 0,
      championships: championshipYears?.length ?? 0,
      seasons: seasons,
      careerPoints: 0,
      currentSeasonPosition: currentPosition,
      currentSeasonPoints: currentPoints,
      championshipYears: championshipYears,
    );
  }

  factory DriverCareer.empty(String driverId) => DriverCareer(
        driverId: driverId,
        fullName: '',
        nationality: '',
      );
}

/// Championship standing entry
@freezed
class ChampionshipStanding with _$ChampionshipStanding {
  const factory ChampionshipStanding({
    required int season,
    required int position,
    required double points,
    required int wins,
    String? constructorName,
  }) = _ChampionshipStanding;

  factory ChampionshipStanding.fromJson(Map<String, dynamic> json) {
    final driverStanding = json['DriverStandings']?[0] ?? json;
    final constructor = driverStanding['Constructors']?[0];

    return ChampionshipStanding(
      season: int.tryParse(json['season']?.toString() ?? '0') ?? 0,
      position: int.tryParse(driverStanding['position']?.toString() ?? '0') ?? 0,
      points: double.tryParse(driverStanding['points']?.toString() ?? '0') ?? 0,
      wins: int.tryParse(driverStanding['wins']?.toString() ?? '0') ?? 0,
      constructorName: constructor?['name'] as String?,
    );
  }
}
