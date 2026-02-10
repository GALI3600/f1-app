import 'package:f1sync/core/theme/f1_colors.dart';
import 'package:f1sync/core/theme/f1_text_styles.dart';
import 'package:f1sync/features/meetings/data/models/meeting.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// GP Header Card Widget
/// Detail screen header displaying:
/// - Large country flag emoji
/// - Official name, round, circuit, dates
/// - Sprint weekend badge
/// - Gradient background with vermelho accents
class GPHeaderCard extends StatelessWidget {
  final Meeting meeting;

  const GPHeaderCard({
    super.key,
    required this.meeting,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      decoration: BoxDecoration(
        color: F1Colors.navy,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: F1Colors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top section: flag + round + sprint badge
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Flag circle
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: F1Colors.navyLight.withValues(alpha: 0.6),
                    border: Border.all(
                      color: F1Colors.border,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _getFlagEmoji(meeting.countryCode),
                      style: const TextStyle(fontSize: 34),
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // Name + country
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Meeting name
                      Text(
                        meeting.meetingName,
                        style: F1TextStyles.headlineLarge.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 6),

                      // Country name
                      Text(
                        meeting.countryName,
                        style: F1TextStyles.bodyMedium.copyWith(
                          color: F1Colors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Divider
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            color: F1Colors.border,
          ),

          const SizedBox(height: 14),

          // Info row: round, circuit, date
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
            child: Wrap(
              spacing: 10,
              runSpacing: 8,
              children: [
                // Round badge
                _buildChip(
                  icon: Icons.tag_rounded,
                  label: 'Round ${meeting.meetingKey}',
                  color: F1Colors.vermelho,
                ),

                // Circuit
                _buildChip(
                  icon: Icons.sports_score_rounded,
                  label: meeting.circuitShortName,
                  color: F1Colors.textSecondary,
                ),

                // Date
                _buildChip(
                  icon: Icons.calendar_today_rounded,
                  label: _formatDateRange(meeting.dateStart),
                  color: F1Colors.textSecondary,
                ),

                // Location
                _buildChip(
                  icon: Icons.location_on_rounded,
                  label: meeting.location,
                  color: F1Colors.textSecondary,
                ),

                // Sprint badge
                if (meeting.isSprintWeekend)
                  _buildChip(
                    icon: Icons.bolt_rounded,
                    label: 'Sprint Weekend',
                    color: F1Colors.dourado,
                    filled: true,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip({
    required IconData icon,
    required String label,
    required Color color,
    bool filled = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: filled
            ? color.withValues(alpha: 0.15)
            : F1Colors.navyLight.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: filled
            ? Border.all(color: color.withValues(alpha: 0.4), width: 0.5)
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: F1TextStyles.labelSmall.copyWith(
              color: color,
              fontWeight: filled ? FontWeight.w700 : FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  String _getFlagEmoji(String countryCode) {
    var code = countryCode.toUpperCase();
    if (code.length == 3) {
      code = _countryCodeMap[code] ?? code.substring(0, 2);
    }
    if (code.length != 2) return '\u{1F3C1}';
    final firstChar = code.codeUnitAt(0) + 127397;
    final secondChar = code.codeUnitAt(1) + 127397;
    return String.fromCharCodes([firstChar, secondChar]);
  }

  static const _countryCodeMap = {
    'ARG': 'AR', 'AUS': 'AU', 'AUT': 'AT', 'BEL': 'BE', 'BRA': 'BR',
    'CAN': 'CA', 'CHN': 'CN', 'COL': 'CO', 'DEN': 'DK', 'FIN': 'FI',
    'FRA': 'FR', 'GBR': 'GB', 'GER': 'DE', 'HUN': 'HU', 'IND': 'IN',
    'IRL': 'IE', 'ITA': 'IT', 'JPN': 'JP', 'MEX': 'MX', 'MON': 'MC',
    'NED': 'NL', 'NZL': 'NZ', 'POL': 'PL', 'POR': 'PT', 'RSA': 'ZA',
    'RUS': 'RU', 'ESP': 'ES', 'SUI': 'CH', 'SWE': 'SE', 'THA': 'TH',
    'UAE': 'AE', 'USA': 'US', 'VEN': 'VE', 'SGP': 'SG', 'QAT': 'QA',
    'SAU': 'SA', 'BHR': 'BH', 'AZE': 'AZ',
  };

  String _formatDateRange(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }
}
