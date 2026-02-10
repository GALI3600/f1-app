import 'package:flutter/material.dart';
import 'package:f1sync/core/theme/f1_colors.dart';
import 'package:f1sync/core/theme/f1_text_styles.dart';

/// F1-themed live indicator with pulsing animation
///
/// Displays a pulsing red dot with optional "LIVE" label to indicate live sessions.
///
/// Usage:
/// ```dart
/// LiveIndicator()
/// ```
///
/// With label:
/// ```dart
/// LiveIndicator.withLabel()
/// ```
class LiveIndicator extends StatefulWidget {
  /// Size of the indicator dot
  final double size;

  /// Color of the indicator
  final Color color;

  /// Whether to show the "LIVE" label
  final bool showLabel;

  /// Animation duration (full cycle)
  final Duration duration;

  /// Optional custom label text
  final String? labelText;

  /// Label position relative to dot
  final LiveIndicatorLabelPosition labelPosition;

  const LiveIndicator({
    super.key,
    this.size = 8.0,
    this.color = F1Colors.vermelho,
    this.showLabel = false,
    this.duration = const Duration(milliseconds: 1500),
    this.labelText,
    this.labelPosition = LiveIndicatorLabelPosition.right,
  });

  /// Live indicator with label
  const LiveIndicator.withLabel({
    super.key,
    this.size = 8.0,
    this.color = F1Colors.vermelho,
    this.duration = const Duration(milliseconds: 1500),
    this.labelText,
    this.labelPosition = LiveIndicatorLabelPosition.right,
  }) : showLabel = true;

  /// Large live indicator with label
  const LiveIndicator.large({
    super.key,
    this.size = 12.0,
    this.color = F1Colors.vermelho,
    this.showLabel = true,
    this.duration = const Duration(milliseconds: 1500),
    this.labelText,
    this.labelPosition = LiveIndicatorLabelPosition.right,
  });

  @override
  State<LiveIndicator> createState() => _LiveIndicatorState();
}

class _LiveIndicatorState extends State<LiveIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    // Scale animation from 1.0 to 1.3
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    // Opacity animation for glow effect
    _opacityAnimation = Tween<double>(
      begin: 0.8,
      end: 0.3,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final indicator = AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.size * 2.5,
          height: widget.size * 2.5,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: _opacityAnimation.value),
                blurRadius: widget.size * 1.5,
                spreadRadius: widget.size * 0.5,
              ),
            ],
          ),
          child: Center(
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  color: widget.color,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        );
      },
    );

    if (!widget.showLabel) {
      return indicator;
    }

    final label = Text(
      widget.labelText ?? 'LIVE',
      style: F1TextStyles.liveIndicator,
    );

    switch (widget.labelPosition) {
      case LiveIndicatorLabelPosition.right:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            indicator,
            const SizedBox(width: 8),
            label,
          ],
        );
      case LiveIndicatorLabelPosition.left:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            label,
            const SizedBox(width: 8),
            indicator,
          ],
        );
      case LiveIndicatorLabelPosition.top:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            label,
            const SizedBox(height: 4),
            indicator,
          ],
        );
      case LiveIndicatorLabelPosition.bottom:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            indicator,
            const SizedBox(height: 4),
            label,
          ],
        );
    }
  }
}

/// Position of the label relative to the indicator dot
enum LiveIndicatorLabelPosition {
  /// Label on the right side
  right,

  /// Label on the left side
  left,

  /// Label on top
  top,

  /// Label on bottom
  bottom,
}

/// Live indicator badge
///
/// A badge-style live indicator with background for better visibility.
class LiveIndicatorBadge extends StatelessWidget {
  /// Background color of the badge
  final Color backgroundColor;

  /// Text color
  final Color textColor;

  /// Indicator color
  final Color indicatorColor;

  /// Badge padding
  final EdgeInsetsGeometry padding;

  /// Border radius
  final double borderRadius;

  /// Custom label text
  final String? labelText;

  const LiveIndicatorBadge({
    super.key,
    this.backgroundColor = F1Colors.vermelho,
    this.textColor = F1Colors.textPrimary,
    this.indicatorColor = F1Colors.textPrimary,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    this.borderRadius = 4.0,
    this.labelText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          LiveIndicator(
            size: 6.0,
            color: indicatorColor,
          ),
          const SizedBox(width: 6),
          Text(
            labelText ?? 'LIVE',
            style: F1TextStyles.labelSmall.copyWith(
              color: textColor,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

/// Session status indicator
///
/// Shows different states for sessions (live, upcoming, finished).
class SessionStatusIndicator extends StatelessWidget {
  /// Status of the session
  final SessionStatus status;

  /// Custom label text (overrides default status text)
  final String? labelText;

  /// Whether to show the indicator dot
  final bool showDot;

  const SessionStatusIndicator({
    super.key,
    required this.status,
    this.labelText,
    this.showDot = true,
  });

  @override
  Widget build(BuildContext context) {
    final statusConfig = _getStatusConfig(status);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showDot) ...[
          if (status == SessionStatus.live)
            LiveIndicator(
              size: 6.0,
              color: statusConfig.color,
            )
          else
            Container(
              width: 6.0,
              height: 6.0,
              decoration: BoxDecoration(
                color: statusConfig.color,
                shape: BoxShape.circle,
              ),
            ),
          const SizedBox(width: 8),
        ],
        Text(
          labelText ?? statusConfig.label,
          style: F1TextStyles.labelMedium.copyWith(
            color: statusConfig.color,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }

  /// Get configuration for status
  _SessionStatusConfig _getStatusConfig(SessionStatus status) {
    switch (status) {
      case SessionStatus.live:
        return _SessionStatusConfig(
          label: 'LIVE',
          color: F1Colors.vermelho,
        );
      case SessionStatus.upcoming:
        return _SessionStatusConfig(
          label: 'UPCOMING',
          color: F1Colors.textSecondary,
        );
      case SessionStatus.finished:
        return _SessionStatusConfig(
          label: 'FINISHED',
          color: F1Colors.textSecondary,
        );
      case SessionStatus.scheduled:
        return _SessionStatusConfig(
          label: 'SCHEDULED',
          color: F1Colors.warning,
        );
    }
  }
}

/// Session status enum
enum SessionStatus {
  /// Session is currently live
  live,

  /// Session is upcoming
  upcoming,

  /// Session has finished
  finished,

  /// Session is scheduled
  scheduled,
}

/// Session status configuration
class _SessionStatusConfig {
  final String label;
  final Color color;

  _SessionStatusConfig({
    required this.label,
    required this.color,
  });
}
