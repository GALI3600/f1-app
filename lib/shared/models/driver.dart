import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'driver.freezed.dart';
part 'driver.g.dart';

/// Driver information for a specific session
///
/// Contains complete driver details including team affiliation and identification.
/// See: API_ANALYSIS.md lines 221-278, 1032-1079
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
    @JsonKey(name: 'country_code') required String countryCode,
    @JsonKey(name: 'headshot_url') String? headshotUrl,
    @JsonKey(name: 'session_key') required int sessionKey,
    @JsonKey(name: 'meeting_key') required int meetingKey,
  }) = _Driver;

  factory Driver.fromJson(Map<String, dynamic> json) =>
      _$DriverFromJson(json);
}

/// Extension providing helper methods for Driver model
extension DriverExtension on Driver {
  /// Team color as Flutter Color object
  Color get teamColor {
    final hex = teamColour.startsWith('#') ? teamColour : '#$teamColour';
    return Color(int.parse(hex.substring(1), radix: 16) + 0xFF000000);
  }

  /// Avatar URL with fallback to placeholder
  String get avatarUrl {
    return headshotUrl ?? 'https://via.placeholder.com/150?text=$nameAcronym';
  }

  /// Display name for UI (broadcast name)
  String get displayName => broadcastName;

  /// Driver initials (name acronym)
  String get initials => nameAcronym;
}
