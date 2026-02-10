import 'package:flutter/material.dart';
import 'package:f1sync/core/theme/f1_colors.dart';

/// F1-themed AppBar with flat dark background
///
/// A customizable app bar following the minimalist F1 design system.
///
/// Usage:
/// ```dart
/// F1AppBar(
///   title: 'F1 Sync',
/// )
/// ```
class F1AppBar extends StatelessWidget implements PreferredSizeWidget {
  /// The title to display in the app bar
  final String? title;

  /// Optional title widget (overrides title string)
  final Widget? titleWidget;

  /// Leading widget (typically back button or menu icon)
  final Widget? leading;

  /// Actions to display on the trailing side
  final List<Widget>? actions;

  /// Whether to center the title (defaults to true for F1 style)
  final bool centerTitle;

  /// Height of the app bar (defaults to 56px)
  final double height;

  /// Custom gradient (ignored — kept for API compat)
  final Gradient? gradient;

  /// Whether to show a bottom border
  final bool showBottomBorder;

  /// Background color behind rounded corners (ignored — kept for API compat)
  final Color? cornerBackgroundColor;

  /// Background color for left corner only (ignored — kept for API compat)
  final Color? cornerBackgroundColorLeft;

  const F1AppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.leading,
    this.actions,
    this.centerTitle = true,
    this.height = 56.0,
    this.gradient,
    this.showBottomBorder = false,
    this.cornerBackgroundColor,
    this.cornerBackgroundColorLeft,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: height,
          color: F1Colors.navyDeep,
          child: AppBar(
            title: titleWidget ?? (title != null ? Text(title!) : null),
            leading: leading,
            actions: actions,
            centerTitle: centerTitle,
            backgroundColor: Colors.transparent,
            elevation: 0,
            foregroundColor: F1Colors.textPrimary,
            iconTheme: const IconThemeData(
              color: F1Colors.textPrimary,
            ),
            titleTextStyle: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: F1Colors.textPrimary,
              fontFamily: 'Formula1',
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          height: 1,
          color: F1Colors.border,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height + 1);
}

/// F1-themed SliverAppBar with flat dark background
///
/// A scrollable app bar following the minimalist F1 design system.
///
/// Usage:
/// ```dart
/// CustomScrollView(
///   slivers: [
///     F1SliverAppBar(
///       title: 'F1 Sync',
///       expandedHeight: 200,
///     ),
///   ],
/// )
/// ```
class F1SliverAppBar extends StatelessWidget {
  /// The title to display in the app bar
  final String? title;

  /// Optional title widget (overrides title string)
  final Widget? titleWidget;

  /// Leading widget (typically back button or menu icon)
  final Widget? leading;

  /// Actions to display on the trailing side
  final List<Widget>? actions;

  /// Whether to center the title
  final bool centerTitle;

  /// Height of the expanded app bar
  final double expandedHeight;

  /// Whether the app bar is pinned when collapsed
  final bool pinned;

  /// Whether the app bar is floating
  final bool floating;

  /// Custom gradient (ignored — kept for API compat)
  final Gradient? gradient;

  /// Optional flexible space widget
  final Widget? flexibleSpace;

  const F1SliverAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.leading,
    this.actions,
    this.centerTitle = true,
    this.expandedHeight = 200.0,
    this.pinned = true,
    this.floating = false,
    this.gradient,
    this.flexibleSpace,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      title: titleWidget ?? (title != null ? Text(title!) : null),
      leading: leading,
      actions: actions,
      centerTitle: centerTitle,
      expandedHeight: expandedHeight,
      pinned: pinned,
      floating: floating,
      backgroundColor: F1Colors.navyDeep,
      elevation: 0,
      foregroundColor: F1Colors.textPrimary,
      iconTheme: const IconThemeData(
        color: F1Colors.textPrimary,
      ),
      titleTextStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: F1Colors.textPrimary,
        letterSpacing: 0.5,
      ),
      flexibleSpace: flexibleSpace != null
          ? FlexibleSpaceBar(
              background: Container(
                color: F1Colors.navyDeep,
                child: flexibleSpace,
              ),
            )
          : null,
    );
  }
}
