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
  final bool isLandscape;
  final bool isPanelMode;

  const DriverProfileHeader({
    super.key,
    required this.driver,
    this.height = 300,
    this.isLandscape = false,
    this.isPanelMode = false,
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

  List<Color> _buildGradientColors(Color teamColor, {bool withNavyEnd = true}) {
    final teamColor2 = _getTeamColor2();
    final teamColor3 = _getTeamColor3();

    if (teamColor2 != null && teamColor3 != null) {
      return withNavyEnd
          ? [teamColor.withValues(alpha: 0.8), teamColor2.withValues(alpha: 0.7), teamColor3.withValues(alpha: 0.6), F1Colors.navyDeep]
          : [teamColor, teamColor2, teamColor3];
    }
    if (teamColor2 != null) {
      return withNavyEnd
          ? [teamColor.withValues(alpha: 0.8), teamColor2.withValues(alpha: 0.6), F1Colors.navyDeep]
          : [teamColor, teamColor2];
    }
    return withNavyEnd
        ? [teamColor.withValues(alpha: 0.8), F1Colors.navyDeep]
        : [teamColor, teamColor.withValues(alpha: 0.7)];
  }

  List<double> _buildGradientStops() {
    final teamColor2 = _getTeamColor2();
    final teamColor3 = _getTeamColor3();

    if (teamColor2 != null && teamColor3 != null) {
      return const [0.0, 0.33, 0.66, 1.0];
    }
    if (teamColor2 != null) {
      return const [0.0, 0.5, 1.0];
    }
    return const [0.0, 1.0];
  }

  /// Returns a contrasting text color (white or dark) based on background luminance
  Color _contrastingTextColor(Color background) {
    return background.computeLuminance() > 0.5
        ? F1Colors.navyDeep
        : Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    final teamColor = _getTeamColor();
    final teamColor2 = _getTeamColor2();

    if (isPanelMode) {
      return _buildPanelLayout(teamColor, teamColor2);
    }
    if (isLandscape) {
      return _buildLandscapeLayout(teamColor, teamColor2);
    }
    return _buildPortraitLayout(teamColor, teamColor2);
  }

  Widget _buildPortraitLayout(Color teamColor, [Color? teamColor2]) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: _buildGradientColors(teamColor),
          stops: _buildGradientStops(),
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
                      color: _contrastingTextColor(teamColor),
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

  Widget _buildPanelLayout(Color teamColor, [Color? teamColor2]) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: teamColor2 != null
              ? [teamColor.withValues(alpha: 0.9), teamColor2.withValues(alpha: 0.7), F1Colors.navyDeep]
              : [teamColor.withValues(alpha: 0.9), teamColor.withValues(alpha: 0.6), F1Colors.navyDeep],
          stops: const [0.0, 0.4, 1.0],
        ),
      ),
      child: Row(
        children: [
          // Driver headshot - left side
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                // Photo
                if (driver.headshotUrl != null)
                  Positioned.fill(
                    child: Hero(
                      tag: 'driver_panel_${driver.driverNumber}',
                      child: CachedNetworkImage(
                        imageUrl: driver.headshotUrl!,
                        fit: BoxFit.contain,
                        alignment: Alignment.bottomCenter,
                        placeholder: (context, url) => const SizedBox.shrink(),
                        errorWidget: (context, url, error) => const SizedBox.shrink(),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Driver info - right side
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Driver number badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: teamColor,
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      driver.driverNumber.toString(),
                      style: F1TextStyles.driverNumber.copyWith(
                        fontSize: 28,
                        color: _contrastingTextColor(teamColor),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Full name
                  Text(
                    driver.fullName.toUpperCase(),
                    style: F1TextStyles.displayMedium.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.5),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // Team name
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      driver.teamName.toUpperCase(),
                      style: F1TextStyles.bodySmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                        letterSpacing: 0.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Country flag
                  if (driver.countryCode != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _getCountryFlag(driver.countryCode!),
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          driver.countryCode!,
                          style: F1TextStyles.bodySmall.copyWith(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLandscapeLayout(Color teamColor, [Color? teamColor2]) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: teamColor2 != null
              ? [teamColor.withValues(alpha: 0.9), teamColor2.withValues(alpha: 0.7), F1Colors.navyDeep]
              : [teamColor.withValues(alpha: 0.9), teamColor.withValues(alpha: 0.6), F1Colors.navyDeep],
          stops: const [0.0, 0.5, 1.0],
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

          // Driver headshot - centered and larger in landscape
          if (driver.headshotUrl != null)
            Positioned.fill(
              child: Hero(
                tag: 'driver_${driver.driverNumber}',
                child: CachedNetworkImage(
                  imageUrl: driver.headshotUrl!,
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                  placeholder: (context, url) => const SizedBox.shrink(),
                  errorWidget: (context, url, error) => const SizedBox.shrink(),
                ),
              ),
            ),

          // Gradient overlay for text readability
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.transparent,
                    F1Colors.navyDeep.withValues(alpha: 0.8),
                    F1Colors.navyDeep.withValues(alpha: 0.95),
                  ],
                  stops: const [0.0, 0.4, 0.7, 1.0],
                ),
              ),
            ),
          ),

          // Driver information - bottom aligned in landscape
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Driver number with team color
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: teamColor,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    driver.driverNumber.toString(),
                    style: F1TextStyles.driverNumber.copyWith(
                      fontSize: 36,
                      color: _contrastingTextColor(teamColor),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Full name - centered
                Text(
                  driver.fullName.toUpperCase(),
                  style: F1TextStyles.displayMedium.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 8),

                // Team name - centered with pill background
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: teamColor.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    driver.teamName.toUpperCase(),
                    style: F1TextStyles.bodyMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                ),

                // Country flag
                if (driver.countryCode != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _getCountryFlag(driver.countryCode!),
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        driver.countryCode!,
                        style: F1TextStyles.bodySmall.copyWith(
                          color: F1Colors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Mapping from ISO 3166-1 alpha-3 to alpha-2 country codes
  static const _countryCodeMap = {
    // F1 relevant countries
    'ARG': 'AR', // Argentina
    'AUS': 'AU', // Australia
    'AUT': 'AT', // Austria
    'BEL': 'BE', // Belgium
    'BRA': 'BR', // Brazil
    'CAN': 'CA', // Canada
    'CHN': 'CN', // China
    'COL': 'CO', // Colombia
    'DEN': 'DK', // Denmark
    'FIN': 'FI', // Finland
    'FRA': 'FR', // France
    'GBR': 'GB', // Great Britain
    'GER': 'DE', // Germany
    'HUN': 'HU', // Hungary
    'IND': 'IN', // India
    'IRL': 'IE', // Ireland
    'ITA': 'IT', // Italy
    'JPN': 'JP', // Japan
    'MEX': 'MX', // Mexico
    'MON': 'MC', // Monaco
    'NED': 'NL', // Netherlands
    'NZL': 'NZ', // New Zealand
    'POL': 'PL', // Poland
    'POR': 'PT', // Portugal
    'RSA': 'ZA', // South Africa
    'RUS': 'RU', // Russia
    'ESP': 'ES', // Spain
    'SUI': 'CH', // Switzerland
    'SWE': 'SE', // Sweden
    'THA': 'TH', // Thailand
    'UAE': 'AE', // United Arab Emirates
    'USA': 'US', // United States
    'VEN': 'VE', // Venezuela
  };

  /// Get country flag emoji from country code
  String _getCountryFlag(String countryCode) {
    // Convert country code to flag emoji
    // Each letter is converted to regional indicator symbol
    var code = countryCode.toUpperCase();

    // Convert 3-letter code to 2-letter code if needed
    if (code.length == 3) {
      code = _countryCodeMap[code] ?? code.substring(0, 2);
    }

    if (code.length != 2) return '🏁';

    try {
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
                  color: teamColor.computeLuminance() > 0.5
                      ? F1Colors.navyDeep
                      : Colors.white,
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
