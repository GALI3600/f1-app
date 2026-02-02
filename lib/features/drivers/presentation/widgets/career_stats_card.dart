import 'package:flutter/material.dart';
import '../../../../core/theme/f1_colors.dart';
import '../../../../core/theme/f1_text_styles.dart';
import '../../data/models/driver_career.dart';

/// Card displaying driver career statistics
class CareerStatsCard extends StatelessWidget {
  final DriverCareer career;

  const CareerStatsCard({
    super.key,
    required this.career,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: F1Colors.navy,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: F1Colors.ciano.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.emoji_events,
                color: F1Colors.dourado,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Career Statistics',
                style: F1TextStyles.headlineSmall.copyWith(
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Main stats grid
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  label: 'Championships',
                  value: career.championships.toString(),
                  icon: Icons.workspace_premium,
                  color: F1Colors.dourado,
                  isHighlighted: career.championships > 0,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatTile(
                  label: 'Race Wins',
                  value: career.wins.toString(),
                  icon: Icons.flag,
                  color: F1Colors.ciano,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  label: 'Podiums',
                  value: career.podiums.toString(),
                  icon: Icons.emoji_events_outlined,
                  color: F1Colors.textSecondary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatTile(
                  label: 'Pole Positions',
                  value: career.poles.toString(),
                  icon: Icons.speed,
                  color: Colors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  label: 'Race Starts',
                  value: career.totalRaces.toString(),
                  icon: Icons.start,
                  color: F1Colors.textSecondary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatTile(
                  label: 'Seasons',
                  value: career.seasons.toString(),
                  icon: Icons.calendar_today,
                  color: F1Colors.textSecondary,
                ),
              ),
            ],
          ),

          // Championship years
          if (career.championshipYears != null &&
              career.championshipYears!.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(color: F1Colors.textSecondary, height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.star,
                  color: F1Colors.dourado,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'World Champion: ',
                  style: F1TextStyles.bodyMedium.copyWith(
                    color: F1Colors.textSecondary,
                  ),
                ),
                Expanded(
                  child: Text(
                    career.championshipYears!.join(', '),
                    style: F1TextStyles.bodyMedium.copyWith(
                      color: F1Colors.dourado,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],

          // Current season standing
          if (career.currentSeasonPosition != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.leaderboard,
                  color: F1Colors.ciano,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  '2025 Standing: ',
                  style: F1TextStyles.bodyMedium.copyWith(
                    color: F1Colors.textSecondary,
                  ),
                ),
                Text(
                  'P${career.currentSeasonPosition}',
                  style: F1TextStyles.bodyMedium.copyWith(
                    color: F1Colors.ciano,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (career.currentSeasonPoints != null) ...[
                  Text(
                    ' (${career.currentSeasonPoints!.toStringAsFixed(0)} pts)',
                    style: F1TextStyles.bodyMedium.copyWith(
                      color: F1Colors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ],

          // Nationality and DOB
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.public,
                color: F1Colors.textSecondary,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                career.nationality,
                style: F1TextStyles.bodyMedium.copyWith(
                  color: F1Colors.textSecondary,
                ),
              ),
              if (career.dateOfBirth != null) ...[
                const SizedBox(width: 16),
                Icon(
                  Icons.cake,
                  color: F1Colors.textSecondary,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  career.dateOfBirth!,
                  style: F1TextStyles.bodyMedium.copyWith(
                    color: F1Colors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool isHighlighted;

  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isHighlighted
            ? F1Colors.dourado.withValues(alpha: 0.15)
            : F1Colors.navyDeep,
        borderRadius: BorderRadius.circular(12),
        border: isHighlighted
            ? Border.all(color: F1Colors.dourado.withValues(alpha: 0.5), width: 1)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const Spacer(),
              Text(
                value,
                style: F1TextStyles.displaySmall.copyWith(
                  color: color,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: F1TextStyles.bodySmall.copyWith(
              color: F1Colors.textSecondary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
