import 'package:flutter/material.dart';
import 'package:f1sync/core/theme/f1_colors.dart';

/// F1-themed team color strip
///
/// Displays a vertical strip with team color, typically on the leading edge of cards.
///
/// Usage:
/// ```dart
/// Row(
///   children: [
///     TeamColorStrip(teamColor: driver.teamColour),
///     Expanded(child: content),
///   ],
/// )
/// ```
class TeamColorStrip extends StatelessWidget {
  /// Team color hex (without #)
  final String teamColor;

  /// Width of the strip
  final double width;

  /// Height of the strip (null = match parent)
  final double? height;

  /// Border radius (applied to the strip)
  final BorderRadius? borderRadius;

  /// Whether to add a glow effect
  final bool showGlow;

  const TeamColorStrip({
    super.key,
    required this.teamColor,
    this.width = 4.0,
    this.height,
    this.borderRadius,
    this.showGlow = false,
  });

  /// Thin strip (2px)
  const TeamColorStrip.thin({
    super.key,
    required this.teamColor,
    this.height,
    this.borderRadius,
    this.showGlow = false,
  }) : width = 2.0;

  /// Medium strip (4px) - default
  const TeamColorStrip.medium({
    super.key,
    required this.teamColor,
    this.height,
    this.borderRadius,
    this.showGlow = false,
  }) : width = 4.0;

  /// Thick strip (6px)
  const TeamColorStrip.thick({
    super.key,
    required this.teamColor,
    this.height,
    this.borderRadius,
    this.showGlow = false,
  }) : width = 6.0;

  /// Strip with glow effect
  const TeamColorStrip.withGlow({
    super.key,
    required this.teamColor,
    this.width = 4.0,
    this.height,
    this.borderRadius,
  }) : showGlow = true;

  @override
  Widget build(BuildContext context) {
    final color = _parseTeamColor(teamColor);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: borderRadius,
        boxShadow: showGlow
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.5),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
    );
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
}

/// Horizontal team color strip
///
/// Displays a horizontal strip with team color, typically at the top or bottom of cards.
class HorizontalTeamColorStrip extends StatelessWidget {
  /// Team color hex (without #)
  final String teamColor;

  /// Height of the strip
  final double height;

  /// Width of the strip (null = match parent)
  final double? width;

  /// Border radius (applied to the strip)
  final BorderRadius? borderRadius;

  /// Whether to add a glow effect
  final bool showGlow;

  const HorizontalTeamColorStrip({
    super.key,
    required this.teamColor,
    this.height = 4.0,
    this.width,
    this.borderRadius,
    this.showGlow = false,
  });

  /// Thin strip (2px)
  const HorizontalTeamColorStrip.thin({
    super.key,
    required this.teamColor,
    this.width,
    this.borderRadius,
    this.showGlow = false,
  }) : height = 2.0;

  /// Medium strip (4px) - default
  const HorizontalTeamColorStrip.medium({
    super.key,
    required this.teamColor,
    this.width,
    this.borderRadius,
    this.showGlow = false,
  }) : height = 4.0;

  /// Thick strip (6px)
  const HorizontalTeamColorStrip.thick({
    super.key,
    required this.teamColor,
    this.width,
    this.borderRadius,
    this.showGlow = false,
  }) : height = 6.0;

  @override
  Widget build(BuildContext context) {
    final color = _parseTeamColor(teamColor);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: borderRadius,
        boxShadow: showGlow
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.5),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
    );
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
}

/// Team color card
///
/// A card with team color strip on the leading edge.
class TeamColorCard extends StatelessWidget {
  /// Team color hex (without #)
  final String teamColor;

  /// The card content
  final Widget child;

  /// Card padding
  final EdgeInsetsGeometry? padding;

  /// Card margin
  final EdgeInsetsGeometry? margin;

  /// Border radius
  final double borderRadius;

  /// Strip width
  final double stripWidth;

  /// Background color
  final Color? backgroundColor;

  /// Whether to show shadow
  final bool showShadow;

  /// On tap callback
  final VoidCallback? onTap;

  const TeamColorCard({
    super.key,
    required this.teamColor,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 12.0,
    this.stripWidth = 4.0,
    this.backgroundColor,
    this.showShadow = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectivePadding = padding ?? const EdgeInsets.all(16.0);
    final effectiveBackgroundColor = backgroundColor ?? F1Colors.navy;

    Widget card = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: effectiveBackgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TeamColorStrip(
              teamColor: teamColor,
              width: stripWidth,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(borderRadius),
                bottomLeft: Radius.circular(borderRadius),
              ),
            ),
            Expanded(
              child: Padding(
                padding: effectivePadding,
                child: child,
              ),
            ),
          ],
        ),
      ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: card,
        ),
      );
    }

    return card;
  }
}

/// Team color divider
///
/// A divider with team color, useful for separating sections.
class TeamColorDivider extends StatelessWidget {
  /// Team color hex (without #)
  final String teamColor;

  /// Thickness of the divider
  final double thickness;

  /// Indent from the start
  final double indent;

  /// Indent from the end
  final double endIndent;

  const TeamColorDivider({
    super.key,
    required this.teamColor,
    this.thickness = 1.0,
    this.indent = 0.0,
    this.endIndent = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    final color = _parseTeamColor(teamColor);

    return Divider(
      color: color,
      thickness: thickness,
      indent: indent,
      endIndent: endIndent,
    );
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
}
