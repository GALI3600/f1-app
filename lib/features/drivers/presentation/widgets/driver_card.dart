import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/f1_colors.dart';
import '../../../../core/theme/f1_text_styles.dart';
import '../../data/models/driver.dart';

/// Card widget for displaying driver information in a grid
/// Premium F1 TV broadcast-style design with team colors and driver identification
class DriverCard extends StatelessWidget {
  final Driver driver;
  final VoidCallback? onTap;
  final bool isLandscapeCompact;
  final bool isSelected;

  const DriverCard({
    super.key,
    required this.driver,
    this.onTap,
    this.isLandscapeCompact = false,
    this.isSelected = false,
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

  Color? _getTeamColor2() {
    if (driver.teamColour2 == null) return null;
    try {
      final hex = driver.teamColour2!.startsWith('#')
          ? driver.teamColour2!
          : '#${driver.teamColour2}';
      return Color(int.parse(hex.substring(1), radix: 16) + 0xFF000000);
    } catch (_) {
      return null;
    }
  }

  Color? _getTeamColor3() {
    if (driver.teamColour3 == null) return null;
    try {
      final hex = driver.teamColour3!.startsWith('#')
          ? driver.teamColour3!
          : '#${driver.teamColour3}';
      return Color(int.parse(hex.substring(1), radix: 16) + 0xFF000000);
    } catch (_) {
      return null;
    }
  }

  /// Get driver-specific identification bar color
  /// Black bar for: Leclerc, Russell, Verstappen, Lindblad
  /// Yellow bar for everyone else
  Color _getDriverBarColor() {
    // Use driverId for reliable identification
    const blackBarDrivers = {
      'leclerc',        // Ferrari
      'russell',        // Mercedes
      'max_verstappen', // Red Bull
      'lindblad',       // Racing Bulls
    };

    if (driver.driverId != null && blackBarDrivers.contains(driver.driverId)) {
      return Colors.black;
    }

    return F1Colors.warning; // Yellow for most drivers
  }

  /// Get driver initials from full name
  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts[0].substring(0, parts[0].length.clamp(0, 2)).toUpperCase();
    }
    final first = parts.first.isNotEmpty ? parts.first[0] : '';
    final last = parts.last.isNotEmpty ? parts.last[0] : '';
    return '$first$last'.toUpperCase();
  }

  /// Build gradient colors list for team
  List<Color> _buildGradientColors() {
    final teamColor = _getTeamColor();
    final teamColor2 = _getTeamColor2();
    final teamColor3 = _getTeamColor3();

    // If we have 3 colors (like Haas: white, black, red)
    if (teamColor2 != null && teamColor3 != null) {
      return [teamColor, teamColor2, teamColor3];
    }

    // If we have 2 colors
    if (teamColor2 != null) {
      return [teamColor, teamColor2];
    }

    // Default: primary color to darker variant
    final darkerColor = HSLColor.fromColor(teamColor)
        .withLightness((HSLColor.fromColor(teamColor).lightness * 0.6).clamp(0.0, 1.0))
        .toColor();
    return [teamColor, darkerColor];
  }

  @override
  Widget build(BuildContext context) {
    final teamColor = _getTeamColor();
    final gradientColors = _buildGradientColors();
    final gradientEndColor = gradientColors.last;

    // Use horizontal layout for landscape compact mode
    if (isLandscapeCompact) {
      return _buildLandscapeCompactCard(teamColor, gradientEndColor);
    }

    return _buildStandardCard(teamColor, gradientEndColor);
  }

  /// Horizontal layout for landscape compact mode - photo on left, info on right
  Widget _buildLandscapeCompactCard(Color teamColor, Color darkerTeamColor) {
    final barColor = _getDriverBarColor();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: isSelected
              ? Border.all(
                  color: F1Colors.ciano,
                  width: 3,
                )
              : null,
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: F1Colors.ciano.withValues(alpha: 0.5),
                blurRadius: 12,
                spreadRadius: 0,
              ),
            BoxShadow(
              color: teamColor.withValues(alpha: 0.3),
              blurRadius: 8,
              spreadRadius: -2,
              offset: const Offset(0, 3),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background gradient
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: _buildGradientColors(),
                  ),
                ),
              ),
            ),

            // Main content - column with bar on top, then horizontal layout
            Column(
              children: [
                // Team color space above bar
                const SizedBox(height: 6),

                // Yellow bar (not at the very top)
                Container(
                  height: 10,
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  decoration: BoxDecoration(
                    color: barColor,
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),

                // Horizontal layout for photo and info
                Expanded(
                  child: Row(
                    children: [
                      // Driver photo - takes left portion (increased)
                      Expanded(
                        flex: 5,
                        child: driver.headshotUrl != null && driver.headshotUrl!.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: driver.headshotUrl!,
                                fit: BoxFit.cover,
                                alignment: Alignment.topCenter,
                                placeholder: (context, url) => _buildPhotoPlaceholder(teamColor),
                                errorWidget: (context, url, error) => _buildPhotoPlaceholder(teamColor),
                              )
                            : _buildPhotoPlaceholder(teamColor),
                      ),

                      // Driver info - right portion
                      Expanded(
                        flex: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Driver number - large and bold
                              Text(
                                driver.driverNumber.toString(),
                                style: F1TextStyles.driverNumber.copyWith(
                                  fontSize: 38,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  height: 1.0,
                                ),
                              ),

                              const SizedBox(height: 2),

                              // Driver last name
                              Text(
                                driver.lastName.toUpperCase(),
                                style: F1TextStyles.headlineMedium.copyWith(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                  height: 1.1,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),

                              const SizedBox(height: 3),

                              // Team name pill
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.25),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: Text(
                                  driver.teamName.toUpperCase(),
                                  style: F1TextStyles.bodySmall.copyWith(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.3,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Border overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Standard vertical layout for portrait mode
  Widget _buildStandardCard(Color teamColor, Color darkerTeamColor) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            // Colored glow effect
            BoxShadow(
              color: teamColor.withValues(alpha: 0.4),
              blurRadius: 16,
              spreadRadius: -2,
              offset: const Offset(0, 6),
            ),
            // Dark shadow for depth
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 12,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background gradient
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: _buildGradientColors(),
                  ),
                ),
              ),
            ),

            // Diagonal accent stripe
            Positioned(
              right: -20,
              top: 40,
              child: Transform.rotate(
                angle: 0.4,
                child: Container(
                  width: 60,
                  height: 200,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.08),
                        Colors.white.withValues(alpha: 0.02),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Main content
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top spacing with team color visible
                const SizedBox(height: 8),

                // F1 TV identification bar - above photo (driver-specific color)
                Builder(
                  builder: (context) {
                    final barColor = _getDriverBarColor();
                    return Container(
                      height: 18,
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            barColor,
                            barColor.withValues(alpha: 0.9),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.4),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                // Driver photo with gradient overlay
                Expanded(
                  flex: 4,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Photo
                      driver.headshotUrl != null && driver.headshotUrl!.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: driver.headshotUrl!,
                              fit: BoxFit.cover,
                              alignment: Alignment.topCenter,
                              placeholder: (context, url) => _buildPhotoPlaceholder(teamColor),
                              errorWidget: (context, url, error) => _buildPhotoPlaceholder(teamColor),
                            )
                          : _buildPhotoPlaceholder(teamColor),

                      // Gradient overlay for depth
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              stops: const [0.0, 0.1, 0.7, 1.0],
                              colors: [
                                Colors.black.withValues(alpha: 0.2),
                                Colors.transparent,
                                Colors.transparent,
                                darkerTeamColor.withValues(alpha: 0.9),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Vignette effect
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              center: Alignment.center,
                              radius: 1.0,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.15),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Driver info section with number
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        darkerTeamColor,
                        darkerTeamColor.withValues(alpha: 0.95),
                      ],
                    ),
                  ),
                  child: Row(
                    children: [
                      // Driver number - left side
                      Text(
                        driver.driverNumber.toString(),
                        style: F1TextStyles.driverNumber.copyWith(
                          fontSize: 44,
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          shadows: [
                            Shadow(
                              color: teamColor.withValues(alpha: 0.5),
                              blurRadius: 8,
                            ),
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.5),
                              blurRadius: 4,
                              offset: const Offset(1, 1),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 10),

                      // Driver name and team - right side
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Driver last name
                            Text(
                              driver.lastName.toUpperCase(),
                              style: F1TextStyles.headlineMedium.copyWith(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withValues(alpha: 0.4),
                                    blurRadius: 2,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),

                            const SizedBox(height: 3),

                            // Team name
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: Text(
                                driver.teamName.toUpperCase(),
                                style: F1TextStyles.bodySmall.copyWith(
                                  color: Colors.white.withValues(alpha: 0.85),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Subtle border overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoPlaceholder(Color teamColor) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            teamColor.withValues(alpha: 0.5),
            teamColor.withValues(alpha: 0.8),
          ],
        ),
      ),
      child: Center(
        child: Text(
          _getInitials(driver.fullName),
          style: F1TextStyles.headlineLarge.copyWith(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 48,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

/// Compact variant of driver card for list view
/// Premium F1 TV broadcast-style design with team colors
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

  Color? _getTeamColor2() {
    if (driver.teamColour2 == null) return null;
    try {
      final hex = driver.teamColour2!.startsWith('#')
          ? driver.teamColour2!
          : '#${driver.teamColour2}';
      return Color(int.parse(hex.substring(1), radix: 16) + 0xFF000000);
    } catch (_) {
      return null;
    }
  }

  Color? _getTeamColor3() {
    if (driver.teamColour3 == null) return null;
    try {
      final hex = driver.teamColour3!.startsWith('#')
          ? driver.teamColour3!
          : '#${driver.teamColour3}';
      return Color(int.parse(hex.substring(1), radix: 16) + 0xFF000000);
    } catch (_) {
      return null;
    }
  }

  List<Color> _buildGradientColors() {
    final teamColor = _getTeamColor();
    final teamColor2 = _getTeamColor2();
    final teamColor3 = _getTeamColor3();

    if (teamColor2 != null && teamColor3 != null) {
      return [teamColor, teamColor2, teamColor3];
    }
    if (teamColor2 != null) {
      return [teamColor, teamColor2];
    }
    final darkerColor = HSLColor.fromColor(teamColor)
        .withLightness((HSLColor.fromColor(teamColor).lightness * 0.6).clamp(0.0, 1.0))
        .toColor();
    return [teamColor, darkerColor];
  }

  /// Get driver-specific identification bar color
  /// Black bar for: Leclerc, Russell, Verstappen, Lindblad
  /// Yellow bar for everyone else
  Color _getDriverBarColor() {
    const blackBarDrivers = {
      'leclerc',        // Ferrari
      'russell',        // Mercedes
      'max_verstappen', // Red Bull
      'lindblad',       // Racing Bulls
    };

    if (driver.driverId != null && blackBarDrivers.contains(driver.driverId)) {
      return Colors.black;
    }

    return F1Colors.warning; // Yellow for most drivers
  }

  /// Get driver initials from full name
  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts[0].substring(0, parts[0].length.clamp(0, 2)).toUpperCase();
    }
    final first = parts.first.isNotEmpty ? parts.first[0] : '';
    final last = parts.last.isNotEmpty ? parts.last[0] : '';
    return '$first$last'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final teamColor = _getTeamColor();
    final gradientColors = _buildGradientColors();
    final darkerTeamColor = gradientColors.last;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            // Colored glow
            BoxShadow(
              color: teamColor.withValues(alpha: 0.3),
              blurRadius: 12,
              spreadRadius: -2,
              offset: const Offset(0, 4),
            ),
            // Dark shadow
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background gradient
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: _buildGradientColors(),
                  ),
                ),
              ),
            ),

            // Diagonal accent
            Positioned(
              right: 40,
              top: -30,
              child: Transform.rotate(
                angle: 0.3,
                child: Container(
                  width: 40,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.06),
                        Colors.white.withValues(alpha: 0.01),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Card content
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  // Square driver photo with yellow bar on top
                  Stack(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: driver.headshotUrl != null && driver.headshotUrl!.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: driver.headshotUrl!,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => _buildPhotoPlaceholder(teamColor),
                                  errorWidget: (context, url, error) => _buildPhotoPlaceholder(teamColor),
                                )
                              : _buildPhotoPlaceholder(teamColor),
                        ),
                      ),
                      // Identification bar on top of photo (driver-specific color)
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 15,
                          decoration: BoxDecoration(
                            color: _getDriverBarColor(),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(6),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 3,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(width: 12),

                  // Driver number
                  Text(
                    driver.driverNumber.toString(),
                    style: F1TextStyles.driverNumber.copyWith(
                      fontSize: 40,
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      shadows: [
                        Shadow(
                          color: teamColor.withValues(alpha: 0.4),
                          blurRadius: 6,
                        ),
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.5),
                          blurRadius: 4,
                          offset: const Offset(1, 1),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Driver info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          driver.lastName.toUpperCase(),
                          style: F1TextStyles.headlineSmall.copyWith(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                            shadows: [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.4),
                                blurRadius: 2,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Text(
                            driver.teamName.toUpperCase(),
                            style: F1TextStyles.bodyMedium.copyWith(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Border overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.08),
                    width: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoPlaceholder(Color teamColor) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            teamColor.withValues(alpha: 0.4),
            teamColor.withValues(alpha: 0.7),
          ],
        ),
      ),
      child: Center(
        child: Text(
          _getInitials(driver.fullName),
          style: F1TextStyles.headlineSmall.copyWith(
            color: Colors.white.withValues(alpha: 0.6),
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}
