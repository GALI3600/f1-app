import 'package:freezed_annotation/freezed_annotation.dart';

part 'session.freezed.dart';
part 'session.g.dart';

/// Session model representing an F1 session (FP, Qualifying, Race, etc.)
///
/// In Jolpica API, sessions are embedded within Race objects.
/// The sessionKey is computed as: round * 100 + sessionIndex
@freezed
class Session with _$Session {
  const Session._();

  const factory Session({
    /// Unique session identifier (round * 100 + sessionIndex for Jolpica)
    @JsonKey(name: 'session_key') required int sessionKey,
    /// Meeting/round number this session belongs to
    @JsonKey(name: 'meeting_key') required int meetingKey,
    /// Display name (e.g., "Practice 1", "Qualifying", "Race")
    @JsonKey(name: 'session_name') required String sessionName,
    /// Type of session (Practice, Qualifying, Sprint, Race, Sprint Qualifying)
    @JsonKey(name: 'session_type') required String sessionType,
    /// Session start time
    @JsonKey(name: 'date_start') required DateTime dateStart,
    /// Session end time (estimated)
    @JsonKey(name: 'date_end') required DateTime dateEnd,
    /// GMT offset string
    @JsonKey(name: 'gmt_offset') required String gmtOffset,
    /// City/Location name
    @JsonKey(name: 'location') required String location,
    /// Country code
    @JsonKey(name: 'country_code') required String countryCode,
    /// Country name
    @JsonKey(name: 'country_name') required String countryName,
    /// Circuit name
    @JsonKey(name: 'circuit_short_name') required String circuitShortName,
    /// Circuit key (for backwards compatibility)
    @JsonKey(name: 'circuit_key') required int circuitKey,
    /// Season year
    @JsonKey(name: 'year') required int year,
  }) = _Session;

  factory Session.fromJson(Map<String, dynamic> json) =>
      _$SessionFromJson(json);

  /// Get the round number from the session key
  int get round => meetingKey;

  /// Check if this is a race session
  bool get isRace => sessionType == 'Race';

  /// Check if this is a qualifying session
  bool get isQualifying => sessionType == 'Qualifying' || sessionType == 'Sprint Qualifying';

  /// Check if this is a practice session
  bool get isPractice => sessionType == 'Practice';

  /// Check if this is a sprint session
  bool get isSprint => sessionType == 'Sprint';
}
