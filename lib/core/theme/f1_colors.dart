import 'package:flutter/material.dart';

/// F1Sync Color Palette
/// Based on the F1 logo analysis with vibrant gradients
class F1Colors {
  F1Colors._();

  // ========== Main Brand Colors ==========

  /// Primary color - Cyan (#00D9FF)
  /// Usage: Primary buttons, links, active elements, highlights
  static const Color ciano = Color(0xFF00D9FF);
  static const Color cianLight = Color(0xFF33E3FF);
  static const Color cianDark = Color(0xFF00C8E6);

  /// Accent color - Purple (#8B4FC9)
  /// Usage: Premium badges, special highlights, purple sectors (best personal lap)
  static const Color roxo = Color(0xFF8B4FC9);
  static const Color roxoLight = Color(0xFFA855F7);
  static const Color roxoDark = Color(0xFF7C3FAD);

  /// Secondary color - Racing Red (#DC1E42)
  /// Usage: Live indicators, FAB, important alerts, red sectors
  static const Color vermelho = Color(0xFFDC1E42);
  static const Color vermelhoLight = Color(0xFFE64D6B);
  static const Color vermelhoDark = Color(0xFFB8142E);

  /// Highlight color - Gold (#C9974D)
  /// Usage: Pole position, records, achievements, P1 highlights
  static const Color dourado = Color(0xFFC9974D);
  static const Color douradoLight = Color(0xFFD4A855);
  static const Color douradoDark = Color(0xFFB38840);

  // ========== Background Colors ==========

  /// Deep navy background (#0A1628)
  /// Usage: Main app background, scaffold background
  static const Color navyDeep = Color(0xFF0A1628);

  /// Navy surface (#1A2847)
  /// Usage: Cards, containers, elevated surfaces
  static const Color navy = Color(0xFF1A2847);

  /// Light navy (#2A3857)
  /// Usage: Elevated elements, hover states
  static const Color navyLight = Color(0xFF2A3857);

  // ========== Status Colors ==========

  /// Success - Green sectors (best in session)
  static const Color success = Color(0xFF00E676);

  /// Warning - Yellow flags, caution
  static const Color warning = Color(0xFFFFB300);

  /// Error - Critical alerts, red flags
  static const Color error = Color(0xFFFF1744);

  /// Info - Information badges
  static const Color info = Color(0xFF2196F3);

  // ========== Text Colors ==========

  /// Primary text on dark background
  static const Color textPrimary = Color(0xFFFFFFFF);

  /// Secondary text - lower emphasis
  static const Color textSecondary = Color(0xFFB6BABD);

  /// Disabled text
  static const Color textDisabled = Color(0xFF707070);

  // ========== Tire Compound Colors ==========

  /// Soft compound - Red
  static const Color tyreSoft = Color(0xFFFF0000);

  /// Medium compound - Yellow
  static const Color tyreMedium = Color(0xFFFFFF00);

  /// Hard compound - White
  static const Color tyreHard = Color(0xFFFFFFFF);

  /// Intermediate compound - Green
  static const Color tyreIntermediate = Color(0xFF00FF00);

  /// Wet compound - Blue
  static const Color tyreWet = Color(0xFF0000FF);

  // ========== Lap Sector Colors ==========

  /// No data available
  static const Color sectorNone = Color(0xFF707070);

  /// Yellow sector - OK time
  static const Color sectorYellow = Color(0xFFFFEB3B);

  /// Green sector - Personal best
  static const Color sectorGreen = Color(0xFF00E676);

  /// Purple sector - Overall best
  static const Color sectorPurple = roxo;

  /// Red sector - Slower than previous
  static const Color sectorRed = vermelho;

  // ========== Podium Colors ==========

  /// First place - Gold
  static const Color positionFirst = dourado;

  /// Second place - Silver
  static const Color positionSecond = Color(0xFFC0C0C0);

  /// Third place - Bronze
  static const Color positionThird = Color(0xFFCD7F32);

  // ========== Helper Methods ==========

  /// Get color for tire compound
  static Color getTyreColor(String compound) {
    switch (compound.toUpperCase()) {
      case 'SOFT':
        return tyreSoft;
      case 'MEDIUM':
        return tyreMedium;
      case 'HARD':
        return tyreHard;
      case 'INTERMEDIATE':
        return tyreIntermediate;
      case 'WET':
        return tyreWet;
      default:
        return textSecondary;
    }
  }

  /// Get color for position (P1, P2, P3, etc)
  static Color getPositionColor(int position) {
    switch (position) {
      case 1:
        return positionFirst;
      case 2:
        return positionSecond;
      case 3:
        return positionThird;
      default:
        return ciano;
    }
  }

  /// Get color for sector based on segment value from API
  static Color getSectorColor(int segmentValue) {
    switch (segmentValue) {
      case 2048:
        return sectorYellow;
      case 2049:
        return sectorGreen;
      case 2051:
        return sectorPurple;
      case 2064:
        return textSecondary; // Pitlane
      default:
        return sectorNone;
    }
  }
}
