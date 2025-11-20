import 'package:intl/intl.dart';

/// Utility class for date/time formatting and manipulation
///
/// Provides consistent date/time formatting throughout the app,
/// with special handling for F1-specific requirements.
///
/// Features:
/// - ISO 8601 parsing (OpenF1 API format)
/// - Multiple display formats (full, short, time-only)
/// - Relative time formatting (e.g., "2 hours ago")
/// - Timezone handling
/// - Session time formatting
/// - Duration formatting
///
/// Usage:
/// ```dart
/// // Parse ISO 8601
/// final date = DateTimeUtil.parseIso8601('2023-09-15T13:08:19.923000+00:00');
///
/// // Format for display
/// final formatted = DateTimeUtil.formatFull(date); // "September 15, 2023 at 1:08 PM"
/// final time = DateTimeUtil.formatTime(date); // "1:08 PM"
///
/// // Relative time
/// final relative = DateTimeUtil.formatRelative(date); // "2 hours ago"
///
/// // Duration
/// final duration = DateTimeUtil.formatDuration(Duration(minutes: 92, seconds: 34)); // "1:32:34"
/// ```
class DateTimeUtil {
  DateTimeUtil._();

  // ========== Date Formatters ==========

  /// Full date and time format: "September 15, 2023 at 1:08 PM"
  static final DateFormat _fullFormat = DateFormat('MMMM d, y \'at\' h:mm a');

  /// Medium date format: "Sep 15, 2023"
  static final DateFormat _mediumDateFormat = DateFormat('MMM d, y');

  /// Short date format: "09/15/23"
  static final DateFormat _shortDateFormat = DateFormat('MM/dd/yy');

  /// Time only format: "1:08 PM"
  static final DateFormat _timeFormat = DateFormat('h:mm a');

  /// Time with seconds: "1:08:19 PM"
  static final DateFormat _timeWithSecondsFormat = DateFormat('h:mm:ss a');

  /// 24-hour time format: "13:08"
  static final DateFormat _time24Format = DateFormat('HH:mm');

  /// 24-hour time with seconds: "13:08:19"
  static final DateFormat _time24WithSecondsFormat = DateFormat('HH:mm:ss');

  /// Day and month: "Sep 15"
  static final DateFormat _dayMonthFormat = DateFormat('MMM d');

  /// Year only: "2023"
  static final DateFormat _yearFormat = DateFormat('y');

  // ========== Parsing ==========

  /// Parse ISO 8601 date string (OpenF1 API format)
  ///
  /// Handles formats like:
  /// - 2023-09-15T13:08:19.923000+00:00
  /// - 2023-09-15T13:08:19Z
  /// - 2023-09-15T13:08:19
  static DateTime? parseIso8601(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;

    try {
      return DateTime.parse(dateString).toLocal();
    } catch (e) {
      return null;
    }
  }

  /// Parse ISO 8601 and keep as UTC
  static DateTime? parseIso8601Utc(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;

    try {
      return DateTime.parse(dateString).toUtc();
    } catch (e) {
      return null;
    }
  }

  // ========== Formatting ==========

  /// Format as full date and time: "September 15, 2023 at 1:08 PM"
  static String formatFull(DateTime dateTime) {
    return _fullFormat.format(dateTime);
  }

  /// Format as medium date: "Sep 15, 2023"
  static String formatMediumDate(DateTime dateTime) {
    return _mediumDateFormat.format(dateTime);
  }

  /// Format as short date: "09/15/23"
  static String formatShortDate(DateTime dateTime) {
    return _shortDateFormat.format(dateTime);
  }

  /// Format as time only: "1:08 PM"
  static String formatTime(DateTime dateTime) {
    return _timeFormat.format(dateTime);
  }

  /// Format as time with seconds: "1:08:19 PM"
  static String formatTimeWithSeconds(DateTime dateTime) {
    return _timeWithSecondsFormat.format(dateTime);
  }

  /// Format as 24-hour time: "13:08"
  static String formatTime24(DateTime dateTime) {
    return _time24Format.format(dateTime);
  }

  /// Format as 24-hour time with seconds: "13:08:19"
  static String formatTime24WithSeconds(DateTime dateTime) {
    return _time24WithSecondsFormat.format(dateTime);
  }

  /// Format as day and month: "Sep 15"
  static String formatDayMonth(DateTime dateTime) {
    return _dayMonthFormat.format(dateTime);
  }

  /// Format as year only: "2023"
  static String formatYear(DateTime dateTime) {
    return _yearFormat.format(dateTime);
  }

  // ========== Relative Time ==========

  /// Format as relative time: "2 hours ago", "in 3 days"
  static String formatRelative(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.isNegative) {
      // Future
      final absDifference = difference.abs();
      return 'in ${_formatDifference(absDifference)}';
    } else {
      // Past
      return '${_formatDifference(difference)} ago';
    }
  }

  /// Format difference as human-readable string
  static String _formatDifference(Duration difference) {
    if (difference.inSeconds < 60) {
      return '${difference.inSeconds}s';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()}w';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()}mo';
    } else {
      return '${(difference.inDays / 365).floor()}y';
    }
  }

  // ========== Duration Formatting ==========

  /// Format duration as lap time: "1:32.456"
  ///
  /// Used for lap times and sector times.
  static String formatLapTime(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    final milliseconds = duration.inMilliseconds.remainder(1000);

    if (minutes > 0) {
      return '$minutes:${seconds.toString().padLeft(2, '0')}.${milliseconds.toString().padLeft(3, '0')}';
    } else {
      return '$seconds.${milliseconds.toString().padLeft(3, '0')}s';
    }
  }

  /// Format duration as session time: "1:32:45"
  ///
  /// Used for race duration and session lengths.
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '$minutes:${seconds.toString().padLeft(2, '0')}';
    }
  }

  /// Format duration as short text: "1h 32m"
  static String formatDurationShort(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m';
    } else {
      return '${duration.inSeconds}s';
    }
  }

  /// Format milliseconds as lap time
  static String formatMilliseconds(int milliseconds) {
    return formatLapTime(Duration(milliseconds: milliseconds));
  }

  // ========== Comparison ==========

  /// Check if date is today
  static bool isToday(DateTime dateTime) {
    final now = DateTime.now();
    return dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day;
  }

  /// Check if date is yesterday
  static bool isYesterday(DateTime dateTime) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return dateTime.year == yesterday.year &&
        dateTime.month == yesterday.month &&
        dateTime.day == yesterday.day;
  }

  /// Check if date is this year
  static bool isThisYear(DateTime dateTime) {
    return dateTime.year == DateTime.now().year;
  }

  /// Check if date is in the past
  static bool isPast(DateTime dateTime) {
    return dateTime.isBefore(DateTime.now());
  }

  /// Check if date is in the future
  static bool isFuture(DateTime dateTime) {
    return dateTime.isAfter(DateTime.now());
  }

  // ========== Smart Formatting ==========

  /// Smart format that chooses the best format based on context
  ///
  /// - Today: "1:08 PM"
  /// - Yesterday: "Yesterday at 1:08 PM"
  /// - This week: "Monday at 1:08 PM"
  /// - This year: "Sep 15 at 1:08 PM"
  /// - Other years: "Sep 15, 2023"
  static String formatSmart(DateTime dateTime) {
    if (isToday(dateTime)) {
      return formatTime(dateTime);
    } else if (isYesterday(dateTime)) {
      return 'Yesterday at ${formatTime(dateTime)}';
    } else if (DateTime.now().difference(dateTime).inDays < 7) {
      return '${DateFormat('EEEE').format(dateTime)} at ${formatTime(dateTime)}';
    } else if (isThisYear(dateTime)) {
      return '${formatDayMonth(dateTime)} at ${formatTime(dateTime)}';
    } else {
      return formatMediumDate(dateTime);
    }
  }
}
