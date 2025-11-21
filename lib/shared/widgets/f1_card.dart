import 'package:flutter/material.dart';
import 'package:f1sync/core/theme/f1_colors.dart';

/// F1-themed card with gradient border options
///
/// A customizable card widget following the F1 design system with support
/// for different border styles and variants.
///
/// Usage:
/// ```dart
/// F1Card(
///   child: Text('Content'),
/// )
/// ```
///
/// Variants:
/// - `F1Card.primary` - Solid cyan border
/// - `F1Card.gradient` - Gradient border (cyan → purple)
/// - `F1Card.elevated` - Larger shadow for emphasis
/// - `F1Card.outlined` - Transparent background with border only
class F1Card extends StatelessWidget {
  /// The widget to display inside the card
  final Widget child;

  /// Border variant type
  final F1CardVariant variant;

  /// Custom padding (defaults to 16px)
  final EdgeInsetsGeometry? padding;

  /// Custom margin
  final EdgeInsetsGeometry? margin;

  /// Border radius (defaults to 12px)
  final double borderRadius;

  /// Whether to show shadow
  final bool showShadow;

  /// Custom background color (overrides variant defaults)
  final Color? backgroundColor;

  /// On tap callback
  final VoidCallback? onTap;

  const F1Card({
    super.key,
    required this.child,
    this.variant = F1CardVariant.primary,
    this.padding,
    this.margin,
    this.borderRadius = 12.0,
    this.showShadow = true,
    this.backgroundColor,
    this.onTap,
  });

  /// Primary variant - Solid cyan border
  const F1Card.primary({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 12.0,
    this.showShadow = true,
    this.backgroundColor,
    this.onTap,
  }) : variant = F1CardVariant.primary;

  /// Gradient variant - Gradient border (cyan → purple)
  const F1Card.gradient({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 12.0,
    this.showShadow = true,
    this.backgroundColor,
    this.onTap,
  }) : variant = F1CardVariant.gradient;

  /// Elevated variant - Larger shadow for emphasis
  const F1Card.elevated({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 12.0,
    this.backgroundColor,
    this.onTap,
  })  : variant = F1CardVariant.elevated,
        showShadow = true;

  /// Outlined variant - Transparent background with border only
  const F1Card.outlined({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 12.0,
    this.showShadow = false,
    this.onTap,
  })  : variant = F1CardVariant.outlined,
        backgroundColor = Colors.transparent;

  @override
  Widget build(BuildContext context) {
    final effectivePadding = padding ?? const EdgeInsets.all(16.0);
    final effectiveBackgroundColor =
        backgroundColor ?? _getBackgroundColor(variant);

    Widget card = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: variant == F1CardVariant.gradient
            ? null
            : effectiveBackgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: _getBorder(variant),
        gradient: variant == F1CardVariant.gradient
            ? _getGradientBorder()
            : null,
        boxShadow: showShadow ? _getBoxShadow(variant) : null,
      ),
      child: variant == F1CardVariant.gradient
          ? _buildGradientCard(effectivePadding)
          : Padding(
              padding: effectivePadding,
              child: child,
            ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: card,
        ),
      );
    }

    return card;
  }

  /// Build gradient card with inner container
  Widget _buildGradientCard(EdgeInsetsGeometry effectivePadding) {
    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: backgroundColor ?? F1Colors.navy,
        borderRadius: BorderRadius.circular(borderRadius - 2),
      ),
      child: Padding(
        padding: effectivePadding,
        child: child,
      ),
    );
  }

  /// Get background color based on variant
  Color _getBackgroundColor(F1CardVariant variant) {
    switch (variant) {
      case F1CardVariant.outlined:
        return Colors.transparent;
      case F1CardVariant.primary:
      case F1CardVariant.gradient:
      case F1CardVariant.elevated:
        return F1Colors.navy;
    }
  }

  /// Get border based on variant
  Border? _getBorder(F1CardVariant variant) {
    switch (variant) {
      case F1CardVariant.primary:
        return Border.all(
          color: F1Colors.ciano.withValues(alpha: 0.3),
          width: 1.5,
        );
      case F1CardVariant.outlined:
        return Border.all(
          color: F1Colors.ciano.withValues(alpha: 0.5),
          width: 1.5,
        );
      case F1CardVariant.gradient:
      case F1CardVariant.elevated:
        return null;
    }
  }

  /// Get gradient for border (used in gradient variant)
  LinearGradient _getGradientBorder() {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        F1Colors.ciano.withValues(alpha: 0.5),
        F1Colors.roxo.withValues(alpha: 0.5),
      ],
    );
  }

  /// Get box shadow based on variant
  List<BoxShadow> _getBoxShadow(F1CardVariant variant) {
    switch (variant) {
      case F1CardVariant.elevated:
        return [
          BoxShadow(
            color: F1Colors.ciano.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: F1Colors.roxo.withValues(alpha: 0.1),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ];
      case F1CardVariant.primary:
      case F1CardVariant.gradient:
        return [
          BoxShadow(
            color: F1Colors.ciano.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ];
      case F1CardVariant.outlined:
        return [];
    }
  }
}

/// F1Card variant types
enum F1CardVariant {
  /// Solid cyan border with navy background
  primary,

  /// Gradient border (cyan → purple) with navy background
  gradient,

  /// Navy background with larger shadow
  elevated,

  /// Transparent background with cyan border
  outlined,
}
