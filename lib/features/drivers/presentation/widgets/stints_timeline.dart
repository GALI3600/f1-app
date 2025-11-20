import 'package:flutter/material.dart';
import '../../../../core/theme/f1_colors.dart';
import '../../../../core/theme/f1_text_styles.dart';
import '../../../stints/data/models/stint.dart';

/// Timeline widget for visualizing tire strategy (stints)
class StintsTimeline extends StatelessWidget {
  final List<Stint> stints;
  final int totalLaps;

  const StintsTimeline({
    super.key,
    required this.stints,
    required this.totalLaps,
  });

  Color _getCompoundColor(String compound) {
    switch (compound.toUpperCase()) {
      case 'SOFT':
        return F1Colors.soft;
      case 'MEDIUM':
        return F1Colors.medium;
      case 'HARD':
        return F1Colors.hard;
      case 'INTERMEDIATE':
        return F1Colors.intermediate;
      case 'WET':
        return F1Colors.wet;
      default:
        return F1Colors.textSecondary;
    }
  }

  String _getCompoundLabel(String compound) {
    switch (compound.toUpperCase()) {
      case 'SOFT':
        return 'S';
      case 'MEDIUM':
        return 'M';
      case 'HARD':
        return 'H';
      case 'INTERMEDIATE':
        return 'I';
      case 'WET':
        return 'W';
      default:
        return compound.substring(0, 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (stints.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            'No tire strategy data available',
            style: TextStyle(color: F1Colors.textSecondary),
          ),
        ),
      );
    }

    // Sort stints by stint number
    final sortedStints = List<Stint>.from(stints);
    sortedStints.sort((a, b) => a.stintNumber.compareTo(b.stintNumber));

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            'Tire Strategy',
            style: F1TextStyles.headlineMedium,
          ),

          const SizedBox(height: 8),

          // Summary
          Text(
            '${stints.length} stint${stints.length != 1 ? 's' : ''} • ${stints.length - 1} pit stop${stints.length - 1 != 1 ? 's' : ''}',
            style: F1TextStyles.bodyMedium.copyWith(
              color: F1Colors.textSecondary,
            ),
          ),

          const SizedBox(height: 24),

          // Timeline visualization
          Container(
            height: 80,
            decoration: BoxDecoration(
              color: F1Colors.navy,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Stack(
              children: [
                // Background grid
                Positioned.fill(
                  child: CustomPaint(
                    painter: _TimelineGridPainter(totalLaps: totalLaps),
                  ),
                ),

                // Stint bars
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 12,
                    ),
                    child: Row(
                      children: sortedStints.map((stint) {
                        final stintLaps = stint.lapEnd - stint.lapStart + 1;
                        final stintWidth = (stintLaps / totalLaps);

                        return Flexible(
                          flex: (stintWidth * 1000).round(),
                          child: _buildStintBar(stint, stintLaps),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Stint details list
          ...sortedStints.map((stint) => _buildStintCard(stint)),

          const SizedBox(height: 16),

          // Compound legend
          _buildCompoundLegend(),
        ],
      ),
    );
  }

  Widget _buildStintBar(Stint stint, int laps) {
    final compoundColor = _getCompoundColor(stint.compound);
    final compoundLabel = _getCompoundLabel(stint.compound);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: compoundColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Center(
        child: Text(
          compoundLabel,
          style: F1TextStyles.bodyMedium.copyWith(
            color: _getTextColorForBackground(compoundColor),
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  Widget _buildStintCard(Stint stint) {
    final compoundColor = _getCompoundColor(stint.compound);
    final stintLaps = stint.lapEnd - stint.lapStart + 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: F1Colors.navy,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: compoundColor.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Stint number badge
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: compoundColor,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                stint.stintNumber.toString(),
                style: F1TextStyles.headlineMedium.copyWith(
                  color: _getTextColorForBackground(compoundColor),
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Stint info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      stint.compound,
                      style: F1TextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                        color: compoundColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '($stintLaps lap${stintLaps != 1 ? 's' : ''})',
                      style: F1TextStyles.bodyMedium.copyWith(
                        color: F1Colors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Laps ${stint.lapStart} - ${stint.lapEnd} • Age: ${stint.tyreAgeAtStart} laps',
                  style: F1TextStyles.bodySmall.copyWith(
                    color: F1Colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompoundLegend() {
    final compounds = <String>{'SOFT', 'MEDIUM', 'HARD', 'INTERMEDIATE', 'WET'};
    final usedCompounds = stints
        .map((s) => s.compound.toUpperCase())
        .where((c) => compounds.contains(c))
        .toSet()
        .toList();

    if (usedCompounds.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: usedCompounds.map((compound) {
        return _buildLegendItem(
          color: _getCompoundColor(compound),
          label: compound,
        );
      }).toList(),
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String label,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: F1TextStyles.bodySmall.copyWith(
            color: F1Colors.textSecondary,
          ),
        ),
      ],
    );
  }

  Color _getTextColorForBackground(Color backgroundColor) {
    // Calculate luminance to determine if text should be black or white
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}

/// Custom painter for timeline grid
class _TimelineGridPainter extends CustomPainter {
  final int totalLaps;

  _TimelineGridPainter({required this.totalLaps});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = F1Colors.navyLight.withOpacity(0.2)
      ..strokeWidth = 1;

    // Draw vertical grid lines every 10 laps
    final interval = totalLaps > 50 ? 10 : 5;
    for (int i = 0; i <= totalLaps; i += interval) {
      final x = (i / totalLaps) * size.width;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
