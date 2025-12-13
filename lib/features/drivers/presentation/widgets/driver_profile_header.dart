import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/f1_colors.dart';
import '../../../../core/theme/f1_gradients.dart';
import '../../../../core/theme/f1_text_styles.dart';
import '../../data/models/driver.dart';

/// Profile header widget for driver detail screen
class DriverProfileHeader extends StatelessWidget {
  final Driver driver;
  final double height;

  const DriverProfileHeader({
    super.key,
    required this.driver,
    this.height = 300,
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

    return Container(
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            teamColor.withValues(alpha: 0.8),
            F1Colors.navyDeep,
          ],
          stops: const [0.0, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Background pattern/texture
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: Container(
                decoration: BoxDecoration(
                  gradient: F1Gradients.main,
                ),
              ),
            ),
          ),

          // Driver headshot
          if (driver.headshotUrl != null)
            Positioned(
              right: 0,
              bottom: 0,
              top: 40,
              child: Hero(
                tag: 'driver_${driver.driverNumber}',
                child: CachedNetworkImage(
                  imageUrl: driver.headshotUrl!,
                  fit: BoxFit.contain,
                  alignment: Alignment.bottomRight,
                  placeholder: (context, url) => const SizedBox.shrink(),
                  errorWidget: (context, url, error) => const SizedBox.shrink(),
                ),
              ),
            ),

          // Gradient overlay for text readability
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    F1Colors.navyDeep.withValues(alpha: 0.9),
                    F1Colors.navyDeep.withValues(alpha: 0.6),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),

          // Driver information
          Positioned(
            left: 24,
            right: 24,
            bottom: 32,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Driver number with team color
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: teamColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    driver.driverNumber.toString(),
                    style: F1TextStyles.driverNumber.copyWith(
                      fontSize: 32,
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Full name
                Text(
                  driver.fullName.toUpperCase(),
                  style: F1TextStyles.displayMedium.copyWith(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 8),

                // Team name
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 20,
                      decoration: BoxDecoration(
                        color: teamColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        driver.teamName,
                        style: F1TextStyles.headlineMedium.copyWith(
                          color: teamColor,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Country flag and code (only show if available)
                if (driver.countryCode != null)
                  Row(
                    children: [
                      // Country flag emoji (if we can construct it from country code)
                      Text(
                        _getCountryFlag(driver.countryCode!),
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        driver.countryCode!,
                        style: F1TextStyles.bodyLarge.copyWith(
                          color: F1Colors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Get country flag emoji from country code
  String _getCountryFlag(String countryCode) {
    // Convert country code to flag emoji
    // Each letter is converted to regional indicator symbol
    final code = countryCode.toUpperCase();
    if (code.length != 2 && code.length != 3) return '🏁';

    try {
      // Use first 2 letters for flag emoji
      final firstChar = code.codeUnitAt(0);
      final secondChar = code.codeUnitAt(1);

      // Regional indicator symbols start at U+1F1E6 (🇦)
      const regionalOffset = 0x1F1E6 - 0x41; // Offset from 'A'

      final flag = String.fromCharCodes([
        firstChar + regionalOffset,
        secondChar + regionalOffset,
      ]);

      return flag;
    } catch (_) {
      return '🏁'; // Fallback to checkered flag
    }
  }
}

/// Compact variant for smaller screens
class DriverProfileHeaderCompact extends StatelessWidget {
  final Driver driver;

  const DriverProfileHeaderCompact({
    super.key,
    required this.driver,
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

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            teamColor.withValues(alpha: 0.2),
            F1Colors.navy,
          ],
        ),
        border: Border(
          bottom: BorderSide(
            color: teamColor,
            width: 2,
          ),
        ),
      ),
      child: Row(
        children: [
          // Driver number badge
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: teamColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                driver.driverNumber.toString(),
                style: F1TextStyles.driverNumber.copyWith(
                  fontSize: 28,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Driver info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  driver.nameAcronym,
                  style: F1TextStyles.headlineLarge.copyWith(
                    color: teamColor,
                  ),
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
        ],
      ),
    );
  }
}
