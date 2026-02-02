import 'package:flutter/material.dart';
import 'package:f1sync/core/theme/f1_colors.dart';
import 'package:f1sync/core/error/error_mapper.dart';
import 'package:f1sync/shared/services/haptic_service.dart';
import 'package:f1sync/shared/widgets/f1_loading.dart';

/// Service for displaying consistent snackbar/toast messages
///
/// Provides centralized snackbar management with F1 design system theming
/// and automatic haptic feedback.
///
/// Usage:
/// ```dart
/// SnackbarService.showSuccess(context, 'Data loaded successfully');
/// SnackbarService.showError(context, error);
/// SnackbarService.showInfo(context, 'Live session starting soon');
/// ```
class SnackbarService {
  SnackbarService._();

  /// Default duration for snackbars
  static const Duration defaultDuration = Duration(seconds: 3);

  /// Short duration for quick messages
  static const Duration shortDuration = Duration(seconds: 2);

  /// Long duration for important messages
  static const Duration longDuration = Duration(seconds: 5);

  /// Show a success snackbar
  ///
  /// Use for successful operations like data loaded, refresh complete, etc.
  static void showSuccess(
    BuildContext context,
    String message, {
    Duration duration = defaultDuration,
    SnackBarAction? action,
    bool haptic = true,
  }) {
    if (haptic) HapticService.success();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: F1Colors.success,
        behavior: SnackBarBehavior.floating,
        duration: duration,
        action: action,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// Show an error snackbar
  ///
  /// Use for failed operations, network errors, validation errors, etc.
  /// Can accept either a String or an Exception/Error object.
  static void showError(
    BuildContext context,
    Object error, {
    Duration duration = longDuration,
    VoidCallback? onRetry,
    bool haptic = true,
  }) {
    if (haptic) HapticService.error();

    final message = error is String ? error : ErrorMapper.getErrorMessage(error);
    final icon = error is String ? Icons.error_outline_rounded : ErrorMapper.getErrorIcon(error);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: F1Colors.error,
        behavior: SnackBarBehavior.floating,
        duration: duration,
        action: onRetry != null
            ? SnackBarAction(
                label: 'Retry',
                textColor: Colors.white,
                onPressed: onRetry,
              )
            : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// Show a network error snackbar
  ///
  /// Specialized error snackbar for network-related errors.
  static void showNetworkError(
    BuildContext context, {
    String message = 'No internet connection',
    VoidCallback? onRetry,
    Duration duration = longDuration,
    bool haptic = true,
  }) {
    if (haptic) HapticService.error();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: F1Colors.error,
        behavior: SnackBarBehavior.floating,
        duration: duration,
        action: onRetry != null
            ? SnackBarAction(
                label: 'Retry',
                textColor: Colors.white,
                onPressed: onRetry,
              )
            : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// Show a warning snackbar
  ///
  /// Use for warnings, confirmations needed, caution states, etc.
  static void showWarning(
    BuildContext context,
    String message, {
    Duration duration = defaultDuration,
    SnackBarAction? action,
    bool haptic = true,
  }) {
    if (haptic) HapticService.warning();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: F1Colors.warning,
        behavior: SnackBarBehavior.floating,
        duration: duration,
        action: action,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// Show an info snackbar
  ///
  /// Use for informational messages like "Live session starting soon".
  static void showInfo(
    BuildContext context,
    String message, {
    Duration duration = defaultDuration,
    SnackBarAction? action,
    bool haptic = false,
  }) {
    if (haptic) HapticService.lightImpact();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.info_outline_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: F1Colors.info,
        behavior: SnackBarBehavior.floating,
        duration: duration,
        action: action,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// Show a custom snackbar
  ///
  /// Use when you need full control over the snackbar appearance.
  static void showCustom(
    BuildContext context, {
    required String message,
    required Color backgroundColor,
    IconData? icon,
    Color iconColor = Colors.white,
    Duration duration = defaultDuration,
    SnackBarAction? action,
    bool haptic = false,
  }) {
    if (haptic) HapticService.lightImpact();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                color: iconColor,
                size: 20,
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        duration: duration,
        action: action,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// Show a loading snackbar
  ///
  /// Use for ongoing operations. Remember to dismiss it when done.
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showLoading(
    BuildContext context,
    String message, {
    bool haptic = false,
  }) {
    if (haptic) HapticService.lightImpact();

    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const F1WheelLoading(
              size: 16,
              color: Colors.white,
              duration: Duration(milliseconds: 600),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: F1Colors.navy,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(days: 1), // Will be dismissed manually
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// Dismiss the current snackbar
  static void dismiss(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }

  /// Clear all snackbars
  static void clearAll(BuildContext context) {
    ScaffoldMessenger.of(context).clearSnackBars();
  }
}
