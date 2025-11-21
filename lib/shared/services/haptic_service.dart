import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

/// Service for providing haptic feedback throughout the app
///
/// Provides consistent haptic feedback patterns for different user interactions.
/// Automatically handles platform differences and gracefully degrades when
/// haptic feedback is not supported.
///
/// Usage:
/// ```dart
/// // Light tap feedback for card taps
/// HapticService.lightImpact();
///
/// // Medium feedback for navigation
/// HapticService.mediumImpact();
///
/// // Success feedback
/// HapticService.success();
///
/// // Error feedback
/// HapticService.error();
/// ```
class HapticService {
  HapticService._();

  /// Whether haptic feedback is enabled (can be toggled by user preferences)
  static bool _isEnabled = true;

  /// Enable haptic feedback
  static void enable() {
    _isEnabled = true;
  }

  /// Disable haptic feedback
  static void disable() {
    _isEnabled = false;
  }

  /// Check if haptic feedback is enabled
  static bool get isEnabled => _isEnabled;

  /// Light impact haptic feedback
  ///
  /// Use for:
  /// - Card taps
  /// - List item selections
  /// - Chip selections
  /// - Minor UI interactions
  static Future<void> lightImpact() async {
    if (!_isEnabled) return;
    try {
      await HapticFeedback.lightImpact();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Haptic feedback not supported: $e');
      }
    }
  }

  /// Medium impact haptic feedback
  ///
  /// Use for:
  /// - Navigation transitions
  /// - Tab switches
  /// - Modal presentations
  /// - Button presses
  static Future<void> mediumImpact() async {
    if (!_isEnabled) return;
    try {
      await HapticFeedback.mediumImpact();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Haptic feedback not supported: $e');
      }
    }
  }

  /// Heavy impact haptic feedback
  ///
  /// Use for:
  /// - Important confirmations
  /// - Deletions
  /// - Major state changes
  /// - Critical actions
  static Future<void> heavyImpact() async {
    if (!_isEnabled) return;
    try {
      await HapticFeedback.heavyImpact();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Haptic feedback not supported: $e');
      }
    }
  }

  /// Selection changed haptic feedback
  ///
  /// Use for:
  /// - Slider movements
  /// - Picker changes
  /// - Segmented control changes
  /// - Continuous selection changes
  static Future<void> selectionClick() async {
    if (!_isEnabled) return;
    try {
      await HapticFeedback.selectionClick();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Haptic feedback not supported: $e');
      }
    }
  }

  /// Vibrate for notifications
  ///
  /// Use for:
  /// - Incoming notifications
  /// - Alerts
  /// - Background updates
  static Future<void> vibrate() async {
    if (!_isEnabled) return;
    try {
      await HapticFeedback.vibrate();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Haptic feedback not supported: $e');
      }
    }
  }

  /// Success feedback (medium impact + light impact)
  ///
  /// Use for:
  /// - Successful operations
  /// - Completed tasks
  /// - Refresh complete
  /// - Data loaded successfully
  static Future<void> success() async {
    if (!_isEnabled) return;
    try {
      await HapticFeedback.mediumImpact();
      await Future.delayed(const Duration(milliseconds: 50));
      await HapticFeedback.lightImpact();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Haptic feedback not supported: $e');
      }
    }
  }

  /// Error feedback (heavy impact)
  ///
  /// Use for:
  /// - Failed operations
  /// - Validation errors
  /// - Network errors
  /// - Invalid inputs
  static Future<void> error() async {
    if (!_isEnabled) return;
    try {
      await HapticFeedback.heavyImpact();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Haptic feedback not supported: $e');
      }
    }
  }

  /// Warning feedback (light impact + medium impact)
  ///
  /// Use for:
  /// - Warnings
  /// - Confirmations needed
  /// - Caution states
  static Future<void> warning() async {
    if (!_isEnabled) return;
    try {
      await HapticFeedback.lightImpact();
      await Future.delayed(const Duration(milliseconds: 50));
      await HapticFeedback.mediumImpact();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Haptic feedback not supported: $e');
      }
    }
  }

  /// Navigation feedback (light impact)
  ///
  /// Use for:
  /// - Screen navigation
  /// - Tab changes
  /// - Drawer open/close
  static Future<void> navigation() async {
    await mediumImpact();
  }

  /// Tap feedback (light impact)
  ///
  /// Use for:
  /// - General taps
  /// - Card taps
  /// - List item taps
  static Future<void> tap() async {
    await lightImpact();
  }

  /// Long press feedback (heavy impact)
  ///
  /// Use for:
  /// - Long press actions
  /// - Context menu opens
  /// - Drag start
  static Future<void> longPress() async {
    await heavyImpact();
  }

  /// Refresh feedback (success pattern)
  ///
  /// Use for:
  /// - Pull-to-refresh complete
  /// - Manual refresh complete
  /// - Data reload complete
  static Future<void> refresh() async {
    await success();
  }
}
