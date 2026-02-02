import 'package:flutter/material.dart';
import 'package:f1sync/core/theme/f1_colors.dart';
import 'package:f1sync/core/theme/f1_text_styles.dart';

/// F1Sync Theme Configuration
/// Complete dark theme based on F1 visual identity
class AppTheme {
  AppTheme._();

  /// Main dark theme (default)
  /// Based on F1 logo colors and design system
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // ========== Color Scheme ==========
      colorScheme: const ColorScheme.dark(
        primary: F1Colors.ciano,
        secondary: F1Colors.vermelho,
        tertiary: F1Colors.roxo,
        surface: F1Colors.navy,
        error: F1Colors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.white,
        onError: Colors.white,
      ),

      // ========== Scaffold ==========
      scaffoldBackgroundColor: F1Colors.navyDeep,

      // ========== AppBar ==========
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        iconTheme: IconThemeData(color: Colors.white),
        actionsIconTheme: IconThemeData(color: Colors.white),
      ),

      // ========== Card ==========
      cardTheme: CardThemeData(
        color: F1Colors.navy,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: F1Colors.ciano.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        margin: const EdgeInsets.all(8),
      ),

      // ========== Elevated Button ==========
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: F1Colors.ciano,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: F1TextStyles.labelLarge,
        ),
      ),

      // ========== Outlined Button ==========
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: F1Colors.ciano,
          side: const BorderSide(color: F1Colors.ciano, width: 1.5),
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: F1TextStyles.labelLarge,
        ),
      ),

      // ========== Text Button ==========
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: F1Colors.ciano,
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          textStyle: F1TextStyles.labelLarge,
        ),
      ),

      // ========== FAB ==========
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: F1Colors.vermelho,
        foregroundColor: Colors.white,
        elevation: 4,
      ),

      // ========== Bottom Navigation Bar ==========
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: F1Colors.navyDeep,
        selectedItemColor: F1Colors.ciano,
        unselectedItemColor: F1Colors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // ========== Input Decoration ==========
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: F1Colors.navy,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: F1Colors.ciano),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: F1Colors.ciano.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: F1Colors.ciano,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: F1Colors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: F1Colors.error,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        hintStyle: F1TextStyles.bodyMedium,
        labelStyle: F1TextStyles.labelLarge,
      ),

      // ========== Chip ==========
      chipTheme: ChipThemeData(
        backgroundColor: F1Colors.navy,
        labelStyle: F1TextStyles.labelMedium,
        side: BorderSide(
          color: F1Colors.ciano.withValues(alpha: 0.3),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),

      // ========== Progress Indicator ==========
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: F1Colors.ciano,
        linearTrackColor: F1Colors.navy,
        circularTrackColor: F1Colors.navy,
      ),

      // ========== Snackbar ==========
      snackBarTheme: SnackBarThemeData(
        backgroundColor: F1Colors.navy,
        contentTextStyle: F1TextStyles.bodyMedium.copyWith(
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: F1Colors.ciano),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 4,
      ),

      // ========== Dialog ==========
      dialogTheme: DialogThemeData(
        backgroundColor: F1Colors.navy,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: F1Colors.ciano.withValues(alpha: 0.3),
          ),
        ),
        titleTextStyle: F1TextStyles.headlineMedium,
        contentTextStyle: F1TextStyles.bodyLarge,
      ),

      // ========== Bottom Sheet ==========
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: F1Colors.navy,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(16),
          ),
        ),
      ),

      // ========== Divider ==========
      dividerTheme: DividerThemeData(
        color: F1Colors.ciano.withValues(alpha: 0.2),
        thickness: 1,
        space: 1,
      ),

      // ========== Icon ==========
      iconTheme: const IconThemeData(
        color: F1Colors.ciano,
        size: 24,
      ),

      // ========== List Tile ==========
      listTileTheme: const ListTileThemeData(
        textColor: F1Colors.textPrimary,
        iconColor: F1Colors.ciano,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      // ========== Switch ==========
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.white;
          }
          return F1Colors.textSecondary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return F1Colors.ciano;
          }
          return F1Colors.navyLight;
        }),
      ),

      // ========== Checkbox ==========
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return F1Colors.ciano;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        side: const BorderSide(color: F1Colors.ciano, width: 2),
      ),

      // ========== Radio ==========
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return F1Colors.ciano;
          }
          return F1Colors.textSecondary;
        }),
      ),

      // ========== Slider ==========
      sliderTheme: const SliderThemeData(
        activeTrackColor: F1Colors.ciano,
        inactiveTrackColor: F1Colors.navy,
        thumbColor: F1Colors.ciano,
        overlayColor: Color(0x1F00D9FF), // F1Colors.ciano with opacity
        valueIndicatorColor: F1Colors.ciano,
        valueIndicatorTextStyle: TextStyle(color: Colors.white),
      ),

      // ========== TabBar ==========
      tabBarTheme: const TabBarThemeData(
        labelColor: F1Colors.ciano,
        unselectedLabelColor: F1Colors.textSecondary,
        indicatorColor: F1Colors.ciano,
        indicatorSize: TabBarIndicatorSize.tab,
      ),

      // ========== Text Theme ==========
      textTheme: const TextTheme(
        displayLarge: F1TextStyles.displayLarge,
        displayMedium: F1TextStyles.displayMedium,
        displaySmall: F1TextStyles.displaySmall,
        headlineLarge: F1TextStyles.headlineLarge,
        headlineMedium: F1TextStyles.headlineMedium,
        headlineSmall: F1TextStyles.headlineSmall,
        bodyLarge: F1TextStyles.bodyLarge,
        bodyMedium: F1TextStyles.bodyMedium,
        bodySmall: F1TextStyles.bodySmall,
        labelLarge: F1TextStyles.labelLarge,
        labelMedium: F1TextStyles.labelMedium,
        labelSmall: F1TextStyles.labelSmall,
      ),
    );
  }

  /// Light theme (optional - for future implementation)
  /// Currently using dark theme as primary
  static ThemeData get lightTheme {
    // For Phase 1, we'll use the dark theme as default
    // Light theme can be implemented in Phase 2
    return darkTheme;
  }
}
