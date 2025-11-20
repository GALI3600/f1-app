import 'package:flutter/material.dart';
import 'package:f1sync/core/theme/f1_colors.dart';
import 'package:f1sync/core/theme/f1_text_styles.dart';
import 'package:f1sync/shared/widgets/f1_card.dart';

/// Navigation card for quick access to app features
///
/// Displays a grid of navigation cards that users can tap to navigate to
/// different sections of the app.
class NavigationGrid extends StatelessWidget {
  /// Optional callback when a navigation item is tapped
  final Function(String route)? onNavigate;

  const NavigationGrid({
    super.key,
    this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Text(
            'Quick Navigation',
            style: F1TextStyles.headlineSmall.copyWith(
              color: F1Colors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.0,
          children: [
            NavigationCard(
              icon: Icons.flag_rounded,
              label: 'GPs',
              iconColor: F1Colors.ciano,
              route: '/meetings',
              onTap: onNavigate,
            ),
            NavigationCard(
              icon: Icons.person_rounded,
              label: 'Drivers',
              iconColor: F1Colors.roxo,
              route: '/drivers',
              onTap: onNavigate,
            ),
            NavigationCard(
              icon: Icons.groups_rounded,
              label: 'Teams',
              iconColor: F1Colors.vermelho,
              route: '/teams',
              onTap: onNavigate,
            ),
            NavigationCard(
              icon: Icons.route_rounded,
              label: 'Circuits',
              iconColor: F1Colors.dourado,
              route: '/circuits',
              onTap: onNavigate,
            ),
            NavigationCard(
              icon: Icons.bar_chart_rounded,
              label: 'Stats',
              iconColor: F1Colors.ciano,
              route: '/stats',
              onTap: onNavigate,
            ),
            NavigationCard(
              icon: Icons.settings_rounded,
              label: 'Settings',
              iconColor: F1Colors.textSecondary,
              route: '/settings',
              onTap: onNavigate,
            ),
          ],
        ),
      ],
    );
  }
}

/// Individual navigation card widget
///
/// Displays an icon and label for a specific navigation destination.
class NavigationCard extends StatelessWidget {
  /// The icon to display
  final IconData icon;

  /// The label text
  final String label;

  /// The icon color
  final Color iconColor;

  /// The route to navigate to
  final String route;

  /// Optional callback when tapped
  final Function(String route)? onTap;

  const NavigationCard({
    super.key,
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.route,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return F1Card.primary(
      padding: const EdgeInsets.all(12),
      onTap: () {
        if (onTap != null) {
          onTap!(route);
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon with background
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),

          // Label
          Text(
            label,
            style: F1TextStyles.labelMedium.copyWith(
              color: F1Colors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// Alternative compact navigation card (horizontal layout)
///
/// A more compact version of the navigation card with icon and label side by side.
class CompactNavigationCard extends StatelessWidget {
  /// The icon to display
  final IconData icon;

  /// The label text
  final String label;

  /// The subtitle text (optional)
  final String? subtitle;

  /// The icon color
  final Color iconColor;

  /// The route to navigate to
  final String route;

  /// Optional callback when tapped
  final Function(String route)? onTap;

  const CompactNavigationCard({
    super.key,
    required this.icon,
    required this.label,
    this.subtitle,
    required this.iconColor,
    required this.route,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return F1Card.primary(
      padding: const EdgeInsets.all(12),
      onTap: () {
        if (onTap != null) {
          onTap!(route);
        }
      },
      child: Row(
        children: [
          // Icon with background
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),

          // Label and subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: F1TextStyles.bodyLarge.copyWith(
                    color: F1Colors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: F1TextStyles.bodySmall.copyWith(
                      color: F1Colors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),

          // Arrow icon
          Icon(
            Icons.arrow_forward_ios_rounded,
            color: F1Colors.textSecondary,
            size: 16,
          ),
        ],
      ),
    );
  }
}
