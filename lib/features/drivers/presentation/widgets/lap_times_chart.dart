import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/f1_colors.dart';
import '../../../../core/theme/f1_text_styles.dart';
import '../../../laps/data/models/lap.dart';

/// Chart widget for displaying driver lap times
class LapTimesChart extends StatelessWidget {
  final List<Lap> laps;
  final Color lineColor;
  final Lap? fastestLap;

  const LapTimesChart({
    super.key,
    required this.laps,
    this.lineColor = F1Colors.ciano,
    this.fastestLap,
  });

  @override
  Widget build(BuildContext context) {
    if (laps.isEmpty) {
      return const Center(
        child: Text(
          'No lap data available',
          style: TextStyle(color: F1Colors.textSecondary),
        ),
      );
    }

    // Filter out pit out laps and invalid times
    final validLaps = laps
        .where((lap) => !lap.isPitOutLap && lap.lapDuration > 0)
        .toList();

    if (validLaps.isEmpty) {
      return const Center(
        child: Text(
          'No valid lap times',
          style: TextStyle(color: F1Colors.textSecondary),
        ),
      );
    }

    // Find min and max lap times for Y-axis scaling
    final minTime = validLaps
        .map((lap) => lap.lapDuration)
        .reduce((a, b) => a < b ? a : b);
    final maxTime = validLaps
        .map((lap) => lap.lapDuration)
        .reduce((a, b) => a > b ? a : b);

    // Add some padding to min/max
    final yMin = minTime - 2;
    final yMax = maxTime + 2;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Chart title and fastest lap info
          if (fastestLap != null)
            _buildFastestLapInfo(fastestLap!),

          const SizedBox(height: 16),

          // Chart
          SizedBox(
            height: 250,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  horizontalInterval: 1,
                  verticalInterval: 5,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: F1Colors.navyLight.withValues(alpha: 0.3),
                      strokeWidth: 1,
                    );
                  },
                  getDrawingVerticalLine: (value) {
                    return FlLine(
                      color: F1Colors.navyLight.withValues(alpha: 0.3),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    axisNameWidget: Text(
                      'Lap Number',
                      style: F1TextStyles.bodySmall.copyWith(
                        color: F1Colors.textSecondary,
                      ),
                    ),
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 5,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: F1TextStyles.bodySmall.copyWith(
                            color: F1Colors.textSecondary,
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    axisNameWidget: Text(
                      'Lap Time (s)',
                      style: F1TextStyles.bodySmall.copyWith(
                        color: F1Colors.textSecondary,
                      ),
                    ),
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 45,
                      interval: 2,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toStringAsFixed(0),
                          style: F1TextStyles.bodySmall.copyWith(
                            color: F1Colors.textSecondary,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(
                    color: F1Colors.navyLight.withValues(alpha: 0.3),
                  ),
                ),
                minX: validLaps.first.lapNumber.toDouble(),
                maxX: validLaps.last.lapNumber.toDouble(),
                minY: yMin,
                maxY: yMax,
                lineBarsData: [
                  LineChartBarData(
                    spots: validLaps
                        .map((lap) => FlSpot(
                              lap.lapNumber.toDouble(),
                              lap.lapDuration,
                            ))
                        .toList(),
                    isCurved: true,
                    color: lineColor,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        final lap = validLaps[index];
                        // Highlight fastest lap
                        if (fastestLap != null &&
                            lap.lapNumber == fastestLap!.lapNumber) {
                          return FlDotCirclePainter(
                            radius: 6,
                            color: F1Colors.dourado,
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          );
                        }
                        return FlDotCirclePainter(
                          radius: 3,
                          color: lineColor,
                          strokeWidth: 1,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          lineColor.withValues(alpha: 0.3),
                          lineColor.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    tooltipBgColor: F1Colors.navy,
                    tooltipBorder: BorderSide(
                      color: lineColor,
                      width: 1,
                    ),
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        final lapIndex = spot.spotIndex;
                        if (lapIndex >= validLaps.length) return null;

                        final lap = validLaps[lapIndex];
                        return LineTooltipItem(
                          'Lap ${lap.lapNumber}\n${_formatLapTime(lap.lapDuration)}',
                          F1TextStyles.bodySmall.copyWith(
                            color: Colors.white,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Legend
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildFastestLapInfo(Lap lap) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: F1Colors.navy,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: F1Colors.dourado.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.timer,
            color: F1Colors.dourado,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            'Fastest Lap: ',
            style: F1TextStyles.bodyMedium.copyWith(
              color: F1Colors.textSecondary,
            ),
          ),
          Text(
            _formatLapTime(lap.lapDuration),
            style: F1TextStyles.lapTime.copyWith(
              fontSize: 16,
              color: F1Colors.dourado,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '(Lap ${lap.lapNumber})',
            style: F1TextStyles.bodySmall.copyWith(
              color: F1Colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      children: [
        _buildLegendItem(
          color: lineColor,
          label: 'Lap Time',
        ),
        const SizedBox(width: 24),
        _buildLegendItem(
          color: F1Colors.dourado,
          label: 'Fastest Lap',
        ),
      ],
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String label,
  }) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
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

  String _formatLapTime(double seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes}:${remainingSeconds.toStringAsFixed(3).padLeft(6, '0')}';
  }
}
