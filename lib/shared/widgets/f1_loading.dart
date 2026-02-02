import 'dart:math' as math;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../core/theme/f1_colors.dart';

/// F1 Pirelli tire spinning loading animation
class F1WheelLoading extends StatefulWidget {
  final double size;
  final Color? color;
  final Duration duration;

  const F1WheelLoading({
    super.key,
    this.size = 40,
    this.color,
    this.duration = const Duration(milliseconds: 800),
  });

  @override
  State<F1WheelLoading> createState() => _F1WheelLoadingState();
}

class _F1WheelLoadingState extends State<F1WheelLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  static const String _tireImageUrl =
      'https://upload.wikimedia.org/wikipedia/commons/thumb/6/6d/F1_tire_Pirelli_empty.svg/1024px-F1_tire_Pirelli_empty.svg.png';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: _controller.value * 2 * math.pi,
          child: child,
        );
      },
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: CachedNetworkImage(
          imageUrl: _tireImageUrl,
          fit: BoxFit.contain,
          placeholder: (context, url) => const SizedBox.shrink(),
          errorWidget: (context, url, error) => Icon(
            Icons.circle_outlined,
            size: widget.size,
            color: widget.color ?? F1Colors.ciano,
          ),
        ),
      ),
    );
  }
}

/// Loading widget with F1 wheel and optional message
class F1LoadingWidget extends StatelessWidget {
  final double size;
  final Color? color;
  final String? message;

  const F1LoadingWidget({
    super.key,
    this.size = 40,
    this.color,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        F1WheelLoading(
          size: size,
          color: color,
        ),
        if (message != null) ...[
          const SizedBox(height: 16),
          Text(
            message!,
            style: TextStyle(
              color: F1Colors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ],
    );
  }
}
