import 'package:f1sync/core/theme/f1_colors.dart';
import 'package:f1sync/core/theme/f1_gradients.dart';
import 'package:f1sync/features/meetings/data/models/meeting.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// GP List Tile Widget
/// Displays a Grand Prix in a list with:
/// - Country flag, name, location, dates
/// - Gradient left border
/// - Tap to navigate to detail
class GPListTile extends StatelessWidget {
  final Meeting meeting;
  final VoidCallback? onTap;

  const GPListTile({
    super.key,
    required this.meeting,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                F1Colors.ciano.withValues(alpha: 0.3),
                Colors.transparent,
              ],
              stops: const [0.0, 0.05], // Gradient only on left border
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Country Flag
                _buildCountryFlag(),

                const SizedBox(width: 16),

                // Meeting Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Meeting Name
                      Text(
                        meeting.meetingName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: F1Colors.textPrimary,
                        ),
                      ),

                      const SizedBox(height: 4),

                      // Location and Circuit
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 16,
                            color: F1Colors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${meeting.location} • ${meeting.circuitShortName}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: F1Colors.textSecondary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Date
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_outlined,
                            size: 16,
                            color: F1Colors.ciano,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatDate(meeting.dateStart),
                            style: const TextStyle(
                              fontSize: 14,
                              color: F1Colors.ciano,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Chevron
                const Icon(
                  Icons.chevron_right,
                  color: F1Colors.ciano,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCountryFlag() {
    // Display country code in a circle with gradient background
    // In a real app, you could use a flag image or emoji
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: F1Gradients.cianRoxo,
      ),
      child: Center(
        child: Text(
          meeting.countryCode,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }
}
