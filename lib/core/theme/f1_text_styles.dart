import 'package:flutter/material.dart';
import 'package:f1sync/core/theme/f1_colors.dart';

/// F1Sync Typography System
/// Hierarchical text styles for consistent typography
class F1TextStyles {
  F1TextStyles._();

  // Base font family
  static const String _fontFamily = 'Roboto';
  static const String _monoFontFamily = 'RobotoMono';

  // ========== Display Styles ==========

  /// Display Large - 48px, Extra Bold
  /// Usage: Splash screens, hero headers
  static const TextStyle displayLarge = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.w900,
    color: F1Colors.textPrimary,
    letterSpacing: -0.5,
    fontFamily: _fontFamily,
    height: 1.1,
  );

  /// Display Medium - 36px, Extra Bold
  /// Usage: Major section headers
  static const TextStyle displayMedium = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w800,
    color: F1Colors.textPrimary,
    fontFamily: _fontFamily,
    height: 1.2,
  );

  /// Display Small - 28px, Bold
  /// Usage: Screen titles, modal headers
  static const TextStyle displaySmall = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: F1Colors.textPrimary,
    fontFamily: _fontFamily,
    height: 1.2,
  );

  // ========== Headline Styles ==========

  /// Headline Large - 24px, Bold
  /// Usage: Section headers, card titles
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: F1Colors.textPrimary,
    fontFamily: _fontFamily,
    height: 1.3,
  );

  /// Headline Medium - 20px, Semi-Bold
  /// Usage: Subsection headers
  static const TextStyle headlineMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: F1Colors.textPrimary,
    fontFamily: _fontFamily,
    height: 1.3,
  );

  /// Headline Small - 18px, Semi-Bold
  /// Usage: Card headers, list headers
  static const TextStyle headlineSmall = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: F1Colors.textPrimary,
    fontFamily: _fontFamily,
    height: 1.4,
  );

  // ========== Body Styles ==========

  /// Body Large - 16px, Regular
  /// Usage: Main body text, descriptions
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: F1Colors.textPrimary,
    fontFamily: _fontFamily,
    height: 1.5,
  );

  /// Body Medium - 14px, Regular
  /// Usage: Secondary text, supporting information
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: F1Colors.textSecondary,
    fontFamily: _fontFamily,
    height: 1.5,
  );

  /// Body Small - 12px, Regular
  /// Usage: Captions, meta information
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: F1Colors.textDisabled,
    fontFamily: _fontFamily,
    height: 1.5,
  );

  // ========== Label Styles ==========

  /// Label Large - 14px, Medium
  /// Usage: Button text, form labels
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: F1Colors.textPrimary,
    fontFamily: _fontFamily,
    letterSpacing: 0.5,
  );

  /// Label Medium - 12px, Medium
  /// Usage: Small buttons, chips
  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: F1Colors.textPrimary,
    fontFamily: _fontFamily,
    letterSpacing: 0.5,
  );

  /// Label Small - 10px, Medium
  /// Usage: Tiny labels, badges
  static const TextStyle labelSmall = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: F1Colors.textPrimary,
    fontFamily: _fontFamily,
    letterSpacing: 0.5,
  );

  // ========== F1-Specific Styles ==========

  /// Driver Number - 64px, Extra Bold, Monospace
  /// Usage: Driver number displays
  static const TextStyle driverNumber = TextStyle(
    fontSize: 64,
    fontWeight: FontWeight.w900,
    color: F1Colors.ciano,
    fontFamily: _monoFontFamily,
    letterSpacing: -2,
    height: 1.0,
  );

  /// Lap Time - 20px, Bold, Monospace
  /// Usage: Lap time displays
  static const TextStyle lapTime = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    fontFamily: _monoFontFamily,
    color: F1Colors.textPrimary,
    letterSpacing: 1,
  );

  /// Lap Time Small - 16px, Bold, Monospace
  /// Usage: Compact lap times in lists
  static const TextStyle lapTimeSmall = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    fontFamily: _monoFontFamily,
    color: F1Colors.textPrimary,
    letterSpacing: 0.5,
  );

  /// Position Number - 24px, Extra Bold
  /// Usage: Position displays (P1, P2, etc)
  static const TextStyle position = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w900,
    color: F1Colors.dourado,
    fontFamily: _fontFamily,
  );

  /// Position Small - 18px, Extra Bold
  /// Usage: Compact position displays
  static const TextStyle positionSmall = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w900,
    color: F1Colors.dourado,
    fontFamily: _fontFamily,
  );

  /// Team Name - 14px, Semi-Bold, Uppercase
  /// Usage: Team name displays
  static const TextStyle teamName = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: F1Colors.ciano,
    letterSpacing: 0.5,
    fontFamily: _fontFamily,
  );

  /// Driver Name - 16px, Bold
  /// Usage: Driver name displays
  static const TextStyle driverName = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: F1Colors.textPrimary,
    fontFamily: _fontFamily,
  );

  /// Driver Acronym - 14px, Extra Bold
  /// Usage: Driver 3-letter codes (VER, HAM, etc)
  static const TextStyle driverAcronym = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w800,
    color: F1Colors.textPrimary,
    fontFamily: _fontFamily,
    letterSpacing: 1,
  );

  /// Speed Display - 32px, Bold, Monospace
  /// Usage: Speed indicators
  static const TextStyle speed = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    fontFamily: _monoFontFamily,
    color: F1Colors.textPrimary,
  );

  /// Gap Time - 14px, Semi-Bold, Monospace
  /// Usage: Time gaps, intervals
  static const TextStyle gapTime = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    fontFamily: _monoFontFamily,
    color: F1Colors.textSecondary,
  );

  // ========== Special Styles ==========

  /// Live Indicator Text - 12px, Bold, Uppercase
  /// Usage: LIVE indicators
  static const TextStyle liveIndicator = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: F1Colors.textPrimary,
    letterSpacing: 1.5,
    fontFamily: _fontFamily,
  );

  /// Error Text - 14px, Medium
  /// Usage: Error messages
  static const TextStyle error = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: F1Colors.error,
    fontFamily: _fontFamily,
  );

  /// Success Text - 14px, Medium
  /// Usage: Success messages
  static const TextStyle success = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: F1Colors.success,
    fontFamily: _fontFamily,
  );

  // ========== Helper Methods ==========

  /// Apply color to a text style
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  /// Apply team color to a text style
  static TextStyle withTeamColor(TextStyle style, String teamColorHex) {
    final color = Color(int.parse('FF$teamColorHex', radix: 16));
    return style.copyWith(color: color);
  }

  /// Make text uppercase (for team names, etc)
  static TextStyle uppercase(TextStyle style) {
    // Note: Uppercase transformation should be done on the text string itself
    // This is just for semantic grouping
    return style.copyWith(letterSpacing: style.letterSpacing ?? 0.5);
  }

  /// Apply gradient to text (returns gradient shader)
  static Shader textGradient(Rect bounds, Gradient gradient) {
    return gradient.createShader(bounds);
  }
}
