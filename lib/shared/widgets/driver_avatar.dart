import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:f1sync/core/theme/f1_colors.dart';
import 'package:f1sync/core/theme/f1_text_styles.dart';

/// F1-themed driver avatar with team color border
///
/// Displays a circular driver avatar with a team-colored border.
/// Uses CachedNetworkImage for efficient image loading.
///
/// Usage:
/// ```dart
/// DriverAvatar(
///   imageUrl: driver.headshotUrl,
///   teamColor: driver.teamColour,
///   driverName: driver.fullName,
/// )
/// ```
class DriverAvatar extends StatelessWidget {
  /// URL of the driver headshot image
  final String? imageUrl;

  /// Team color hex (without #)
  final String teamColor;

  /// Driver name (used for initials if no image)
  final String driverName;

  /// Size of the avatar
  final DriverAvatarSize size;

  /// Custom size (overrides size enum)
  final double? customSize;

  /// Border width (defaults to 3px)
  final double borderWidth;

  /// Whether to show a loading placeholder
  final bool showPlaceholder;

  /// Custom placeholder widget
  final Widget? placeholder;

  /// On tap callback
  final VoidCallback? onTap;

  const DriverAvatar({
    super.key,
    this.imageUrl,
    required this.teamColor,
    required this.driverName,
    this.size = DriverAvatarSize.medium,
    this.customSize,
    this.borderWidth = 3.0,
    this.showPlaceholder = true,
    this.placeholder,
    this.onTap,
  });

  /// Small avatar (48px)
  const DriverAvatar.small({
    super.key,
    this.imageUrl,
    required this.teamColor,
    required this.driverName,
    this.borderWidth = 2.5,
    this.showPlaceholder = true,
    this.placeholder,
    this.onTap,
  })  : size = DriverAvatarSize.small,
        customSize = null;

  /// Medium avatar (64px)
  const DriverAvatar.medium({
    super.key,
    this.imageUrl,
    required this.teamColor,
    required this.driverName,
    this.borderWidth = 3.0,
    this.showPlaceholder = true,
    this.placeholder,
    this.onTap,
  })  : size = DriverAvatarSize.medium,
        customSize = null;

  /// Large avatar (96px)
  const DriverAvatar.large({
    super.key,
    this.imageUrl,
    required this.teamColor,
    required this.driverName,
    this.borderWidth = 4.0,
    this.showPlaceholder = true,
    this.placeholder,
    this.onTap,
  })  : size = DriverAvatarSize.large,
        customSize = null;

  @override
  Widget build(BuildContext context) {
    final avatarSize = customSize ?? _getSize(size);
    final teamBorderColor = _parseTeamColor(teamColor);
    final initials = _getInitials(driverName);

    Widget avatar = Container(
      width: avatarSize,
      height: avatarSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: teamBorderColor,
          width: borderWidth,
        ),
        color: F1Colors.navy,
      ),
      child: ClipOval(
        child: imageUrl != null && imageUrl!.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: imageUrl!,
                fit: BoxFit.cover,
                placeholder: showPlaceholder
                    ? (context, url) =>
                        placeholder ?? _buildPlaceholder(initials, avatarSize)
                    : null,
                errorWidget: (context, url, error) =>
                    _buildPlaceholder(initials, avatarSize),
              )
            : _buildPlaceholder(initials, avatarSize),
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: avatar,
      );
    }

    return avatar;
  }

  /// Build placeholder with driver initials
  Widget _buildPlaceholder(String initials, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: F1Colors.navy,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials,
          style: _getTextStyle(size),
        ),
      ),
    );
  }

  /// Get avatar size based on enum
  double _getSize(DriverAvatarSize size) {
    switch (size) {
      case DriverAvatarSize.small:
        return 48.0;
      case DriverAvatarSize.medium:
        return 64.0;
      case DriverAvatarSize.large:
        return 96.0;
    }
  }

  /// Get text style for initials based on size
  TextStyle _getTextStyle(double size) {
    if (size >= 96) {
      return F1TextStyles.headlineMedium.copyWith(
        color: F1Colors.textPrimary,
        fontWeight: FontWeight.w800,
      );
    } else if (size >= 64) {
      return F1TextStyles.headlineSmall.copyWith(
        color: F1Colors.textPrimary,
        fontWeight: FontWeight.w800,
      );
    } else {
      return F1TextStyles.bodyLarge.copyWith(
        color: F1Colors.textPrimary,
        fontWeight: FontWeight.w700,
      );
    }
  }

  /// Parse team color from hex string
  Color _parseTeamColor(String hex) {
    try {
      // Remove # if present
      final cleanHex = hex.replaceAll('#', '');
      return Color(int.parse('FF$cleanHex', radix: 16));
    } catch (e) {
      // Fallback to cyan if parsing fails
      return F1Colors.textSecondary;
    }
  }

  /// Get driver initials from full name
  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';

    if (parts.length == 1) {
      // Single name, return first two characters
      return parts[0].substring(0, parts[0].length.clamp(0, 2)).toUpperCase();
    }

    // Multiple names, return first letter of first and last name
    final first = parts.first.isNotEmpty ? parts.first[0] : '';
    final last = parts.last.isNotEmpty ? parts.last[0] : '';
    return '$first$last'.toUpperCase();
  }
}

/// Driver avatar size options
enum DriverAvatarSize {
  /// Small size (48px)
  small,

  /// Medium size (64px)
  medium,

  /// Large size (96px)
  large,
}

/// Driver avatar with position badge
///
/// Displays a driver avatar with a position badge overlay.
class DriverAvatarWithPosition extends StatelessWidget {
  /// URL of the driver headshot image
  final String? imageUrl;

  /// Team color hex (without #)
  final String teamColor;

  /// Driver name (used for initials if no image)
  final String driverName;

  /// Driver position (P1, P2, etc)
  final int position;

  /// Size of the avatar
  final DriverAvatarSize size;

  /// Border width
  final double borderWidth;

  /// On tap callback
  final VoidCallback? onTap;

  const DriverAvatarWithPosition({
    super.key,
    this.imageUrl,
    required this.teamColor,
    required this.driverName,
    required this.position,
    this.size = DriverAvatarSize.medium,
    this.borderWidth = 3.0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        DriverAvatar(
          imageUrl: imageUrl,
          teamColor: teamColor,
          driverName: driverName,
          size: size,
          borderWidth: borderWidth,
          onTap: onTap,
        ),
        Positioned(
          right: -4,
          bottom: -4,
          child: _buildPositionBadge(position),
        ),
      ],
    );
  }

  /// Build position badge
  Widget _buildPositionBadge(int position) {
    final badgeSize = _getBadgeSize(size);
    final backgroundColor = _getPositionColor(position);

    return Container(
      width: badgeSize,
      height: badgeSize,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: F1Colors.navyDeep,
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          'P$position',
          style: TextStyle(
            fontSize: badgeSize * 0.35,
            fontWeight: FontWeight.w900,
            color: position <= 3 ? F1Colors.navyDeep : F1Colors.textPrimary,
          ),
        ),
      ),
    );
  }

  /// Get badge size based on avatar size
  double _getBadgeSize(DriverAvatarSize size) {
    switch (size) {
      case DriverAvatarSize.small:
        return 20.0;
      case DriverAvatarSize.medium:
        return 24.0;
      case DriverAvatarSize.large:
        return 32.0;
    }
  }

  /// Get position badge color
  Color _getPositionColor(int position) {
    return F1Colors.getPositionColor(position);
  }
}
