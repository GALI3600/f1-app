import 'package:flutter/material.dart';
import '../../../session_results/data/models/session_result.dart';
import '../../../drivers/data/models/driver.dart';
import '../../../../shared/widgets/driver_avatar.dart';
import '../../../../shared/widgets/team_color_strip.dart';
import '../../../../core/theme/f1_colors.dart';

/// Card displaying a single result row in session results
class SessionResultCard extends StatelessWidget {
  final SessionResult result;
  final Driver? driver;
  final bool isFastestLap;
  final int? positionsGained; // Positive = gained, negative = lost

  const SessionResultCard({
    super.key,
    required this.result,
    this.driver,
    this.isFastestLap = false,
    this.positionsGained,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Team color strip
            if (driver != null)
              TeamColorStrip(
                teamColor: driver!.teamColour,
                width: 4,
              ),
            // Position badge
            _buildPositionBadge(context),
            const SizedBox(width: 12),
            // Driver info
            if (driver != null) ...[
              DriverAvatar(
                imageUrl: driver!.headshotUrl,
                teamColor: driver!.teamColour,
                driverName: driver!.fullName,
                size: DriverAvatarSize.small,
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          driver?.fullName ?? 'Driver ${result.driverNumber}',
                          style: Theme.of(context).textTheme.titleMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Fastest lap indicator
                      if (isFastestLap)
                        Container(
                          margin: const EdgeInsets.only(left: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: F1Colors.roxo.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: F1Colors.roxo),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.flash_on,
                                size: 12,
                                color: F1Colors.roxo,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                'FL',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: F1Colors.roxo,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        driver?.teamName ?? '',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: F1Colors.textSecondary,
                            ),
                      ),
                      if (result.dnf || result.dns || result.dsq) ...[
                        const SizedBox(width: 8),
                        _buildStatusBadge(context),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Gap/Time info
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (result.position == 1)
                  Text(
                    _formatDuration(result.duration),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'RobotoMono',
                        ),
                  )
                else
                  Text(
                    '+${_formatGap(result.gapToLeader)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'RobotoMono',
                          color: F1Colors.textSecondary,
                        ),
                  ),
                const SizedBox(height: 4),
                Text(
                  '${result.numberOfLaps} laps',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            // Positions gained/lost indicator
            if (positionsGained != null && positionsGained != 0) ...[
              const SizedBox(width: 8),
              _buildPositionChangeIndicator(context),
            ],
            const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildPositionBadge(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: _getPositionGradient(),
        border: result.position > 3
            ? Border.all(color: F1Colors.ciano, width: 2)
            : null,
      ),
      child: Center(
        child: Text(
          '${result.position}',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: result.position <= 3 ? Colors.black : Colors.white,
              ),
        ),
      ),
    );
  }

  LinearGradient? _getPositionGradient() {
    switch (result.position) {
      case 1:
        return const LinearGradient(
          colors: [Color(0xFFFFD700), Color(0xFFFFA500)], // Gold
        );
      case 2:
        return const LinearGradient(
          colors: [Color(0xFFC0C0C0), Color(0xFF808080)], // Silver
        );
      case 3:
        return const LinearGradient(
          colors: [Color(0xFFCD7F32), Color(0xFF8B4513)], // Bronze
        );
      default:
        return null;
    }
  }

  Widget _buildStatusBadge(BuildContext context) {
    String status;
    Color color;

    if (result.dnf) {
      status = 'DNF';
      color = F1Colors.vermelho;
    } else if (result.dns) {
      status = 'DNS';
      color = F1Colors.warning;
    } else if (result.dsq) {
      status = 'DSQ';
      color = F1Colors.error;
    } else {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color),
      ),
      child: Text(
        status,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildPositionChangeIndicator(BuildContext context) {
    final isPositive = positionsGained! > 0;
    final color = isPositive ? F1Colors.success : F1Colors.vermelho;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPositive ? Icons.arrow_upward : Icons.arrow_downward,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 2),
          Text(
            '${positionsGained!.abs()}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Color _getTeamColor(String teamColour) {
    try {
      final hex = teamColour.startsWith('#') ? teamColour : '#$teamColour';
      return Color(int.parse(hex.substring(1), radix: 16) + 0xFF000000);
    } catch (e) {
      return F1Colors.ciano;
    }
  }

  String _formatDuration(double seconds) {
    final duration = Duration(milliseconds: (seconds * 1000).round());
    final minutes = duration.inMinutes;
    final remainingSeconds = duration.inSeconds % 60;
    final milliseconds = duration.inMilliseconds % 1000;

    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}.${(milliseconds ~/ 10).toString().padLeft(2, '0')}';
  }

  String _formatGap(double gap) {
    if (gap < 60) {
      return '${gap.toStringAsFixed(3)}s';
    } else {
      final minutes = gap ~/ 60;
      final seconds = gap % 60;
      return '${minutes}m ${seconds.toStringAsFixed(1)}s';
    }
  }
}
