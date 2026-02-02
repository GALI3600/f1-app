import 'package:flutter/material.dart';
import 'package:f1sync/core/theme/f1_colors.dart';
import 'package:f1sync/core/theme/f1_text_styles.dart';

/// F1-themed error widget for error states
///
/// Displays error messages with optional retry action following the F1 design system.
///
/// Usage:
/// ```dart
/// F1ErrorWidget(
///   title: 'Failed to load data',
///   message: 'Please check your internet connection',
///   onRetry: () => loadData(),
/// )
/// ```
class F1ErrorWidget extends StatelessWidget {
  /// The error title
  final String title;

  /// The error message (optional)
  final String? message;

  /// The error icon (defaults to error_outline)
  final IconData icon;

  /// Icon color (defaults to error red)
  final Color iconColor;

  /// Retry callback (if null, retry button is hidden)
  final VoidCallback? onRetry;

  /// Retry button text (defaults to 'Retry')
  final String retryText;

  /// Whether to show a detailed error message
  final bool showDetails;

  /// Optional error details (for debugging)
  final String? errorDetails;

  const F1ErrorWidget({
    super.key,
    required this.title,
    this.message,
    this.icon = Icons.error_outline,
    this.iconColor = F1Colors.error,
    this.onRetry,
    this.retryText = 'Retry',
    this.showDetails = false,
    this.errorDetails,
  });

  /// Network error variant
  const F1ErrorWidget.network({
    super.key,
    this.title = 'Connection Error',
    this.message = 'Please check your internet connection and try again',
    this.icon = Icons.wifi_off_rounded,
    this.iconColor = F1Colors.error,
    this.onRetry,
    this.retryText = 'Retry',
    this.showDetails = false,
    this.errorDetails,
  });

  /// Server error variant
  const F1ErrorWidget.server({
    super.key,
    this.title = 'Server Error',
    this.message = 'Something went wrong on our end. Please try again later',
    this.icon = Icons.cloud_off_rounded,
    this.iconColor = F1Colors.error,
    this.onRetry,
    this.retryText = 'Retry',
    this.showDetails = false,
    this.errorDetails,
  });

  /// Not found error variant
  const F1ErrorWidget.notFound({
    super.key,
    this.title = 'Not Found',
    this.message = 'The requested resource could not be found',
    this.icon = Icons.search_off_rounded,
    this.iconColor = F1Colors.textSecondary,
    this.onRetry,
    this.retryText = 'Go Back',
    this.showDetails = false,
    this.errorDetails,
  });

  /// Unauthorized error variant
  const F1ErrorWidget.unauthorized({
    super.key,
    this.title = 'Unauthorized',
    this.message = 'You need to be logged in to access this content',
    this.icon = Icons.lock_outline_rounded,
    this.iconColor = F1Colors.warning,
    this.onRetry,
    this.retryText = 'Sign In',
    this.showDetails = false,
    this.errorDetails,
  });

  /// Generic error variant (for uncategorized errors)
  const F1ErrorWidget.generic({
    super.key,
    this.title = 'Something went wrong',
    this.message = 'An unexpected error occurred. Please try again',
    this.icon = Icons.error_outline_rounded,
    this.iconColor = F1Colors.error,
    this.onRetry,
    this.retryText = 'Retry',
    this.showDetails = false,
    this.errorDetails,
  });

  /// Timeout error variant
  const F1ErrorWidget.timeout({
    super.key,
    this.title = 'Request Timed Out',
    this.message = 'The request took too long. Please try again',
    this.icon = Icons.schedule_outlined,
    this.iconColor = F1Colors.warning,
    this.onRetry,
    this.retryText = 'Retry',
    this.showDetails = false,
    this.errorDetails,
  });

  /// Rate limited error variant
  const F1ErrorWidget.rateLimited({
    super.key,
    this.title = 'Too Many Requests',
    this.message = 'Please wait a moment before trying again',
    this.icon = Icons.speed_rounded,
    this.iconColor = F1Colors.warning,
    this.onRetry,
    this.retryText = 'Try Again',
    this.showDetails = false,
    this.errorDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Error: $title${message != null ? '. $message' : ''}',
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Error Icon
              ExcludeSemantics(
                child: Icon(
                  icon,
                  size: 64,
                  color: iconColor,
                ),
              ),
              const SizedBox(height: 24),

              // Error Title
              Semantics(
                header: true,
                child: Text(
                  title,
                  style: F1TextStyles.headlineMedium,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 12),

              // Error Message
              if (message != null)
                Text(
                  message!,
                  style: F1TextStyles.bodyMedium,
                  textAlign: TextAlign.center,
                ),

              // Error Details (for debugging)
              if (showDetails && errorDetails != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: F1Colors.navyLight,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: F1Colors.error.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    errorDetails!,
                    style: F1TextStyles.bodySmall.copyWith(
                      fontFamily: 'RobotoMono',
                      color: F1Colors.error,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
              ],

              // Retry Button
              if (onRetry != null) ...[
                const SizedBox(height: 24),
                Semantics(
                  button: true,
                  enabled: true,
                  label: retryText,
                  hint: 'Double tap to retry',
                  child: ElevatedButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh_rounded),
                    label: Text(retryText),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: F1Colors.ciano,
                      foregroundColor: F1Colors.navyDeep,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Compact error widget for inline display
///
/// A smaller error widget suitable for inline display in lists or cards.
class F1CompactErrorWidget extends StatelessWidget {
  /// The error message
  final String message;

  /// The error icon (defaults to error_outline)
  final IconData icon;

  /// Icon color (defaults to error red)
  final Color iconColor;

  /// Retry callback (if null, retry button is hidden)
  final VoidCallback? onRetry;

  const F1CompactErrorWidget({
    super.key,
    required this.message,
    this.icon = Icons.error_outline,
    this.iconColor = F1Colors.error,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(
            icon,
            size: 24,
            color: iconColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: F1TextStyles.bodyMedium.copyWith(
                color: iconColor,
              ),
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(width: 12),
            IconButton(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              color: F1Colors.ciano,
              iconSize: 20,
            ),
          ],
        ],
      ),
    );
  }
}
