import 'package:flutter/material.dart';
import 'package:f1sync/core/theme/f1_colors.dart';
import 'package:f1sync/core/theme/f1_text_styles.dart';
import 'package:f1sync/features/home/presentation/providers/standings_provider.dart';
import 'package:f1sync/shared/widgets/f1_card.dart';

/// Quick statistics card for the home screen
///
/// Displays key statistics in a grid layout:
/// - Championship leader (from real standings)
/// - Leading team (from real standings)
/// - Total drivers in season
/// - Current session info
class QuickStatsCard extends StatelessWidget {
  /// Standings data with championship leader and leading constructor
  final StandingsData standings;

  /// Optional session name (e.g., "Race", "Qualifying")
  final String? sessionName;

  /// Optional callback when a stat is tapped
  final Function(String statType)? onStatTap;

  const QuickStatsCard({
    super.key,
    required this.standings,
    this.sessionName,
    this.onStatTap,
  });

  @override
  Widget build(BuildContext context) {
    // Get the championship leader
    final leader = standings.championshipLeader;

    // Get the leading constructor
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
        const SizedBox(height: 8),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.4,
          children: [
            // Championship Leader
            _StatCard(
              icon: Icons.emoji_events_rounded,
              iconColor: F1Colors.dourado,
              label: 'Championship Leader',
              value: leader?.driverCode ?? '---',
              subtitle: leader != null
                  ? '${leader.points.toInt()} pts'
                  : null,
              onTap: onStatTap != null ? () => onStatTap!('leader') : null,
            ),

            // Leading Team
            _StatCard(
              icon: Icons.groups_rounded,
              iconColor: F1Colors.ciano,
              label: 'Leading Team',
              value: leadingTeam != null
                  ? (leadingTeam.name.length > 12
                      ? '${leadingTeam.name.substring(0, 12)}...'
                      : leadingTeam.name)
                  : '---',
              subtitle: leadingTeam != null
                  ? '${leadingTeam.points.toInt()} pts'
                  : '${standings.totalConstructors} teams',
              onTap: onStatTap != null ? () => onStatTap!('teams') : null,
            ),

            // Total Drivers
            _StatCard(
              icon: Icons.person_rounded,
              iconColor: F1Colors.roxo,
              label: 'Drivers',
              value: '${standings.totalDrivers}',
              subtitle: 'in championship',
              onTap: onStatTap != null ? () => onStatTap!('drivers') : null,
            ),

            // Current Session (if available)
            if (sessionName != null)
              _StatCard(
                icon: Icons.flag_rounded,
                iconColor: F1Colors.vermelho,
                label: 'Session',
                value: _shortenSessionName(sessionName!),
                subtitle: 'Current',
                onTap: onStatTap != null ? () => onStatTap!('session') : null,
              )
            else
              _StatCard(
                icon: Icons.calendar_month_rounded,
                iconColor: F1Colors.textSecondary,
                label: 'Off-Season',
                value: '---',
                subtitle: 'No active session',
              ),
          ],
        ),
      ],
    );
  }

  /// Shorten session name if too long
  String _shortenSessionName(String name) {
    // Remove common prefixes/suffixes
    name = name
        .replaceAll('Practice ', 'FP')
        .replaceAll('Qualifying', 'Quali')
        .replaceAll('Sprint Qualifying', 'SQ');

    if (name.length > 10) {
      return name.substring(0, 10);
    }

    return name;
  }
}

/// Individual stat card widget
class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String? subtitle;
  final VoidCallback? onTap;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return F1Card.primary(
      padding: const EdgeInsets.all(10),
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 18,
            ),
          ),
          const SizedBox(height: 6),

          // Label
          Text(
            label,
            style: F1TextStyles.labelSmall.copyWith(
              color: F1Colors.textSecondary,
              fontSize: 9,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),

          // Value
          Text(
            value,
            style: F1TextStyles.headlineSmall.copyWith(
              color: F1Colors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          // Subtitle (optional)
          if (subtitle != null)
            Text(
              subtitle!,
              style: F1TextStyles.bodySmall.copyWith(
                color: F1Colors.textSecondary,
                fontSize: 9,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    );
  }
}
