import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:f1sync/core/theme/f1_colors.dart';

/// F1-themed loading widget with shimmer effect
///
/// Displays a skeleton loader with F1-branded shimmer animation.
///
/// Usage:
/// ```dart
/// LoadingWidget()
/// ```
///
/// For custom shapes:
/// ```dart
/// LoadingWidget.custom(
///   child: Container(
///     height: 200,
///     decoration: BoxDecoration(
///       color: Colors.white,
///       borderRadius: BorderRadius.circular(12),
///     ),
///   ),
/// )
/// ```
class LoadingWidget extends StatelessWidget {
  /// The child widget to apply shimmer effect to
  final Widget? child;

  /// Width of the loading container
  final double? width;

  /// Height of the loading container
  final double? height;

  /// Border radius of the loading container
  final double borderRadius;

  /// Duration of the shimmer animation
  final Duration duration;

  const LoadingWidget({
    super.key,
    this.child,
    this.width,
    this.height,
    this.borderRadius = 12.0,
    this.duration = const Duration(milliseconds: 1500),
  });

  /// Custom loading widget with specified child
  const LoadingWidget.custom({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1500),
  })  : width = null,
        height = null,
        borderRadius = 0;

  /// Card-shaped loading widget
  const LoadingWidget.card({
    super.key,
    this.width = double.infinity,
    this.height = 120.0,
    this.borderRadius = 12.0,
    this.duration = const Duration(milliseconds: 1500),
  }) : child = null;

  /// List item loading widget
  const LoadingWidget.listItem({
    super.key,
    this.width = double.infinity,
    this.height = 80.0,
    this.borderRadius = 8.0,
    this.duration = const Duration(milliseconds: 1500),
  }) : child = null;

  /// Circle loading widget (for avatars)
  const LoadingWidget.circle({
    super.key,
    required double size,
    this.duration = const Duration(milliseconds: 1500),
  })  : width = size,
        height = size,
        borderRadius = 1000, // Large enough to make it circular
        child = null;

  /// Text line loading widget
  const LoadingWidget.text({
    super.key,
    this.width = 120.0,
    this.height = 16.0,
    this.borderRadius = 4.0,
    this.duration = const Duration(milliseconds: 1500),
  }) : child = null;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: F1Colors.navy,
      highlightColor: F1Colors.ciano.withValues(alpha: 0.3),
      period: duration,
      child: child ??
          Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          ),
    );
  }
}

/// F1-themed list loading widget
///
/// Displays a list of shimmer loading items for skeleton loading states.
///
/// Usage:
/// ```dart
/// LoadingListWidget(itemCount: 5)
/// ```
class LoadingListWidget extends StatelessWidget {
  /// Number of loading items to display
  final int itemCount;

  /// Height of each loading item
  final double itemHeight;

  /// Spacing between items
  final double spacing;

  /// Custom item builder (optional)
  final Widget Function(BuildContext context, int index)? itemBuilder;

  const LoadingListWidget({
    super.key,
    this.itemCount = 5,
    this.itemHeight = 80.0,
    this.spacing = 12.0,
    this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: itemCount,
      separatorBuilder: (context, index) => SizedBox(height: spacing),
      itemBuilder: itemBuilder ??
          (context, index) => LoadingWidget.listItem(height: itemHeight),
    );
  }
}

/// F1-themed grid loading widget
///
/// Displays a grid of shimmer loading items for skeleton loading states.
///
/// Usage:
/// ```dart
/// LoadingGridWidget(
///   crossAxisCount: 2,
///   itemCount: 6,
/// )
/// ```
class LoadingGridWidget extends StatelessWidget {
  /// Number of loading items to display
  final int itemCount;

  /// Number of columns in the grid
  final int crossAxisCount;

  /// Aspect ratio of each item
  final double childAspectRatio;

  /// Spacing between items
  final double spacing;

  /// Custom item builder (optional)
  final Widget Function(BuildContext context, int index)? itemBuilder;

  const LoadingGridWidget({
    super.key,
    this.itemCount = 6,
    this.crossAxisCount = 2,
    this.childAspectRatio = 1.5,
    this.spacing = 12.0,
    this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
      ),
      itemCount: itemCount,
      itemBuilder: itemBuilder ?? (context, index) => const LoadingWidget.card(),
    );
  }
}

/// F1-themed driver card loading widget
///
/// Specialized loading widget for driver card skeletons.
class DriverCardLoadingWidget extends StatelessWidget {
  const DriverCardLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return LoadingWidget.custom(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 16),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 120,
                    height: 18,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 80,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 60,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// F1-themed race card loading widget
///
/// Specialized loading widget for race card skeletons.
class RaceCardLoadingWidget extends StatelessWidget {
  const RaceCardLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return LoadingWidget.custom(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Container(
              width: 180,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 12),
            // Date
            Container(
              width: 100,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 8),
            // Location
            Container(
              width: 140,
              height: 14,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
