import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:f1sync/core/constants/driver_assets.dart';

part 'driver.freezed.dart';
part 'driver.g.dart';

/// Driver model representing an F1 driver
@freezed
@JsonSerializable(createFactory: false)
class Driver with _$Driver {
  const Driver._();
  const factory Driver({
    @JsonKey(name: 'driver_number') required int driverNumber,
    @JsonKey(name: 'broadcast_name') required String broadcastName,
    @JsonKey(name: 'full_name') required String fullName,
    @JsonKey(name: 'name_acronym') required String nameAcronym,
    @JsonKey(name: 'first_name') required String firstName,
    @JsonKey(name: 'last_name') required String lastName,
    @JsonKey(name: 'team_name') required String teamName,
    @JsonKey(name: 'team_colour') required String teamColour,
    @JsonKey(name: 'team_colour_2') String? teamColour2, // Secondary color for gradient
    @JsonKey(name: 'country_code') String? countryCode,
    @JsonKey(name: 'headshot_url') String? headshotUrl,
    // Session/Meeting keys (optional - not available from Jolpica)
    @JsonKey(name: 'session_key') @Default(0) int sessionKey,
    @JsonKey(name: 'meeting_key') @Default(0) int meetingKey,
    // Jolpica-specific fields
    @JsonKey(name: 'driver_id') String? driverId,
    String? nationality,
    @JsonKey(name: 'date_of_birth') String? dateOfBirth,
    @JsonKey(name: 'wikipedia_url') String? wikipediaUrl,
  }) = _Driver;

  /// Create Driver from JSON response
  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      driverNumber: (json['driver_number'] as num?)?.toInt() ?? 0,
      broadcastName: json['broadcast_name'] as String? ?? '',
      fullName: json['full_name'] as String? ?? '',
      nameAcronym: json['name_acronym'] as String? ?? '',
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      teamName: json['team_name'] as String? ?? '',
      teamColour: json['team_colour'] as String? ?? '000000',
      teamColour2: json['team_colour_2'] as String?,
      countryCode: json['country_code'] as String?,
      headshotUrl: json['headshot_url'] as String?,
      sessionKey: (json['session_key'] as num?)?.toInt() ?? 0,
      meetingKey: (json['meeting_key'] as num?)?.toInt() ?? 0,
      driverId: json['driver_id'] as String?,
      nationality: json['nationality'] as String?,
      dateOfBirth: json['date_of_birth'] as String?,
      wikipediaUrl: json['wikipedia_url'] as String?,
    );
  }

  /// Create Driver from Jolpica API response
  ///
  /// Uses DriverAssets for team name, team color, and headshot URL
  factory Driver.fromJolpica(Map<String, dynamic> json) {
    final driverId = json['driverId'] as String? ?? '';
    final permanentNumber = json['permanentNumber'] as String?;
    var driverNumber = permanentNumber != null
        ? int.tryParse(permanentNumber) ?? 0
        : 0;

    // Manual overrides for numbers not yet updated in API
    driverNumber = _getDriverNumberOverride(driverId) ?? driverNumber;

    final givenName = json['givenName'] as String? ?? '';
    final familyName = json['familyName'] as String? ?? '';
    final code = json['code'] as String? ?? '';
    final nationality = json['nationality'] as String?;
    final dateOfBirth = json['dateOfBirth'] as String?;
    final wikipediaUrl = json['url'] as String?;

    // Get team info from local assets
    final teamName = DriverAssets.getTeamName(driverId);
    final teamColour = DriverAssets.getTeamColour(driverId);
    final teamColour2 = DriverAssets.getTeamColour2(driverId);
    final headshotUrl = DriverAssets.getHeadshotUrl(driverId) ??
        DriverAssets.fallbackHeadshotUrl;

    return Driver(
      driverNumber: driverNumber,
      broadcastName: '${givenName.isNotEmpty ? givenName[0] : ''} ${familyName.toUpperCase()}',
      fullName: '$givenName ${familyName.toUpperCase()}',
      nameAcronym: code,
      firstName: givenName,
      lastName: familyName,
      teamName: teamName,
      teamColour: teamColour,
      teamColour2: teamColour2,
      countryCode: _nationalityToCode(nationality),
      headshotUrl: headshotUrl,
      sessionKey: 0, // Not available from Jolpica
      meetingKey: 0, // Not available from Jolpica
      driverId: driverId,
      nationality: nationality,
      dateOfBirth: dateOfBirth,
      wikipediaUrl: wikipediaUrl,
    );
  }

  /// Create an empty/placeholder Driver when data is not available
  ///
  /// Uses DriverAssets to populate team info if available
  factory Driver.empty(String driverId) {
    final teamName = DriverAssets.getTeamName(driverId);
    final teamColour = DriverAssets.getTeamColour(driverId);
    final teamColour2 = DriverAssets.getTeamColour2(driverId);
    final headshotUrl = DriverAssets.getHeadshotUrl(driverId) ??
        DriverAssets.fallbackHeadshotUrl;

    // Use override if available
    final driverNumber = _getDriverNumberOverride(driverId) ?? 0;

    // Try to format the driverId as a name (e.g., "max_verstappen" -> "Max Verstappen")
    final nameParts = driverId.split('_');
    final firstName = nameParts.isNotEmpty
        ? nameParts.first[0].toUpperCase() + nameParts.first.substring(1)
        : '';
    final lastName = nameParts.length > 1
        ? nameParts.last.toUpperCase()
        : driverId.toUpperCase();

    return Driver(
      driverNumber: driverNumber,
      broadcastName: '${firstName.isNotEmpty ? firstName[0] : ''} $lastName',
      fullName: '$firstName $lastName',
      nameAcronym: lastName.length >= 3 ? lastName.substring(0, 3) : lastName,
      firstName: firstName,
      lastName: lastName.toLowerCase(),
      teamName: teamName,
      teamColour: teamColour,
      teamColour2: teamColour2,
      countryCode: null,
      headshotUrl: headshotUrl,
      sessionKey: 0,
      meetingKey: 0,
      driverId: driverId,
      nationality: null,
      dateOfBirth: null,
      wikipediaUrl: null,
    );
  }

  Map<String, dynamic> toJson() => _$DriverToJson(this);
}

/// Manual driver number overrides for 2026 season
/// Used when API data is outdated or missing
int? _getDriverNumberOverride(String driverId) {
  const overrides = {
    'norris': 1,    // Champion number for 2026
    'lindblad': 41, // New number not yet in API
  };
  return overrides[driverId];
}

/// Convert nationality string to country code
String? _nationalityToCode(String? nationality) {
  if (nationality == null) return null;

  const nationalityMap = {
    'Dutch': 'NED',
    'British': 'GBR',
    'Spanish': 'ESP',
    'Monegasque': 'MON',
    'German': 'GER',
    'Australian': 'AUS',
    'French': 'FRA',
    'Mexican': 'MEX',
    'Canadian': 'CAN',
    'Finnish': 'FIN',
    'Thai': 'THA',
    'Japanese': 'JPN',
    'Chinese': 'CHN',
    'Italian': 'ITA',
    'Danish': 'DEN',
    'American': 'USA',
    'Brazilian': 'BRA',
    'Argentine': 'ARG',
    'New Zealander': 'NZL',
  };

  return nationalityMap[nationality];
}
