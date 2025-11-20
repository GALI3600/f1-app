import 'package:freezed_annotation/freezed_annotation.dart';

part 'session.freezed.dart';
part 'session.g.dart';

/// Session (Practice, Qualifying, Sprint, Race)
///
/// Represents an individual F1 session within a meeting/weekend.
/// See: API_ANALYSIS.md lines 718-776
@freezed
class Session with _$Session {
  const factory Session({
    @JsonKey(name: 'session_key') required int sessionKey,
    @JsonKey(name: 'meeting_key') required int meetingKey,
    @JsonKey(name: 'session_name') required String sessionName,
    @JsonKey(name: 'session_type') required String sessionType,
    @JsonKey(name: 'date_start') required DateTime dateStart,
    @JsonKey(name: 'date_end') required DateTime dateEnd,
    @JsonKey(name: 'gmt_offset') required String gmtOffset,
    required String location,
    @JsonKey(name: 'country_code') required String countryCode,
    @JsonKey(name: 'country_name') required String countryName,
    @JsonKey(name: 'circuit_short_name') required String circuitShortName,
    @JsonKey(name: 'circuit_key') required int circuitKey,
    required int year,
  }) = _Session;

  factory Session.fromJson(Map<String, dynamic> json) =>
      _$SessionFromJson(json);
}
