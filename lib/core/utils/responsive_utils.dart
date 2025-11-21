import 'package:flutter/material.dart';

/// Responsive layout utility for adaptive UI design
///
/// Provides breakpoints and utilities for building responsive layouts
/// that adapt to different screen sizes (phone, tablet, desktop).
///
/// Usage:
/// ```dart
/// // Check device type
/// if (ResponsiveUtils.isTablet(context)) {
///   return TabletLayout();
/// }
///
/// // Get value based on screen size
/// final columns = ResponsiveUtils.valueWhen(
///   context: context,
///   mobile: 2,
///   tablet: 3,
///   desktop: 4,
/// );
///
/// // Use responsive widget
/// ResponsiveBuilder(
///   mobile: (context) => MobileLayout(),
///   tablet: (context) => TabletLayout(),
/// )
/// ```
class ResponsiveUtils {
  // Breakpoints (in logical pixels)
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1024;

  /// Check if current device is mobile (width < 600dp)
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }

  /// Check if current device is tablet (600dp <= width < 1024dp)
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < tabletBreakpoint;
  }

  /// Check if current device is desktop (width >= 1024dp)
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= tabletBreakpoint;
  }

  /// Check if current orientation is portrait
  static bool isPortrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }

  /// Check if current orientation is landscape
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  /// Get device type as enum
  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileBreakpoint) {
      return DeviceType.mobile;
    } else if (width < tabletBreakpoint) {
      return DeviceType.tablet;
    } else {
      return DeviceType.desktop;
    }
  }

  /// Get value based on device type
  ///
  /// Returns the appropriate value for the current screen size.
  /// If a specific breakpoint value is not provided, it falls back
  /// to the next smaller breakpoint.
  ///
  /// Example:
  /// ```dart
  /// final padding = ResponsiveUtils.valueWhen<double>(
  ///   context: context,
  ///   mobile: 16,
  ///   tablet: 24,
  ///   desktop: 32,
  /// );
  /// ```
  static T valueWhen<T>({
    required BuildContext context,
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    final deviceType = getDeviceType(context);

    return switch (deviceType) {
      DeviceType.mobile => mobile,
      DeviceType.tablet => tablet ?? mobile,
      DeviceType.desktop => desktop ?? tablet ?? mobile,
    };
  }

  /// Get responsive grid columns count
  ///
  /// Returns appropriate number of columns for grid layouts
  /// based on screen size.
  ///
  /// Default values:
  /// - Mobile portrait: 2 columns
  /// - Mobile landscape: 3 columns
  /// - Tablet portrait: 3 columns
  /// - Tablet landscape: 4 columns
  /// - Desktop: 4-6 columns
  static int getGridColumns(BuildContext context, {int? override}) {
    if (override != null) return override;

    final width = MediaQuery.of(context).size.width;
    final isPortrait = ResponsiveUtils.isPortrait(context);

    if (width < mobileBreakpoint) {
      // Mobile
      return isPortrait ? 2 : 3;
    } else if (width < tabletBreakpoint) {
      // Tablet
      return isPortrait ? 3 : 4;
    } else {
      // Desktop
      return (width / 250).floor().clamp(4, 6);
    }
  }

  /// Get responsive horizontal padding
  ///
  /// Returns appropriate horizontal padding based on screen size.
  static double getHorizontalPadding(BuildContext context) {
    return valueWhen<double>(
      context: context,
      mobile: 16,
      tablet: 24,
      desktop: 32,
    );
  }

  /// Get responsive vertical padding
  ///
  /// Returns appropriate vertical padding based on screen size.
  static double getVerticalPadding(BuildContext context) {
    return valueWhen<double>(
      context: context,
      mobile: 16,
      tablet: 20,
      desktop: 24,
    );
  }

  /// Get responsive card width
  ///
  /// Returns appropriate maximum width for cards/containers
  /// to prevent them from being too wide on large screens.
  static double? getCardMaxWidth(BuildContext context) {
    if (isDesktop(context)) {
      return 1200;
    } else if (isTablet(context)) {
      return 800;
    }
    return null; // Full width on mobile
  }

  /// Get responsive font scale
  ///
  /// Returns font scale factor based on screen size.
  /// Useful for making text slightly larger on tablets/desktop.
  static double getFontScale(BuildContext context) {
    return valueWhen<double>(
      context: context,
      mobile: 1.0,
      tablet: 1.05,
      desktop: 1.1,
    );
  }

  /// Get safe area padding
  ///
  /// Returns the current safe area insets (for notches, system bars, etc.)
  static EdgeInsets getSafeAreaPadding(BuildContext context) {
    return MediaQuery.of(context).padding;
  }

  /// Check if device has bottom navigation bar (system UI)
  static bool hasBottomSystemBar(BuildContext context) {
    return MediaQuery.of(context).padding.bottom > 0;
  }

  /// Get text scale factor from system settings
  static double getTextScaleFactor(BuildContext context) {
    return MediaQuery.of(context).textScaler.scale(1.0).clamp(0.8, 2.0);
  }
}

/// Device type enum
enum DeviceType {
  mobile,
  tablet,
  desktop,
}

/// Responsive builder widget
///
/// Builds different widgets based on device type.
///
/// Usage:
/// ```dart
/// ResponsiveBuilder(
///   mobile: (context) => MobileLayout(),
///   tablet: (context) => TabletLayout(),
///   desktop: (context) => DesktopLayout(),
/// )
/// ```
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext) mobile;
  final Widget Function(BuildContext)? tablet;
  final Widget Function(BuildContext)? desktop;

  const ResponsiveBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final deviceType = ResponsiveUtils.getDeviceType(context);

        return switch (deviceType) {
          DeviceType.mobile => mobile(context),
          DeviceType.tablet => (tablet ?? mobile)(context),
          DeviceType.desktop => (desktop ?? tablet ?? mobile)(context),
        };
      },
    );
  }
}

/// Responsive padding widget
///
/// Applies responsive padding based on device type.
///
/// Usage:
/// ```dart
/// ResponsivePadding(
///   child: YourWidget(),
/// )
/// ```
class ResponsivePadding extends StatelessWidget {
  final Widget child;
  final double? mobile;
  final double? tablet;
  final double? desktop;
  final bool horizontal;
  final bool vertical;

  const ResponsivePadding({
    super.key,
    required this.child,
    this.mobile,
    this.tablet,
    this.desktop,
    this.horizontal = true,
    this.vertical = true,
  });

  @override
  Widget build(BuildContext context) {
    final padding = ResponsiveUtils.valueWhen<double>(
      context: context,
      mobile: mobile ?? 16,
      tablet: tablet ?? 24,
      desktop: desktop ?? 32,
    );

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontal ? padding : 0,
        vertical: vertical ? padding : 0,
      ),
      child: child,
    );
  }
}

/// Responsive center widget
///
/// Centers content with max width on large screens.
///
/// Usage:
/// ```dart
/// ResponsiveCenter(
///   maxWidth: 1200,
///   child: YourContent(),
/// )
/// ```
class ResponsiveCenter extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  final EdgeInsets? padding;

  const ResponsiveCenter({
    super.key,
    required this.child,
    this.maxWidth,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveMaxWidth = maxWidth ?? ResponsiveUtils.getCardMaxWidth(context);

    return Center(
      child: Container(
        constraints: effectiveMaxWidth != null
            ? BoxConstraints(maxWidth: effectiveMaxWidth)
            : null,
        padding: padding,
        child: child,
      ),
    );
  }
}

/// Responsive grid view
///
/// Grid view with responsive column count.
///
/// Usage:
/// ```dart
/// ResponsiveGridView(
///   items: items,
///   itemBuilder: (context, item) => ItemCard(item),
/// )
/// ```
class ResponsiveGridView<T> extends StatelessWidget {
  final List<T> items;
  final Widget Function(BuildContext, T) itemBuilder;
  final double spacing;
  final double runSpacing;
  final int? columnOverride;
  final ScrollPhysics? physics;

  const ResponsiveGridView({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.spacing = 16,
    this.runSpacing = 16,
    this.columnOverride,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    final columns = ResponsiveUtils.getGridColumns(
      context,
      override: columnOverride,
    );

    return GridView.builder(
      physics: physics,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: spacing,
        mainAxisSpacing: runSpacing,
        childAspectRatio: 1.0,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return itemBuilder(context, items[index]);
      },
    );
  }
}
