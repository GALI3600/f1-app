import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:f1sync/core/constants/driver_assets.dart';

part 'driver_standing.freezed.dart';
part 'driver_standing.g.dart';

/// Driver standing in the championship
@freezed
@JsonSerializable(createFactory: false)
class DriverStanding with _$DriverStanding {
  const DriverStanding._();

  const factory DriverStanding({
    required int position,
    required double points,
    required int wins,
    required String driverId,
    required String driverCode,
    required String givenName,
    required String familyName,
    required String nationality,
    required String constructorId,
    required String constructorName,
    // Visual data from DriverAssets
    String? teamColour,
    String? headshotUrl,
  }) = _DriverStanding;

  /// Create DriverStanding from Jolpica API response
  factory DriverStanding.fromJolpica(Map<String, dynamic> json) {
    final driver = json['Driver'] as Map<String, dynamic>? ?? {};
    final constructors = json['Constructors'] as List? ?? [];
    final constructor = constructors.isNotEmpty
        ? constructors.first as Map<String, dynamic>
        : <String, dynamic>{};

    final driverId = driver['driverId'] as String? ?? '';

    return DriverStanding(
      position: int.tryParse(json['position']?.toString() ?? '') ?? 0,
      points: double.tryParse(json['points']?.toString() ?? '') ?? 0.0,
      wins: int.tryParse(json['wins']?.toString() ?? '') ?? 0,
      driverId: driverId,
      driverCode: driver['code'] as String? ?? '',
      givenName: driver['givenName'] as String? ?? '',
      familyName: driver['familyName'] as String? ?? '',
      nationality: driver['nationality'] as String? ?? '',
      constructorId: constructor['constructorId'] as String? ?? '',
      constructorName: constructor['name'] as String? ?? '',
      teamColour: DriverAssets.getTeamColour(driverId),
      headshotUrl: DriverAssets.getHeadshotUrl(driverId),
    );
  }

  /// Create from JSON — handles both Jolpica API format and flat toJson format
  factory DriverStanding.fromJson(Map<String, dynamic> json) {
    // Jolpica API format has nested 'Driver' key
    if (json.containsKey('Driver')) {
      return DriverStanding.fromJolpica(json);
    }
    // Flat format from toJson() / cache
    return DriverStanding(
      position: (json['position'] as num?)?.toInt() ?? 0,
      points: (json['points'] as num?)?.toDouble() ?? 0.0,
      wins: (json['wins'] as num?)?.toInt() ?? 0,
      driverId: json['driverId'] as String? ?? '',
      driverCode: json['driverCode'] as String? ?? '',
      givenName: json['givenName'] as String? ?? '',
      familyName: json['familyName'] as String? ?? '',
      nationality: json['nationality'] as String? ?? '',
      constructorId: json['constructorId'] as String? ?? '',
      constructorName: json['constructorName'] as String? ?? '',
      teamColour: json['teamColour'] as String?,
      headshotUrl: json['headshotUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() => _$DriverStandingToJson(this);

  /// Get full name
  String get fullName => '$givenName $familyName';

  /// Get broadcast name (e.g., "M VERSTAPPEN")
  String get broadcastName =>
      '${givenName.isNotEmpty ? givenName[0] : ''} ${familyName.toUpperCase()}';
}
