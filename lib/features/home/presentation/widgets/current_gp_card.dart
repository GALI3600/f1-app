import 'package:flutter/material.dart';
import 'package:f1sync/core/theme/f1_colors.dart';
import 'package:f1sync/core/theme/f1_text_styles.dart';
import 'package:f1sync/core/theme/f1_gradients.dart';
import 'package:f1sync/features/meetings/data/models/meeting.dart';
import 'package:f1sync/shared/widgets/f1_card.dart';
import 'package:intl/intl.dart';

/// Current Grand Prix card widget for the home screen
///
/// Displays information about the current or next Grand Prix including:
/// - GP name and official name
/// - Country flag and circuit name
/// - Date and time until start
/// - Location information
class CurrentGPCard extends StatelessWidget {
  /// The meeting/GP to display
  final Meeting meeting;

  /// Optional callback when card is tapped
  final VoidCallback? onTap;

  const CurrentGPCard({
    super.key,
    required this.meeting,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return F1Card.gradient(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with flag icon
          Row(
            children: [
              // Flag emoji (country code)
              Text(
                _getFlagEmoji(meeting.countryCode),
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // "NEXT GP" label with gradient
                    ShaderMask(
                      shaderCallback: (bounds) =>
                          F1Gradients.cianRoxo.createShader(bounds),
                      child: Text(
                        '🏁 NEXT GP',
                        style: F1TextStyles.labelLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    // GP Name
                    Text(
                      meeting.meetingName,
                      style: F1TextStyles.headlineMedium.copyWith(
                        color: F1Colors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Divider
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  F1Colors.ciano.withValues(alpha: 0.3),
                  F1Colors.roxo.withValues(alpha: 0.3),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Circuit information
          Row(
            children: [
              Icon(
                Icons.location_on_rounded,
                color: F1Colors.ciano,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meeting.circuitShortName,
                      style: F1TextStyles.bodyLarge.copyWith(
                        color: F1Colors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${meeting.location}, ${meeting.countryName}',
                      style: F1TextStyles.bodyMedium.copyWith(
                        color: F1Colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Date information
          Row(
            children: [
              Icon(
                Icons.calendar_today_rounded,
                color: F1Colors.roxo,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatDate(meeting.dateStart),
                      style: F1TextStyles.bodyMedium.copyWith(
                        color: F1Colors.textPrimary,
                      ),
                    ),
                    Text(
                      _getTimeUntil(meeting.dateStart),
                      style: F1TextStyles.bodySmall.copyWith(
                        color: F1Colors.ciano,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Optional "View Details" button
          if (onTap != null) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'View Details',
                  style: F1TextStyles.labelMedium.copyWith(
                    color: F1Colors.ciano,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: F1Colors.ciano,
                  size: 16,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// Convert country code to flag emoji
  String _getFlagEmoji(String countryCode) {
    // Convert country code to flag emoji using Unicode regional indicator symbols
    if (countryCode.length != 2) return '🏁';

    final firstChar = countryCode.codeUnitAt(0) + 127397;
    final secondChar = countryCode.codeUnitAt(1) + 127397;

    return String.fromCharCodes([firstChar, secondChar]);
  }

  /// Format the date in a readable way
  String _formatDate(DateTime date) {
    final formatter = DateFormat('EEEE, MMMM d, yyyy');
    return formatter.format(date);
  }

  /// Get time until the GP starts
  String _getTimeUntil(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);

    if (difference.isNegative) {
      return 'Live Now! 🔴';
    }

    if (difference.inDays > 0) {
      final days = difference.inDays;
      final hours = difference.inHours % 24;
      return 'In $days day${days > 1 ? 's' : ''}, $hours hour${hours != 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      final hours = difference.inHours;
      final minutes = difference.inMinutes % 60;
      return 'In $hours hour${hours > 1 ? 's' : ''}, $minutes min${minutes != 1 ? 's' : ''}';
    } else {
      final minutes = difference.inMinutes;
      return 'In $minutes minute${minutes > 1 ? 's' : ''}';
    }
  }
}
