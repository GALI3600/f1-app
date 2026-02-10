import 'package:flutter/material.dart';
import '../../../session_results/data/models/session_result.dart';
import '../../../drivers/data/models/driver.dart';
import '../../../../shared/widgets/driver_avatar.dart';
import '../../../../shared/widgets/team_color_strip.dart';
import '../../../../core/theme/f1_colors.dart';
import '../../../../core/theme/f1_text_styles.dart';

/// Card displaying a single result row in session results
class SessionResultCard extends StatelessWidget {
  final SessionResult result;
  final Driver? driver;
  final bool isFastestLap;
  final int? positionsGained;

  const SessionResultCard({
    super.key,
    required this.result,
    this.driver,
    this.isFastestLap = false,
    this.positionsGained,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: F1Colors.navy,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: F1Colors.border, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
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
              _buildPositionBadge(),

              const SizedBox(width: 10),

              // Driver avatar
              if (driver != null) ...[
                DriverAvatar(
                  imageUrl: driver!.headshotUrl,
                  teamColor: driver!.teamColour,
                  driverName: driver!.fullName,
                  size: DriverAvatarSize.small,
                ),
                const SizedBox(width: 10),
              ],

              // Driver info
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Name + badges row
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              driver?.fullName ?? 'Driver ${result.driverNumber}',
                              style: F1TextStyles.bodyLarge.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                height: 1.2,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isFastestLap) ...[
                            const SizedBox(width: 6),
                            _buildFastestLapBadge(),
                          ],
                          if (result.dnf || result.dns || result.dsq) ...[
                            const SizedBox(width: 6),
                            _buildStatusBadge(),
                          ],
                        ],
                      ),

                      const SizedBox(height: 3),

                      // Team name
                      Text(
                        driver?.teamName ?? result.teamName ?? '',
                        style: F1TextStyles.bodySmall.copyWith(
                          color: F1Colors.textTertiary,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Time/gap info
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildTimeDisplay(),
                    if (result.numberOfLaps > 0) ...[
                      const SizedBox(height: 2),
                      Text(
                        '${result.numberOfLaps} laps',
                        style: F1TextStyles.bodySmall.copyWith(
                          color: F1Colors.textTertiary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Position change indicator
              if (positionsGained != null && positionsGained != 0) ...[
                const SizedBox(width: 6),
                _buildPositionChangeIndicator(),
              ],

              const SizedBox(width: 14),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPositionBadge() {
    return Container(
      width: 36,
      height: 36,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: _getPositionGradient(),
        border: result.position > 3
            ? Border.all(color: F1Colors.border, width: 1.5)
            : null,
      ),
      child: Center(
        child: Text(
          '${result.position}',
          style: F1TextStyles.positionSmall.copyWith(
            fontSize: 14,
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
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFD700), Color(0xFFE5A100)],
        );
      case 2:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFD0D0D0), Color(0xFF909090)],
        );
      case 3:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFCD7F32), Color(0xFF9A5E1F)],
        );
      default:
        return null;
    }
  }

  Widget _buildFastestLapBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: F1Colors.roxo.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: F1Colors.roxo.withValues(alpha: 0.5),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.flash_on_rounded, size: 11, color: F1Colors.roxo),
          const SizedBox(width: 2),
          Text(
            'FL',
            style: F1TextStyles.labelSmall.copyWith(
              color: F1Colors.roxo,
              fontWeight: FontWeight.w800,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
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
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: color.withValues(alpha: 0.5),
          width: 0.5,
        ),
      ),
      child: Text(
        status,
        style: F1TextStyles.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 9,
        ),
      ),
    );
  }

  Widget _buildTimeDisplay() {
    if (result.position == 1) {
      return Text(
        _formatDuration(result.duration),
        style: F1TextStyles.lapTimeSmall.copyWith(
          fontSize: 14,
          color: F1Colors.textPrimary,
        ),
      );
    }

    if (result.dnf || result.dns || result.dsq) {
      return Text(
        result.status ?? 'DNF',
        style: F1TextStyles.lapTimeSmall.copyWith(
          fontSize: 14,
          color: F1Colors.vermelho,
        ),
      );
    }

    if (result.gapToLeader > 0) {
      return Text(
        '+${_formatGap(result.gapToLeader)}',
        style: F1TextStyles.lapTimeSmall.copyWith(
          fontSize: 13,
          color: F1Colors.textSecondary,
        ),
      );
    }

    if (result.status != null && result.status!.startsWith('+')) {
      return Text(
        result.status!,
        style: F1TextStyles.lapTimeSmall.copyWith(
          fontSize: 13,
          color: F1Colors.textSecondary,
        ),
      );
    }

    return Text(
      '-',
      style: F1TextStyles.lapTimeSmall.copyWith(
        fontSize: 14,
        color: F1Colors.textTertiary,
      ),
    );
  }

  Widget _buildPositionChangeIndicator() {
    final isPositive = positionsGained! > 0;
    final color = isPositive ? F1Colors.success : F1Colors.vermelho;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPositive ? Icons.arrow_upward : Icons.arrow_downward,
            size: 11,
            color: color,
          ),
          const SizedBox(width: 2),
          Text(
            '${positionsGained!.abs()}',
            style: F1TextStyles.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
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
