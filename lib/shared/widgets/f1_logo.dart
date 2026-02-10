import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:f1sync/core/theme/f1_colors.dart';

/// F1Sync logo widget — "F1" bold + red speed bars + "SYNC" monospace
///
/// [size] controls the overall height. The logo has ~2:1 aspect ratio.
class F1Logo extends StatelessWidget {
  final double size;
  final Color? color;
  final double strokeWidth; // kept for API compat, unused

  const F1Logo({
    super.key,
    this.size = 32,
    this.color,
    this.strokeWidth = 2.5,
  });

  @override
  Widget build(BuildContext context) {
    final h = size;
    final s = h / 110; // scale factor (reference: SVG 220x110)
    final textColor = color ?? Colors.white;

    return SizedBox(
      height: h,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // F1 official logo SVG
          SvgPicture.asset(
            'assets/icons/f1_logo.svg',
            height: 42 * s,
            colorFilter: ColorFilter.mode(textColor, BlendMode.srcIn),
          ),
          SizedBox(width: 6 * s),

          // Right: speed bars + separator + SYNC
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Speed bars (decreasing width & opacity)
              _SpeedBar(width: 100 * s, height: 5 * s, opacity: 1.0),
              SizedBox(height: 8 * s),
              _SpeedBar(width: 78 * s, height: 5 * s, opacity: 0.7),
              SizedBox(height: 8 * s),
              _SpeedBar(width: 55 * s, height: 5 * s, opacity: 0.4),
              SizedBox(height: 10 * s),
              // Separator
              Container(
                width: 55 * s,
                height: 1,
                color: const Color(0xFF333333),
              ),
              SizedBox(height: 7 * s),
              // "SYNC"
              Text(
                'SYNC',
                style: TextStyle(
                  fontSize: 18 * s,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'monospace',
                  color: F1Colors.vermelho,
                  letterSpacing: 6 * s,
                  height: 1.0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Single red speed bar with rounded ends
class _SpeedBar extends StatelessWidget {
  final double width;
  final double height;
  final double opacity;

  const _SpeedBar({
    required this.width,
    required this.height,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: F1Colors.vermelho.withValues(alpha: opacity),
        borderRadius: BorderRadius.circular(height / 2),
      ),
    );
  }
}

/// F1Sync brand header with logo and text
class F1SyncBrand extends StatelessWidget {
  final double logoSize;
  final double fontSize;
  final Color? color;
  final MainAxisAlignment alignment;

  const F1SyncBrand({
    super.key,
    this.logoSize = 28,
    this.fontSize = 22,
    this.color,
    this.alignment = MainAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = color ?? Colors.white;

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: alignment,
      children: [
        F1Logo(
          size: logoSize,
          color: textColor,
        ),
        const SizedBox(width: 10),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'F1',
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w900,
                  color: textColor,
                  letterSpacing: -1,
                ),
              ),
              TextSpan(
                text: 'Sync',
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w400,
                  color: textColor.withValues(alpha: 0.9),
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
