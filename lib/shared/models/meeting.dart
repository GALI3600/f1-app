import 'package:freezed_annotation/freezed_annotation.dart';

part 'meeting.freezed.dart';
part 'meeting.g.dart';

/// Meeting (Grand Prix weekend or testing event)
///
/// Represents a complete F1 event weekend including all sessions.
/// See: API_ANALYSIS.md lines 468-524
@freezed
class Meeting with _$Meeting {
  const factory Meeting({
    @JsonKey(name: 'meeting_key') required int meetingKey,
    @JsonKey(name: 'meeting_name') required String meetingName,
    @JsonKey(name: 'meeting_official_name') required String meetingOfficialName,
    required String location,
    @JsonKey(name: 'country_code') required String countryCode,
    @JsonKey(name: 'country_name') required String countryName,
    @JsonKey(name: 'country_key') required int countryKey,
    @JsonKey(name: 'circuit_short_name') required String circuitShortName,
    @JsonKey(name: 'circuit_key') required int circuitKey,
    @JsonKey(name: 'date_start') required DateTime dateStart,
    @JsonKey(name: 'gmt_offset') required String gmtOffset,
    required int year,
  }) = _Meeting;

  factory Meeting.fromJson(Map<String, dynamic> json) =>
      _$MeetingFromJson(json);
}
