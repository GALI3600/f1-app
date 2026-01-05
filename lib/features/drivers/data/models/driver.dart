import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:json_annotation/json_annotation.dart';

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
    @JsonKey(name: 'country_code') String? countryCode,
    @JsonKey(name: 'headshot_url') String? headshotUrl,
    @JsonKey(name: 'session_key') required int sessionKey,
    @JsonKey(name: 'meeting_key') required int meetingKey,
  }) = _Driver;

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
      countryCode: json['country_code'] as String?,
      headshotUrl: json['headshot_url'] as String?,
      sessionKey: (json['session_key'] as num?)?.toInt() ?? 0,
      meetingKey: (json['meeting_key'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => _$DriverToJson(this);
}
