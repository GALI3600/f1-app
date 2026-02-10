import 'package:flutter/material.dart';
import 'package:f1sync/core/theme/f1_colors.dart';

/// F1Sync Gradient System
/// Collection of reusable gradients for consistent visual design
class F1Gradients {
  F1Gradients._();

  // ========== Main Gradients ==========

  /// Full spectrum gradient (Cyan → Purple → Red → Gold)
  /// Usage: Special headers, splash screens, hero sections
  static const LinearGradient main = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      F1Colors.ciano,
      F1Colors.roxo,
      F1Colors.vermelho,
      F1Colors.dourado,
    ],
    stops: [0.0, 0.33, 0.66, 1.0],
  );

  /// Cyan to Purple gradient
  /// Usage: Primary app bar, primary buttons, main headers
  static const LinearGradient cianRoxo = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      F1Colors.ciano,
      F1Colors.roxo,
    ],
  );

  /// Purple to Red gradient
  /// Usage: CTAs, action buttons, FAB
  static const LinearGradient roxoVermelho = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      F1Colors.roxo,
      F1Colors.vermelho,
    ],
  );

  /// Red to Gold gradient
  /// Usage: Premium features, achievements, highlights
  static const LinearGradient vermelhoDourado = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      F1Colors.vermelho,
      F1Colors.dourado,
    ],
  );

  /// Subtle navy gradient
  /// Usage: Card backgrounds, subtle elevation
  static const LinearGradient navy = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      F1Colors.navy,
      F1Colors.navyDeep,
    ],
  );

  // ========== Specialized Gradients ==========

  /// Live indicator gradient (pulsing effect)
  /// Usage: Live session indicators
  static LinearGradient live = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      F1Colors.vermelho,
      F1Colors.vermelho.withValues(alpha: 0.6),
      F1Colors.vermelho,
    ],
    stops: const [0.0, 0.5, 1.0],
  );

  /// Loading shimmer gradient (animated)
  /// Usage: Skeleton loaders, loading states
  static const LinearGradient loading = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      F1Colors.navy,
      F1Colors.navyLight,
      F1Colors.navy,
    ],
    stops: [0.0, 0.5, 1.0],
  );

  /// Speed gradient (velocity indicator)
  /// Usage: Speed gauges, velocity displays
  static const LinearGradient speed = LinearGradient(
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
    colors: [
      F1Colors.ciano,
      F1Colors.roxo,
      F1Colors.vermelho,
    ],
    stops: [0.0, 0.5, 1.0],
  );

  // ========== Overlay Gradients ==========

  /// Dark overlay gradient (top to bottom)
  /// Usage: Image overlays, text legibility
  static LinearGradient darkOverlay = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      F1Colors.navyDeep.withValues(alpha: 0.0),
      F1Colors.navyDeep.withValues(alpha: 0.9),
    ],
  );

  /// Cyan overlay gradient
  /// Usage: Hover states, focus effects
  static LinearGradient cianOverlay = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      F1Colors.border.withValues(alpha: 0.0),
      F1Colors.border.withValues(alpha: 0.3),
    ],
  );

  // ========== Border Gradients ==========

  /// Cyan border gradient
  /// Usage: Card borders, input borders
  static LinearGradient cianBorder = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      F1Colors.border,
      F1Colors.border.withValues(alpha: 0.8),
      F1Colors.border,
    ],
  );

  /// Full spectrum border
  /// Usage: Special cards, featured content
  static const LinearGradient rainbowBorder = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      F1Colors.navyLight,
      F1Colors.border,
      F1Colors.vermelho,
    ],
  );

  // ========== Radial Gradients ==========

  /// Glow effect (radial)
  /// Usage: Live indicators, special effects
  static RadialGradient glow(Color color) {
    return RadialGradient(
      center: Alignment.center,
      radius: 0.8,
      colors: [
        color.withValues(alpha: 0.8),
        color.withValues(alpha: 0.4),
        color.withValues(alpha: 0.0),
      ],
      stops: const [0.0, 0.5, 1.0],
    );
  }

  /// Spotlight effect
  /// Usage: Hero sections, featured content
  static RadialGradient spotlight = RadialGradient(
    center: Alignment.topCenter,
    radius: 1.5,
    colors: [
      F1Colors.navy.withValues(alpha: 0.0),
      F1Colors.navyDeep,
    ],
  );

  // ========== Helper Methods ==========

  /// Create a custom two-color gradient
  static LinearGradient custom({
    required Color startColor,
    required Color endColor,
    Alignment begin = Alignment.centerLeft,
    Alignment end = Alignment.centerRight,
  }) {
    return LinearGradient(
      begin: begin,
      end: end,
      colors: [startColor, endColor],
    );
  }

  /// Create a team color gradient (for team-specific UIs)
  static LinearGradient teamGradient(String teamColorHex) {
    final baseColor = Color(
      int.parse('FF$teamColorHex', radix: 16),
    );
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        baseColor,
        HSLColor.fromColor(baseColor).withLightness(0.3).toColor(),
      ],
    );
  }

  /// Create a fading gradient for lists
  static LinearGradient listFade({
    bool fadeTop = false,
    bool fadeBottom = true,
  }) {
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        if (fadeTop) F1Colors.navyDeep.withValues(alpha: 0.0),
        if (fadeTop) F1Colors.navyDeep,
        if (fadeBottom) F1Colors.navyDeep,
        if (fadeBottom) F1Colors.navyDeep.withValues(alpha: 0.0),
      ],
      stops: fadeTop && fadeBottom
          ? const [0.0, 0.1, 0.9, 1.0]
          : fadeTop
              ? const [0.0, 0.1]
              : const [0.9, 1.0],
    );
  }
}
