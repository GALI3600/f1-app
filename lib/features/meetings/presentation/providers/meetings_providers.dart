import 'package:f1sync/core/providers.dart';
import 'package:f1sync/features/meetings/data/models/meeting.dart';
import 'package:f1sync/features/sessions/data/models/session.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'meetings_providers.g.dart';

// ========== State Providers ==========

/// Selected year provider for meetings history filtering
/// Default: current year
/// Available years: 2023, 2024, 2025
@riverpod
class SelectedYear extends _$SelectedYear {
  @override
  int build() {
    final currentYear = DateTime.now().year;
    // Ensure year is within valid range (2023-2025)
    if (currentYear < 2023) return 2023;
    if (currentYear > 2025) return 2025;
    return currentYear;
  }

  /// Update selected year
  void setYear(int year) {
    if (year >= 2023 && year <= 2025) {
      state = year;
    }
  }
}

// ========== Data Providers ==========

/// Meetings list provider (family by year)
/// Returns list of meetings for a given year, sorted by date descending
/// Cache: 7 days (historical data doesn't change)
@riverpod
Future<List<Meeting>> meetingsList(
  MeetingsListRef ref,
  int year,
) async {
  final repository = ref.watch(meetingsRepositoryProvider);

  final meetings = await repository.getMeetings(year: year);

  // Sort by date descending (newest first)
  meetings.sort((a, b) => b.dateStart.compareTo(a.dateStart));

  return meetings;
}

/// Meeting detail provider (family by meeting key)
/// Returns tuple of (Meeting, List<Session>)
/// Uses the meeting's embedded sessions (parsed from Jolpica API)
@riverpod
Future<MeetingDetail> meetingDetail(
  MeetingDetailRef ref,
  int meetingKey,
) async {
  final meetingsRepo = ref.watch(meetingsRepositoryProvider);
  final selectedYear = ref.watch(selectedYearProvider);

  // Fetch meeting with its embedded sessions
  final meeting = await meetingsRepo.getMeetingByKey(meetingKey, year: selectedYear);

  if (meeting == null) {
    throw Exception('Meeting not found: Round $meetingKey, Year $selectedYear');
  }

  // Use embedded sessions (already parsed with correct dates)
  // Filter out practice sessions (no results available in Jolpica)
  // Sort by date (chronological order)
  final sessions = meeting.sessions
      .where((s) => s.sessionType.toLowerCase() != 'practice')
      .toList()
    ..sort((a, b) => a.dateStart.compareTo(b.dateStart));

  return MeetingDetail(meeting: meeting, sessions: sessions);
}

/// Meeting detail data class
/// Combines meeting info with associated sessions
class MeetingDetail {
  final Meeting meeting;
  final List<Session> sessions;

  const MeetingDetail({
    required this.meeting,
    required this.sessions,
  });
}
