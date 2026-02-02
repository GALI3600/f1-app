import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:f1sync/features/sessions/data/models/session.dart';

part 'meeting.freezed.dart';
part 'meeting.g.dart';

/// Meeting model representing a Grand Prix weekend
///
/// Uses Jolpica API format (Race) for Grand Prix data.
@freezed
class Meeting with _$Meeting {
  const Meeting._();

  const factory Meeting({
    /// Round number in the season (used as meeting key for Jolpica)
    @JsonKey(name: 'meeting_key') required int meetingKey,
    /// Short name of the Grand Prix (e.g., "Monaco Grand Prix")
    @JsonKey(name: 'meeting_name') required String meetingName,
    /// Official full name
    @JsonKey(name: 'meeting_official_name') required String meetingOfficialName,
    /// City/Location name
    @JsonKey(name: 'location') required String location,
    /// ISO country code (e.g., "MC" for Monaco)
    @JsonKey(name: 'country_code') required String countryCode,
    /// Full country name
    @JsonKey(name: 'country_name') required String countryName,
    /// Country key (for backwards compatibility, defaults to 0)
    @JsonKey(name: 'country_key') @Default(0) int countryKey,
    /// Short circuit name (e.g., "Monaco")
    @JsonKey(name: 'circuit_short_name') required String circuitShortName,
    /// Circuit ID (for backwards compatibility, defaults to 0)
    @JsonKey(name: 'circuit_key') @Default(0) int circuitKey,
    /// Race date/time
    @JsonKey(name: 'date_start') required DateTime dateStart,
    /// GMT offset string (e.g., "+02:00")
    @JsonKey(name: 'gmt_offset') @Default('+00:00') String gmtOffset,
    /// Season year
    @JsonKey(name: 'year') required int year,
    /// Circuit ID from Jolpica
    String? circuitId,
    /// Sessions for this meeting (from Jolpica schedule data)
    @Default([]) List<Session> sessions,
  }) = _Meeting;

  factory Meeting.fromJson(Map<String, dynamic> json) =>
      _$MeetingFromJson(json);

  /// Create Meeting from Jolpica API Race format
  factory Meeting.fromJolpica(Map<String, dynamic> json) {
    final circuit = json['Circuit'] as Map<String, dynamic>? ?? {};
    final location = circuit['Location'] as Map<String, dynamic>? ?? {};

    final year = int.tryParse(json['season']?.toString() ?? '') ?? DateTime.now().year;
    final round = int.tryParse(json['round']?.toString() ?? '') ?? 0;

    // Parse race date
    final dateStr = json['date'] as String? ?? '';
    final timeStr = json['time'] as String? ?? '14:00:00Z';
    DateTime dateStart;
    try {
      dateStart = DateTime.parse('${dateStr}T$timeStr');
    } catch (e) {
      dateStart = DateTime.now();
    }

    // Build sessions list from schedule data
    final sessions = <Session>[];
    int sessionIndex = 1;

    // First Practice
    if (json['FirstPractice'] != null) {
      sessions.add(_parseSession(
        json['FirstPractice'] as Map<String, dynamic>,
        'Practice 1',
        'Practice',
        round,
        sessionIndex++,
        circuit,
        location,
        year,
      ));
    }

    // Second Practice
    if (json['SecondPractice'] != null) {
      sessions.add(_parseSession(
        json['SecondPractice'] as Map<String, dynamic>,
        'Practice 2',
        'Practice',
        round,
        sessionIndex++,
        circuit,
        location,
        year,
      ));
    }

    // Third Practice (not in sprint weekends)
    if (json['ThirdPractice'] != null) {
      sessions.add(_parseSession(
        json['ThirdPractice'] as Map<String, dynamic>,
        'Practice 3',
        'Practice',
        round,
        sessionIndex++,
        circuit,
        location,
        year,
      ));
    }

    // Sprint Qualifying (sprint weekends)
    if (json['SprintQualifying'] != null) {
      sessions.add(_parseSession(
        json['SprintQualifying'] as Map<String, dynamic>,
        'Sprint Qualifying',
        'Sprint Qualifying',
        round,
        sessionIndex++,
        circuit,
        location,
        year,
      ));
    }

    // Sprint (sprint weekends)
    if (json['Sprint'] != null) {
      sessions.add(_parseSession(
        json['Sprint'] as Map<String, dynamic>,
        'Sprint',
        'Sprint',
        round,
        sessionIndex++,
        circuit,
        location,
        year,
      ));
    }

    // Qualifying
    if (json['Qualifying'] != null) {
      sessions.add(_parseSession(
        json['Qualifying'] as Map<String, dynamic>,
        'Qualifying',
        'Qualifying',
        round,
        sessionIndex++,
        circuit,
        location,
        year,
      ));
    }

    // Race
    sessions.add(Session(
      sessionKey: round * 100 + sessionIndex,
      meetingKey: round,
      sessionName: 'Race',
      sessionType: 'Race',
      dateStart: dateStart,
      dateEnd: dateStart.add(const Duration(hours: 2)),
      gmtOffset: '+00:00',
      location: location['locality'] as String? ?? '',
      countryCode: location['country'] as String? ?? '',
      countryName: location['country'] as String? ?? '',
      circuitShortName: circuit['circuitName'] as String? ?? '',
      circuitKey: 0,
      year: year,
    ));

    return Meeting(
      meetingKey: round,
      meetingName: json['raceName'] as String? ?? 'Unknown Grand Prix',
      meetingOfficialName: json['raceName'] as String? ?? 'Unknown Grand Prix',
      location: location['locality'] as String? ?? '',
      countryCode: _getCountryCode(location['country'] as String? ?? ''),
      countryName: location['country'] as String? ?? '',
      countryKey: 0,
      circuitShortName: circuit['circuitName'] as String? ?? '',
      circuitKey: 0,
      dateStart: dateStart,
      gmtOffset: '+00:00',
      year: year,
      circuitId: circuit['circuitId'] as String?,
      sessions: sessions,
    );
  }

  /// Get the round number (alias for meetingKey in Jolpica context)
  int get round => meetingKey;

  /// Check if this is a sprint weekend
  bool get isSprintWeekend => sessions.any((s) => s.sessionType == 'Sprint');
}

/// Helper to parse a session from Jolpica schedule data
Session _parseSession(
  Map<String, dynamic> sessionData,
  String sessionName,
  String sessionType,
  int round,
  int sessionIndex,
  Map<String, dynamic> circuit,
  Map<String, dynamic> location,
  int year,
) {
  final dateStr = sessionData['date'] as String? ?? '';
  final timeStr = sessionData['time'] as String? ?? '12:00:00Z';
  DateTime dateStart;
  try {
    dateStart = DateTime.parse('${dateStr}T$timeStr');
  } catch (e) {
    dateStart = DateTime.now();
  }

  // Session duration estimate
  Duration duration;
  switch (sessionType) {
    case 'Practice':
      duration = const Duration(hours: 1);
      break;
    case 'Qualifying':
    case 'Sprint Qualifying':
      duration = const Duration(hours: 1);
      break;
    case 'Sprint':
      duration = const Duration(minutes: 30);
      break;
    default:
      duration = const Duration(hours: 1);
  }

  return Session(
    sessionKey: round * 100 + sessionIndex,
    meetingKey: round,
    sessionName: sessionName,
    sessionType: sessionType,
    dateStart: dateStart,
    dateEnd: dateStart.add(duration),
    gmtOffset: '+00:00',
    location: location['locality'] as String? ?? '',
    countryCode: location['country'] as String? ?? '',
    countryName: location['country'] as String? ?? '',
    circuitShortName: circuit['circuitName'] as String? ?? '',
    circuitKey: 0,
    year: year,
  );
}

/// Get ISO country code from country name
String _getCountryCode(String countryName) {
  const countryMap = {
    'UK': 'GB',
    'United Kingdom': 'GB',
    'USA': 'US',
    'United States': 'US',
    'UAE': 'AE',
    'United Arab Emirates': 'AE',
    'Monaco': 'MC',
    'Italy': 'IT',
    'Spain': 'ES',
    'Canada': 'CA',
    'Austria': 'AT',
    'France': 'FR',
    'Hungary': 'HU',
    'Belgium': 'BE',
    'Netherlands': 'NL',
    'Singapore': 'SG',
    'Japan': 'JP',
    'Qatar': 'QA',
    'Mexico': 'MX',
    'Brazil': 'BR',
    'Australia': 'AU',
    'Saudi Arabia': 'SA',
    'Bahrain': 'BH',
    'Azerbaijan': 'AZ',
    'China': 'CN',
  };
  return countryMap[countryName] ?? countryName.substring(0, 2).toUpperCase();
}
