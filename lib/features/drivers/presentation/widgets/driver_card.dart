import 'package:flutter/material.dart';
import '../../../../core/theme/f1_colors.dart';
import '../../../../core/theme/f1_text_styles.dart';
import '../../../../shared/widgets/driver_avatar.dart';
import '../../../../shared/widgets/team_color_strip.dart';
import '../../data/models/driver.dart';

/// Card widget for displaying driver information in a grid
class DriverCard extends StatelessWidget {
  final Driver driver;
  final VoidCallback? onTap;

  const DriverCard({
    super.key,
    required this.driver,
    this.onTap,
  });

  Color _getTeamColor() {
    try {
      final hex = driver.teamColour.startsWith('#')
          ? driver.teamColour
          : '#${driver.teamColour}';
      return Color(int.parse(hex.substring(1), radix: 16) + 0xFF000000);
    } catch (_) {
      return F1Colors.ciano;
    }
  }

  @override
  Widget build(BuildContext context) {
    final teamColor = _getTeamColor();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: F1Colors.navy,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: teamColor.withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: teamColor.withValues(alpha: 0.1),
              blurRadius: 12,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Team color strip on the left
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: TeamColorStrip(
                teamColor: driver.teamColour,
                width: 4,
              ),
            ),

            // Card content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Large driver avatar with team color border
                  DriverAvatar(
                    imageUrl: driver.headshotUrl,
                    teamColor: driver.teamColour,
                    driverName: driver.fullName,
                    size: DriverAvatarSize.large,
                  ),

                  const SizedBox(height: 16),

                  // Huge driver number
                  Text(
                    driver.driverNumber.toString(),
                    style: F1TextStyles.driverNumber.copyWith(
                      fontSize: 48,
                      color: teamColor,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Driver name acronym
                  Text(
                    driver.nameAcronym,
                    style: F1TextStyles.headlineMedium,
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 4),

                  // Team name
                  Text(
                    driver.teamName,
                    style: F1TextStyles.bodySmall.copyWith(
                      color: F1Colors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Glow effect on hover (for web/desktop)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.0,
                    colors: [
                      teamColor.withValues(alpha: 0.0),
                      teamColor.withValues(alpha: 0.05),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact variant of driver card for list view
class DriverCardCompact extends StatelessWidget {
  final Driver driver;
  final VoidCallback? onTap;

  const DriverCardCompact({
    super.key,
    required this.driver,
    this.onTap,
  });

  Color _getTeamColor() {
    try {
      final hex = driver.teamColour.startsWith('#')
          ? driver.teamColour
          : '#${driver.teamColour}';
      return Color(int.parse(hex.substring(1), radix: 16) + 0xFF000000);
    } catch (_) {
      return F1Colors.ciano;
    }
  }

  @override
  Widget build(BuildContext context) {
    final teamColor = _getTeamColor();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: F1Colors.navy,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: teamColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Team color strip
            TeamColorStrip(
              teamColor: driver.teamColour,
              width: 4,
            ),

            const SizedBox(width: 12),

            // Driver avatar
            DriverAvatar(
              imageUrl: driver.headshotUrl,
              teamColor: driver.teamColour,
              driverName: driver.fullName,
              size: DriverAvatarSize.medium,
            ),

            const SizedBox(width: 16),

            // Driver info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    driver.fullName,
                    style: F1TextStyles.headlineSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    driver.teamName,
                    style: F1TextStyles.bodyMedium.copyWith(
                      color: F1Colors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Driver number
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                driver.driverNumber.toString(),
                style: F1TextStyles.driverNumber.copyWith(
                  fontSize: 36,
                  color: teamColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
