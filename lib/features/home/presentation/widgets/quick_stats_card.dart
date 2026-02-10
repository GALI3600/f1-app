import 'package:flutter/material.dart';
import 'package:f1sync/core/theme/f1_colors.dart';
import 'package:f1sync/core/theme/f1_text_styles.dart';
import 'package:f1sync/features/home/presentation/providers/standings_provider.dart';

/// Quick statistics card for the home screen
///
/// Displays key statistics in a 2x2 grid:
/// - Championship leader
/// - Leading team
/// - Total drivers
/// - Current session or season info
class QuickStatsCard extends StatelessWidget {
  final StandingsData standings;
  final String? sessionName;
  final Function(String statType)? onStatTap;

  const QuickStatsCard({
    super.key,
    required this.standings,
    this.sessionName,
    this.onStatTap,
  });

  @override
  Widget build(BuildContext context) {
    final leader = standings.championshipLeader;
    final leadingTeam = standings.leadingConstructor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Text(
            'Quick Stats',
            style: F1TextStyles.headlineSmall.copyWith(
              color: F1Colors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 4),

        // 2x2 Grid
        Row(
          children: [
            Expanded(
              child: _StatTile(
                icon: Icons.emoji_events_rounded,
                iconColor: F1Colors.dourado,
                label: 'Championship Leader',
                value: leader != null
                    ? '${leader.givenName[0]}. ${leader.familyName}'
                    : '---',
                detail: leader != null
                    ? '${leader.points.toInt()} pts'
                    : null,
                onTap: onStatTap != null ? () => onStatTap!('leader') : null,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatTile(
                icon: Icons.groups_rounded,
                iconColor: F1Colors.textSecondary,
                label: 'Leading Team',
                value: leadingTeam != null
                    ? _truncate(leadingTeam.name, 12)
                    : '---',
                detail: leadingTeam != null
                    ? '${leadingTeam.points.toInt()} pts'
                    : null,
                onTap: onStatTap != null ? () => onStatTap!('teams') : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _StatTile(
                icon: Icons.person_rounded,
                iconColor: F1Colors.textSecondary,
                label: 'Drivers',
                value: '${standings.totalDrivers}',
                detail: 'in championship',
                onTap: onStatTap != null ? () => onStatTap!('drivers') : null,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: sessionName != null
                  ? _StatTile(
                      icon: Icons.flag_rounded,
                      iconColor: F1Colors.vermelho,
                      label: 'Session',
                      value: _shortenSessionName(sessionName!),
                      detail: 'Current',
                      onTap: onStatTap != null
                          ? () => onStatTap!('session')
                          : null,
                    )
                  : _StatTile(
                      icon: Icons.calendar_month_rounded,
                      iconColor: F1Colors.textSecondary,
                      label: 'Season',
                      value: '${standings.totalConstructors}',
                      detail: 'teams',
                    ),
            ),
          ],
        ),
      ],
    );
  }

  String _truncate(String text, int max) {
    return text.length > max ? '${text.substring(0, max)}...' : text;
  }

  String _shortenSessionName(String name) {
    return name
        .replaceAll('Practice ', 'FP')
        .replaceAll('Qualifying', 'Quali')
        .replaceAll('Sprint Qualifying', 'SQ');
  }
}

/// Individual stat tile for the 2x2 grid
class _StatTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String? detail;
  final VoidCallback? onTap;

  const _StatTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    this.detail,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: F1Colors.navy,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: F1Colors.border, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: iconColor, size: 26),
            const SizedBox(height: 12),
            Text(
              value,
              style: F1TextStyles.headlineSmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: F1TextStyles.bodySmall.copyWith(
                color: F1Colors.textSecondary,
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (detail != null) ...[
              const SizedBox(height: 2),
              Text(
                detail!,
                style: F1TextStyles.bodySmall.copyWith(
                  color: F1Colors.textSecondary.withValues(alpha: 0.6),
                  fontSize: 11,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
