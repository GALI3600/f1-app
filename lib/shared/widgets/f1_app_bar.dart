import 'package:flutter/material.dart';
import 'package:f1sync/core/theme/f1_colors.dart';
import 'package:f1sync/core/theme/f1_gradients.dart';

/// F1-themed AppBar with gradient background
///
/// A customizable app bar following the F1 design system with gradient
/// background and consistent styling.
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

  /// Custom gradient (overrides default cyan → purple)
  final Gradient? gradient;

  /// Whether to show a bottom border
  final bool showBottomBorder;

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
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        gradient: gradient ?? F1Gradients.cianRoxo,
        border: showBottomBorder
            ? Border(
                bottom: BorderSide(
                  color: F1Colors.ciano.withOpacity(0.3),
                  width: 1,
                ),
              )
            : null,
      ),
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
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}

/// F1-themed SliverAppBar with gradient background
///
/// A scrollable app bar with gradient background following the F1 design system.
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

  /// Custom gradient (overrides default cyan → purple)
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
        letterSpacing: 0.5,
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: gradient ?? F1Gradients.cianRoxo,
          ),
          child: flexibleSpace,
        ),
      ),
    );
  }
}
