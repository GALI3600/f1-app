import 'package:flutter/material.dart';
import 'package:f1sync/core/theme/f1_colors.dart';
import 'package:f1sync/core/theme/f1_text_styles.dart';

/// F1-themed empty state widget
///
/// Displays empty state messages with optional action following the F1 design system.
///
/// Usage:
/// ```dart
/// F1EmptyStateWidget(
///   icon: Icons.inbox_outlined,
///   title: 'No races yet',
///   message: 'Check back later for upcoming races',
/// )
/// ```
class F1EmptyStateWidget extends StatelessWidget {
  /// The icon to display
  final IconData icon;

  /// The empty state title
  final String title;

  /// The empty state message (optional)
  final String? message;

  /// Icon color (defaults to textSecondary)
  final Color iconColor;

  /// Icon size (defaults to 64)
  final double iconSize;

  /// Action callback (if null, action button is hidden)
  final VoidCallback? onAction;

  /// Action button text (defaults to 'Get Started')
  final String actionText;

  /// Whether to use a text button (true) or elevated button (false)
  final bool useTextButton;

  const F1EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.iconColor = F1Colors.textSecondary,
    this.iconSize = 64.0,
    this.onAction,
    this.actionText = 'Get Started',
    this.useTextButton = true,
  });

  /// No data variant
  const F1EmptyStateWidget.noData({
    super.key,
    this.icon = Icons.inbox_outlined,
    this.title = 'No Data',
    this.message = 'There is no data to display',
    this.iconColor = F1Colors.textSecondary,
    this.iconSize = 64.0,
    this.onAction,
    this.actionText = 'Refresh',
    this.useTextButton = true,
  });

  /// No results variant (for searches)
  const F1EmptyStateWidget.noResults({
    super.key,
    this.icon = Icons.search_off_rounded,
    this.title = 'No Results',
    this.message = 'Try adjusting your search or filters',
    this.iconColor = F1Colors.textSecondary,
    this.iconSize = 64.0,
    this.onAction,
    this.actionText = 'Clear Filters',
    this.useTextButton = true,
  });

  /// No races variant
  const F1EmptyStateWidget.noRaces({
    super.key,
    this.icon = Icons.flag_outlined,
    this.title = 'No Races',
    this.message = 'No races scheduled at the moment',
    this.iconColor = F1Colors.textSecondary,
    this.iconSize = 64.0,
    this.onAction,
    this.actionText = 'Refresh',
    this.useTextButton = true,
  });

  /// No drivers variant
  const F1EmptyStateWidget.noDrivers({
    super.key,
    this.icon = Icons.person_outline_rounded,
    this.title = 'No Drivers',
    this.message = 'No driver information available',
    this.iconColor = F1Colors.textSecondary,
    this.iconSize = 64.0,
    this.onAction,
    this.actionText = 'Refresh',
    this.useTextButton = true,
  });

  /// No favorites variant
  const F1EmptyStateWidget.noFavorites({
    super.key,
    this.icon = Icons.star_outline_rounded,
    this.title = 'No Favorites',
    this.message = 'You haven\'t added any favorites yet',
    this.iconColor = F1Colors.dourado,
    this.iconSize = 64.0,
    this.onAction,
    this.actionText = 'Explore',
    this.useTextButton = false,
  });

  /// Offline variant
  const F1EmptyStateWidget.offline({
    super.key,
    this.icon = Icons.wifi_off_rounded,
    this.title = 'You\'re Offline',
    this.message = 'Connect to the internet to view this content',
    this.iconColor = F1Colors.warning,
    this.iconSize = 64.0,
    this.onAction,
    this.actionText = 'Retry',
    this.useTextButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$title${message != null ? '. $message' : ''}',
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              ExcludeSemantics(
                child: Icon(
                  icon,
                  size: iconSize,
                  color: iconColor,
                ),
              ),
              const SizedBox(height: 24),

              // Title
              Text(
                title,
                style: F1TextStyles.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Message
              if (message != null)
                Text(
                  message!,
                  style: F1TextStyles.bodyMedium,
                  textAlign: TextAlign.center,
                ),

              // Action Button
              if (onAction != null) ...[
                const SizedBox(height: 24),
                if (useTextButton)
                  TextButton.icon(
                    onPressed: onAction,
                    icon: const Icon(Icons.arrow_forward_rounded),
                    label: Text(actionText),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                  )
                else
                  ElevatedButton.icon(
                    onPressed: onAction,
                    icon: const Icon(Icons.arrow_forward_rounded),
                    label: Text(actionText),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
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
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Compact empty state widget for inline display
///
/// A smaller empty state widget suitable for inline display in lists or sections.
class F1CompactEmptyStateWidget extends StatelessWidget {
  /// The icon to display
  final IconData icon;

  /// The empty state message
  final String message;

  /// Icon color (defaults to textSecondary)
  final Color iconColor;

  /// Icon size (defaults to 32)
  final double iconSize;

  const F1CompactEmptyStateWidget({
    super.key,
    required this.icon,
    required this.message,
    this.iconColor = F1Colors.textSecondary,
    this.iconSize = 32.0,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: iconSize,
            color: iconColor,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: F1TextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Empty state widget with custom illustration
///
/// Allows for custom illustrations or widgets instead of icons.
class F1CustomEmptyStateWidget extends StatelessWidget {
  /// The custom illustration widget
  final Widget illustration;

  /// The empty state title
  final String title;

  /// The empty state message (optional)
  final String? message;

  /// Action callback (if null, action button is hidden)
  final VoidCallback? onAction;

  /// Action button text
  final String actionText;

  const F1CustomEmptyStateWidget({
    super.key,
    required this.illustration,
    required this.title,
    this.message,
    this.onAction,
    this.actionText = 'Get Started',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Custom Illustration
            illustration,
            const SizedBox(height: 24),

            // Title
            Text(
              title,
              style: F1TextStyles.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Message
            if (message != null)
              Text(
                message!,
                style: F1TextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),

            // Action Button
            if (onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: F1Colors.navyDeep,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(actionText),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
