import 'package:freezed_annotation/freezed_annotation.dart';

part 'driver.freezed.dart';
part 'driver.g.dart';

/// Driver model representing an F1 driver
@freezed
class Driver with _$Driver {
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

  factory Driver.fromJson(Map<String, dynamic> json) =>
      _$DriverFromJson(json);
}
