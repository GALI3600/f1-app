import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

/// Utilities for improving accessibility throughout the app
///
/// Provides helper functions and widgets to enhance accessibility
/// for screen readers, keyboard navigation, and other assistive technologies.
///
/// All interactive elements should meet WCAG AA standards:
/// - Touch targets: ≥ 48x48dp
/// - Color contrast: ≥ 4.5:1
/// - Semantic labels on all interactive elements
class AccessibilityUtils {
  AccessibilityUtils._();

  /// Minimum touch target size (48x48dp per Material Design guidelines)
  static const double minTouchTarget = 48.0;

  /// Wrap a widget to ensure minimum touch target size
  ///
  /// Use this for small interactive elements like icons to ensure
  /// they meet accessibility guidelines.
  static Widget ensureTouchTarget(
    Widget child, {
    double minSize = minTouchTarget,
  }) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: minSize,
        minHeight: minSize,
      ),
      child: child,
    );
  }

  /// Create a semantic wrapper with label and hint
  ///
  /// Use this to add accessibility labels to custom widgets.
  static Widget semanticWrapper({
    required Widget child,
    required String label,
    String? hint,
    String? value,
    bool isButton = false,
    bool isLink = false,
    bool isHeader = false,
    bool isImage = false,
    bool excludeSemantics = false,
    VoidCallback? onTap,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      value: value,
      button: isButton,
      link: isLink,
      header: isHeader,
      image: isImage,
      excludeSemantics: excludeSemantics,
      onTap: onTap,
      child: child,
    );
  }

  /// Announce a message to screen readers
  ///
  /// Use this to notify users of important state changes that
  /// aren't immediately visible.
  static void announce(
    BuildContext context,
    String message, {
    TextDirection textDirection = TextDirection.ltr,
  }) {
    SemanticsService.announce(
      message,
      textDirection,
    );
  }

  /// Create a tooltip with accessible label
  ///
  /// Use this for icon buttons and other elements that need
  /// additional context.
  static Widget tooltip({
    required Widget child,
    required String message,
    String? semanticLabel,
  }) {
    return Tooltip(
      message: message,
      preferBelow: false,
      child: Semantics(
        label: semanticLabel ?? message,
        child: child,
      ),
    );
  }

  /// Check if color contrast meets WCAG AA standards
  ///
  /// Returns true if contrast ratio is ≥ 4.5:1
  static bool hasGoodContrast(Color foreground, Color background) {
    final fgLuminance = foreground.computeLuminance();
    final bgLuminance = background.computeLuminance();

    final lighter = fgLuminance > bgLuminance ? fgLuminance : bgLuminance;
    final darker = fgLuminance > bgLuminance ? bgLuminance : fgLuminance;

    final contrastRatio = (lighter + 0.05) / (darker + 0.05);
    return contrastRatio >= 4.5;
  }

  /// Format a lap time for screen readers
  ///
  /// Converts "1:23.456" to "1 minute 23.456 seconds"
  static String formatLapTimeForScreenReader(String lapTime) {
    final parts = lapTime.split(':');
    if (parts.length == 2) {
      final minutes = parts[0];
      final seconds = parts[1];
      return '$minutes minute${minutes == '1' ? '' : 's'} $seconds seconds';
    }
    return lapTime;
  }

  /// Format a position for screen readers
  ///
  /// Converts "1" to "1st", "2" to "2nd", etc.
  static String formatPositionForScreenReader(int position) {
    final suffix = switch (position) {
      1 => 'st',
      2 => 'nd',
      3 => 'rd',
      _ => 'th',
    };
    return '$position$suffix position';
  }

  /// Format a driver name for screen readers
  ///
  /// Includes full name and team
  static String formatDriverForScreenReader({
    required String driverName,
    required String teamName,
    int? position,
  }) {
    final positionText = position != null
        ? '${formatPositionForScreenReader(position)}, '
        : '';
    return '$positionText$driverName, $teamName';
  }

  /// Create an accessible card with semantic labels
  static Widget accessibleCard({
    required Widget child,
    required String label,
    String? hint,
    VoidCallback? onTap,
    Color? backgroundColor,
    EdgeInsets? padding,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      button: onTap != null,
      onTap: onTap,
      child: Card(
        color: backgroundColor,
        child: Padding(
          padding: padding ?? const EdgeInsets.all(16.0),
          child: child,
        ),
      ),
    );
  }

  /// Create an accessible icon button
  static Widget accessibleIconButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    Color? color,
    double? size,
    String? tooltip,
  }) {
    return Semantics(
      label: label,
      button: true,
      enabled: true,
      child: Tooltip(
        message: tooltip ?? label,
        child: IconButton(
          icon: Icon(icon),
          onPressed: onPressed,
          color: color,
          iconSize: size ?? 24,
        ),
      ),
    );
  }

  /// Create an accessible list tile
  static Widget accessibleListTile({
    required Widget title,
    Widget? subtitle,
    Widget? leading,
    Widget? trailing,
    required String semanticLabel,
    String? semanticHint,
    VoidCallback? onTap,
  }) {
    return Semantics(
      label: semanticLabel,
      hint: semanticHint,
      button: onTap != null,
      onTap: onTap,
      child: ListTile(
        title: title,
        subtitle: subtitle,
        leading: leading,
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }

  /// Exclude a widget from semantics tree
  ///
  /// Use this for purely decorative elements that would
  /// clutter the accessibility experience.
  static Widget excludeSemantics(Widget child) {
    return ExcludeSemantics(child: child);
  }

  /// Merge semantics of child widgets
  ///
  /// Use this to combine multiple semantic nodes into one.
  static Widget mergeSemantics(Widget child) {
    return MergeSemantics(child: child);
  }

  /// Create a custom semantic label for complex widgets
  static Widget customSemantics({
    required Widget child,
    String? label,
    String? value,
    String? hint,
    String? increasedValue,
    String? decreasedValue,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
    VoidCallback? onIncrease,
    VoidCallback? onDecrease,
    bool isButton = false,
    bool isSlider = false,
    bool isHeader = false,
  }) {
    return Semantics(
      label: label,
      value: value,
      hint: hint,
      increasedValue: increasedValue,
      decreasedValue: decreasedValue,
      onTap: onTap,
      onLongPress: onLongPress,
      onIncrease: onIncrease,
      onDecrease: onDecrease,
      button: isButton,
      slider: isSlider,
      header: isHeader,
      child: child,
    );
  }
}
