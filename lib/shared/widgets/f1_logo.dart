import 'package:flutter/material.dart';

/// F1Sync logo widget - Red Bull Ring circuit with double outline
class F1Logo extends StatelessWidget {
  final double size;
  final Color? color;
  final double strokeWidth;

  const F1Logo({
    super.key,
    this.size = 32,
    this.color,
    this.strokeWidth = 2.5,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _F1LogoPainter(
        color: color ?? Colors.white,
        strokeWidth: strokeWidth,
      ),
    );
  }
}

class _F1LogoPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  _F1LogoPainter({
    required this.color,
    required this.strokeWidth,
  });

  // App gradient color
  static const Color ciano = Color(0xFF00D9FF);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Paint for the rounded rectangle frame
    final framePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Draw rounded rectangle frame
    final frameRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.10, h * 0.10, w * 0.80, h * 0.80),
      Radius.circular(w * 0.18),
    );
    canvas.drawRRect(frameRect, framePaint);

    // Save canvas state for rotation
    canvas.save();

    // Rotate -12 degrees (to the left) around center
    canvas.translate(w / 2, h / 2);
    canvas.rotate(-0.22);
    canvas.translate(-w / 2, -h / 2);

    // Build the circuit path
    final path = _buildCircuitPath(size);

    // Draw outer stroke (cyan color) - thicker
    final outerPaint = Paint()
      ..color = ciano
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, outerPaint);

    // Draw inner stroke (white) - thinner, creates double line effect
    final innerPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * 0.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, innerPaint);

    // Restore canvas state
    canvas.restore();
  }

  Path _buildCircuitPath(Size size) {
    // Original SVG viewBox: 0 0 507.73479 424.50559
    const svgWidth = 507.73479;
    const svgHeight = 424.50559;

    final padding = size.width * 0.22;
    final availableSize = size.width - (padding * 2);

    final scaleX = availableSize / svgWidth;
    final scaleY = availableSize / svgHeight;
    final scale = scaleX < scaleY ? scaleX : scaleY;

    final offsetX = padding + (availableSize - svgWidth * scale) / 2;
    final offsetY = padding + (availableSize - svgHeight * scale) / 2;

    double tx(double x) => offsetX + x * scale;
    double ty(double y) => offsetY + y * scale;

    final path = Path();

    // Starting point
    double cx = 73.536;
    double cy = 15.688;
    path.moveTo(tx(cx), ty(cy));

    // All cubic bezier curves from SVG
    final curves = [
      [-14.435, -4.0011, -28.622, -6.7248, -45.138, -9.0775],
      [-31.402, -4.473, -31.4, -4.803, -0.376, 50.08],
      [30.916, 54.69, 39.767, 75.57, 44.572, 105.15],
      [1.192, 7.3369, 2.9793, 17.962, 3.9708, 23.611],
      [0.99152, 5.6492, 3.404, 20.068, 5.3607, 32.042],
      [7.1661, 43.852, 21.79, 92.7, 47.7, 159.33],
      [4.1962, 10.79, 8.2623, 22.823, 9.0346, 26.74],
      [0.77229, 3.9165, 2.1988, 8.6205, 3.1702, 10.453],
      [2.9607, 5.5862, 18.116, 6.0759, 154.85, 5.006],
      [9.1413, -0.0715, 43.638, 0.12422, 76.66, 0.43452],
      [88.734, 0.83382, 117.19, 0.56473, 125.92, -18.435],
      [0.13444, -0.27272, 0.2529, -0.55104, 0.37031, -0.83023],
      [0.0148, -0.0351, 0.0304, -0.07, 0.0449, -0.10518],
      [0.13766, -0.33428, 0.27391, -0.66868, 0.38936, -1.0113],
      [3.0637, -8.3207, 3.0282, -19.896, 2.6904, -35.957],
      [-0.93156, -44.281, -3.221, -53.497, -15.524, -62.515],
      [-16.32, -6.7748, -39.551, -12.248, -57.763, -16.802],
      [-29.086, -7.2738, -62.703, -15.704, -74.704, -18.733],
      [-94.998, -23.976, -93.051, -23.703, -118.8, -16.688],
      [-13.052, 3.5564, -14.936, 4.5129, -27.672, 14.036],
      [-22.255, 16.642, -40.402, 17.203, -53.542, 1.6574],
      [-7.067, -8.3606, -25.54, -75.477, -24.858, -90.313],
      [1.2252, -26.642, 27.751, -39.966, 54.426, -27.337],
      [63.772, 30.194, 81.594, 36.096, 104.25, 34.529],
      [29.688, -2.0536, 60.418, -20.777, 65.781, -36.966],
      [0.75703, -1.4632, 0.98851, -2.9974, 0.82058, -4.5054],
      [0.0442, -2.0672, -0.40326, -4.0574, -1.4076, -5.9253],
      [-4.2435, -7.8923, -4.1076, -7.8306, -47.416, -21.548],
      [-53.12, -16.846, -68.98, -23.35, -129.55, -53.151],
      [-47.25, -23.251, -75.707, -35.544, -103.26, -43.181],
    ];

    for (final curve in curves) {
      path.cubicTo(
        tx(cx + curve[0]), ty(cy + curve[1]),
        tx(cx + curve[2]), ty(cy + curve[3]),
        tx(cx + curve[4]), ty(cy + curve[5]),
      );
      cx += curve[4];
      cy += curve[5];
    }

    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
    final strokeWidth = logoSize * 0.08;

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: alignment,
      children: [
        F1Logo(
          size: logoSize,
          color: textColor,
          strokeWidth: strokeWidth,
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
