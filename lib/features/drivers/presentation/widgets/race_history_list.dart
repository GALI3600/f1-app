import 'package:flutter/material.dart';
import '../../../../core/theme/f1_colors.dart';
import '../../../../core/theme/f1_text_styles.dart';
import '../../data/models/driver_race_result.dart';

/// Widget displaying a list of race results for a driver
class RaceHistoryList extends StatelessWidget {
  final List<DriverRaceResult> results;
  final Color teamColor;

  const RaceHistoryList({
    super.key,
    required this.results,
    required this.teamColor,
  });

  @override
  Widget build(BuildContext context) {
    if (results.isEmpty) {
      return const Center(
        child: Text(
          'No race history available',
          style: TextStyle(color: F1Colors.textSecondary),
        ),
      );
    }

    // Group results by season
    final groupedResults = <int, List<DriverRaceResult>>{};
    for (final result in results) {
      groupedResults.putIfAbsent(result.season, () => []).add(result);
    }

    // Sort seasons in descending order (most recent first)
    final seasons = groupedResults.keys.toList()..sort((a, b) => b.compareTo(a));

    // Sort races within each season by round in descending order (most recent first)
    for (final season in seasons) {
      groupedResults[season]!.sort((a, b) => b.round.compareTo(a.round));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: seasons.length,
      itemBuilder: (context, index) {
        final season = seasons[index];
        final seasonResults = groupedResults[season]!;

        return _SeasonSection(
          season: season,
          results: seasonResults,
          teamColor: teamColor,
        );
      },
    );
  }
}

class _SeasonSection extends StatelessWidget {
  final int season;
  final List<DriverRaceResult> results;
  final Color teamColor;

  const _SeasonSection({
    required this.season,
    required this.results,
    required this.teamColor,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate season stats (wins/podiums from races only, points from all)
    final races = results.where((r) => !r.isSprint).toList();
    final wins = races.where((r) => r.isWin).length;
    final podiums = races.where((r) => r.isPodium).length;
    final points = results.fold<double>(0, (sum, r) => sum + r.points);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Season header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: teamColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Text(
                '$season',
                style: F1TextStyles.headlineMedium.copyWith(
                  color: teamColor,
                ),
              ),
              const Spacer(),
              _StatChip(label: '${results.length} races', color: F1Colors.textSecondary),
              const SizedBox(width: 8),
              if (wins > 0) ...[
                _StatChip(label: '$wins wins', color: F1Colors.dourado),
                const SizedBox(width: 8),
              ],
              if (podiums > wins) ...[
                _StatChip(label: '$podiums podiums', color: F1Colors.textSecondary),
                const SizedBox(width: 8),
              ],
              _StatChip(label: '${points.toInt()} pts', color: F1Colors.textPrimary),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Race results
        ...results.map((result) => _RaceResultCard(
          result: result,
          teamColor: teamColor,
        )),

        const SizedBox(height: 16),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final Color color;

  const _StatChip({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: F1TextStyles.bodySmall.copyWith(
        color: color,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class _RaceResultCard extends StatelessWidget {
  final DriverRaceResult result;
  final Color teamColor;

  const _RaceResultCard({
    required this.result,
    required this.teamColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: F1Colors.navy,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: result.isWin
              ? F1Colors.dourado.withValues(alpha: 0.5)
              : result.isPodium
                  ? teamColor.withValues(alpha: 0.3)
                  : F1Colors.navy,
          width: result.isWin ? 2 : 1,
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Position indicator
            Container(
              width: 50,
              decoration: BoxDecoration(
                color: _getPositionColor(result.position),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(11),
                  bottomLeft: Radius.circular(11),
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      result.finished ? 'P${result.position}' : 'DNF',
                      style: F1TextStyles.bodyLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (result.positionChange != 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: result.positionChange > 0
                              ? const Color(0xFF00E676)
                              : const Color(0xFFFF5252),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          result.positionChange > 0
                              ? '+${result.positionChange}'
                              : '${result.positionChange}',
                          style: F1TextStyles.bodySmall.copyWith(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Race info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            result.raceName,
                            style: F1TextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (result.isSprint)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: F1Colors.vermelho.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'SPRINT',
                              style: TextStyle(
                                color: F1Colors.vermelho,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        if (result.hasFastestLap)
                          Container(
                            margin: EdgeInsets.only(left: result.isSprint ? 4 : 0),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.purple.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'FL',
                              style: TextStyle(
                                color: Colors.purple,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 12,
                          color: F1Colors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          result.country,
                          style: F1TextStyles.bodySmall.copyWith(
                            color: F1Colors.textSecondary,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Grid: P${result.gridPosition}',
                          style: F1TextStyles.bodySmall.copyWith(
                            color: F1Colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Points
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    result.points > 0 ? '+${result.points.toInt()}' : '0',
                    style: F1TextStyles.bodyLarge.copyWith(
                      color: result.points > 0 ? const Color(0xFF00E676) : F1Colors.textSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'pts',
                    style: F1TextStyles.bodySmall.copyWith(
                      color: F1Colors.textSecondary,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getPositionColor(int position) {
    if (!result.finished) return F1Colors.vermelho;

    return switch (position) {
      1 => F1Colors.dourado,
      2 => Colors.grey.shade400,
      3 => Colors.brown.shade400,
      _ when position <= 10 => F1Colors.textSecondary.withValues(alpha: 0.8),
      _ => F1Colors.navy.withValues(alpha: 0.8),
    };
  }
}
