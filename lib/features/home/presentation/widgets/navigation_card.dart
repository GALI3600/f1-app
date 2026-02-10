import 'package:cached_network_image/cached_network_image.dart';
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

  /// Number of columns in the grid (defaults to 2)
  final int crossAxisCount;

  /// Whether to show the title
  final bool showTitle;

  const NavigationGrid({
    super.key,
    this.onNavigate,
    this.crossAxisCount = 2,
    this.showTitle = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showTitle) ...[
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
        ],
        GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: crossAxisCount > 2 ? 1.4 : 1.0,
          children: [
            EnhancedNavigationCard(
              label: 'Grand Prix',
              subtitle: 'Race Calendar & Results',
              accentColor: F1Colors.vermelho,
              route: '/meetings',
              imageUrl: 'https://www.f1-fansite.com/wp-content/uploads/2023/08/230032-scuderia-ferrari-belgian-gp-saturday_c640df81-ef4d-4701-a69c-8cd83cfe06d1-624x367.jpg',
              onTap: onNavigate,
            ),
            EnhancedNavigationCard(
              label: 'Drivers',
              subtitle: 'Stats & Performance',
              accentColor: F1Colors.vermelho,
              route: '/drivers',
              imageUrl: 'https://images.alphacoders.com/208/thumb-1920-208273.jpg',
              onTap: onNavigate,
            ),
          ],
        ),
      ],
    );
  }
}

/// Enhanced navigation card with background image
class EnhancedNavigationCard extends StatelessWidget {
  final String label;
  final String? subtitle;
  final Color accentColor;
  final String route;
  final String? imageUrl;
  final Function(String route)? onTap;

  const EnhancedNavigationCard({
    super.key,
    required this.label,
    this.subtitle,
    required this.accentColor,
    required this.route,
    this.imageUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => onTap?.call(route),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: 0.3),
                blurRadius: 12,
                spreadRadius: -2,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
          fit: StackFit.expand,
          children: [
            // Background image
            if (imageUrl != null)
              CachedNetworkImage(
                imageUrl: imageUrl!,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: F1Colors.navy,
                ),
                errorWidget: (context, url, error) => Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        accentColor.withValues(alpha: 0.3),
                        F1Colors.navyDeep,
                      ],
                    ),
                  ),
                ),
              )
            else
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      accentColor.withValues(alpha: 0.3),
                      F1Colors.navyDeep,
                    ],
                  ),
                ),
              ),

            // Gradient overlay for text readability
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.3),
                      Colors.black.withValues(alpha: 0.85),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),

            // Accent bar on left
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 5,
                decoration: BoxDecoration(
                  color: accentColor,
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withValues(alpha: 0.5),
                      blurRadius: 8,
                      spreadRadius: 0,
                    ),
                  ],
                ),
              ),
            ),

            // Content
            Positioned(
              left: 16,
              right: 12,
              bottom: 14,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Label
                  Text(
                    label.toUpperCase(),
                    style: F1TextStyles.headlineMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 22,
                      letterSpacing: 1.5,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.6),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),

                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: F1TextStyles.bodySmall.copyWith(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),

            // Arrow indicator
            Positioned(
              right: 12,
              top: 12,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white.withValues(alpha: 0.8),
                  size: 18,
                ),
              ),
            ),

            // Border overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
        ),
      ),
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
              color: iconColor.withValues(alpha: 0.15),
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
              color: iconColor.withValues(alpha: 0.15),
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
