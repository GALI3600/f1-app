import 'package:f1sync/core/theme/f1_colors.dart';
import 'package:f1sync/core/theme/f1_text_styles.dart';
import 'package:f1sync/features/meetings/data/models/meeting.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// GP List Tile Widget
/// Displays a Grand Prix in a list with:
/// - Country flag, round badge, name, circuit, dates
/// - Vermelho accent strip on left
/// - Sprint weekend indicator
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            decoration: BoxDecoration(
              color: F1Colors.navy,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: F1Colors.border,
                width: 1,
              ),
            ),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  // Vermelho accent strip
                  Container(
                    width: 4,
                    decoration: const BoxDecoration(
                      color: F1Colors.vermelho,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(14),
                        bottomLeft: Radius.circular(14),
                      ),
                    ),
                  ),

                  // Main content
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
                      child: Row(
                        children: [
                          // Flag + Round badge
                          _buildFlagSection(),

                          const SizedBox(width: 14),

                          // GP Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Meeting Name
                                Text(
                                  meeting.meetingName,
                                  style: F1TextStyles.headlineSmall.copyWith(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    height: 1.2,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),

                                const SizedBox(height: 6),

                                // Circuit name
                                Text(
                                  meeting.circuitShortName,
                                  style: F1TextStyles.bodyMedium.copyWith(
                                    color: F1Colors.textSecondary,
                                    fontSize: 13,
                                    height: 1.2,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),

                                const SizedBox(height: 8),

                                // Date + Location row
                                Row(
                                  children: [
                                    // Date chip
                                    _buildInfoChip(
                                      Icons.calendar_today_rounded,
                                      _formatDate(meeting.dateStart),
                                    ),

                                    const SizedBox(width: 10),

                                    // Location chip
                                    Flexible(
                                      child: _buildInfoChip(
                                        Icons.location_on_rounded,
                                        meeting.location,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 8),

                          // Right side: sprint badge + chevron
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (meeting.isSprintWeekend) ...[
                                _buildSprintBadge(),
                                const SizedBox(height: 8),
                              ],
                              const Icon(
                                Icons.chevron_right_rounded,
                                color: F1Colors.textTertiary,
                                size: 22,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFlagSection() {
    final flag = _getFlagEmoji(meeting.countryCode);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Flag circle
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: F1Colors.navyLight.withValues(alpha: 0.6),
            border: Border.all(
              color: F1Colors.border,
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              flag,
              style: const TextStyle(fontSize: 28),
            ),
          ),
        ),

        const SizedBox(height: 6),

        // Round badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: F1Colors.vermelho.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: F1Colors.vermelho.withValues(alpha: 0.3),
              width: 0.5,
            ),
          ),
          child: Text(
            'R${meeting.meetingKey}',
            style: F1TextStyles.labelSmall.copyWith(
              color: F1Colors.vermelho,
              fontWeight: FontWeight.w700,
              fontSize: 10,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: F1Colors.textTertiary),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            style: F1TextStyles.bodySmall.copyWith(
              color: F1Colors.textTertiary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildSprintBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: F1Colors.dourado.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: F1Colors.dourado.withValues(alpha: 0.4),
          width: 0.5,
        ),
      ),
      child: Text(
        'SPRINT',
        style: F1TextStyles.labelSmall.copyWith(
          color: F1Colors.dourado,
          fontWeight: FontWeight.w800,
          fontSize: 9,
          letterSpacing: 1,
        ),
      ),
    );
  }

  /// Convert country code to flag emoji using Unicode regional indicator symbols
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

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }
}
