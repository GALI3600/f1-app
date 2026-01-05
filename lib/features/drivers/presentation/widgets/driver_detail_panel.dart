import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/f1_colors.dart';
import '../../../../core/theme/f1_text_styles.dart';
import '../../../../shared/widgets/f1_loading.dart';
import '../../../../core/error/error_mapper.dart';
import '../providers/driver_detail_provider.dart';
import '../providers/driver_career_provider.dart';
import 'driver_profile_header.dart';
import 'lap_times_chart.dart';
import 'stints_timeline.dart';
import 'career_stats_card.dart';

/// Panel widget for displaying driver details in a side panel (tablet landscape mode)
class DriverDetailPanel extends ConsumerStatefulWidget {
  final int driverNumber;
  final VoidCallback? onClose;

  const DriverDetailPanel({
    super.key,
    required this.driverNumber,
    this.onClose,
  });

  @override
  ConsumerState<DriverDetailPanel> createState() => _DriverDetailPanelState();
}

class _DriverDetailPanelState extends ConsumerState<DriverDetailPanel>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Color _getTeamColor(String teamColour) {
    try {
      final hex = teamColour.startsWith('#') ? teamColour : '#$teamColour';
      return Color(int.parse(hex.substring(1), radix: 16) + 0xFF000000);
    } catch (_) {
      return F1Colors.ciano;
    }
  }

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(driverDetailNotifierProvider(
      driverNumber: widget.driverNumber,
    ));

    return Container(
      color: F1Colors.navyDeep,
      child: detailAsync.when(
        data: (detail) {
          final teamColor = _getTeamColor(detail.driver.teamColour);
          return _buildContent(detail, teamColor);
        },
        loading: () => const Center(
          child: F1LoadingWidget(
            size: 50,
            color: F1Colors.ciano,
            message: 'Loading driver data...',
          ),
        ),
        error: (error, stack) => Column(
          children: [
            _buildCloseButton(),
            Expanded(
              child: ErrorMapper.mapToWidget(
                error,
                onRetry: () {
                  ref.invalidate(driverDetailNotifierProvider(
                    driverNumber: widget.driverNumber,
                  ));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCloseButton() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        right: 8,
        left: 8,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 20),
            ),
            onPressed: widget.onClose,
          ),
        ],
      ),
    );
  }

  Widget _buildContent(DriverDetailData detail, Color teamColor) {
    return Column(
      children: [
        // Driver header with close button overlay
        Stack(
          children: [
            SizedBox(
              height: 220,
              child: DriverProfileHeader(
                driver: detail.driver,
                height: 220,
                isPanelMode: true,
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              right: 8,
              child: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 20),
                ),
                onPressed: widget.onClose,
              ),
            ),
          ],
        ),

        // Tab bar
        Container(
          color: F1Colors.navyDeep,
          child: TabBar(
            controller: _tabController,
            indicatorColor: teamColor,
            indicatorWeight: 3,
            labelColor: teamColor,
            unselectedLabelColor: F1Colors.textSecondary,
            labelStyle: F1TextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
            tabs: const [
              Tab(text: 'Profile'),
              Tab(text: 'Lap Times'),
              Tab(text: 'Strategy'),
            ],
          ),
        ),

        // Tab content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildProfileTab(detail),
              _buildLapTimesTab(detail, teamColor),
              _buildStrategyTab(detail),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileTab(DriverDetailData detail) {
    final careerAsync = ref.watch(driverCareerNotifierProvider(
      driverNumber: widget.driverNumber,
    ));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Career Statistics Card
          careerAsync.when(
            data: (career) {
              if (career == null) {
                return const SizedBox.shrink();
              }
              return Column(
                children: [
                  CareerStatsCard(career: career),
                  const SizedBox(height: 16),
                ],
              );
            },
            loading: () => Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: F1Colors.navy,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  F1WheelLoading(size: 20, color: F1Colors.ciano),
                  SizedBox(width: 8),
                  Text(
                    'Loading career stats...',
                    style: TextStyle(color: F1Colors.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ),
            error: (_, __) => const SizedBox.shrink(),
          ),

          // Session stats
          Text('Session Stats', style: F1TextStyles.headlineSmall),
          const SizedBox(height: 8),

          // Stats row
          Row(
            children: [
              Expanded(child: _buildStatCard('Total Laps', detail.totalLaps.toString(), Icons.flag)),
              const SizedBox(width: 8),
              Expanded(child: _buildStatCard('Pit Stops', detail.pitStops.toString(), Icons.build)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Position',
                  detail.currentPosition?.toString() ?? 'N/A',
                  Icons.emoji_events,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  'Positions',
                  detail.positionChanges > 0
                      ? '+${detail.positionChanges}'
                      : detail.positionChanges.toString(),
                  detail.positionChanges > 0 ? Icons.trending_up : Icons.trending_down,
                  valueColor: detail.positionChanges > 0
                      ? F1Colors.success
                      : detail.positionChanges < 0
                          ? F1Colors.error
                          : null,
                ),
              ),
            ],
          ),

          // Fastest lap
          if (detail.fastestLap != null) ...[
            const SizedBox(height: 16),
            Text('Fastest Lap', style: F1TextStyles.headlineSmall),
            const SizedBox(height: 8),
            _buildFastestLapCard(detail.fastestLap!),
          ],

          // Average lap time
          const SizedBox(height: 16),
          Text('Average Lap Time', style: F1TextStyles.headlineSmall),
          const SizedBox(height: 8),
          _buildAverageLapCard(detail.averageLapTime),
        ],
      ),
    );
  }

  Widget _buildLapTimesTab(DriverDetailData detail, Color teamColor) {
    if (detail.laps.isEmpty) {
      return const Center(
        child: Text(
          'No lap data available',
          style: TextStyle(color: F1Colors.textSecondary),
        ),
      );
    }

    return SingleChildScrollView(
      child: LapTimesChart(
        laps: detail.laps,
        lineColor: teamColor,
        fastestLap: detail.fastestLap,
      ),
    );
  }

  Widget _buildStrategyTab(DriverDetailData detail) {
    if (detail.stints.isEmpty) {
      return const Center(
        child: Text(
          'No tire strategy data available',
          style: TextStyle(color: F1Colors.textSecondary),
        ),
      );
    }

    return SingleChildScrollView(
      child: StintsTimeline(
        stints: detail.stints,
        totalLaps: detail.totalLaps,
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, {Color? valueColor}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: F1Colors.navy,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: F1Colors.ciano.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: F1Colors.ciano, size: 18),
          const SizedBox(height: 4),
          Text(
            value,
            style: F1TextStyles.displaySmall.copyWith(
              fontSize: 22,
              color: valueColor,
            ),
          ),
          Text(
            label,
            style: F1TextStyles.bodySmall.copyWith(
              color: F1Colors.textSecondary,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFastestLapCard(dynamic lap) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: F1Colors.navy,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: F1Colors.dourado.withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.timer, color: F1Colors.dourado, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatLapTime(lap.lapDuration),
                  style: F1TextStyles.lapTime.copyWith(
                    color: F1Colors.dourado,
                    fontSize: 18,
                  ),
                ),
                Text(
                  'Lap ${lap.lapNumber}',
                  style: F1TextStyles.bodySmall.copyWith(
                    color: F1Colors.textSecondary,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAverageLapCard(double avgTime) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: F1Colors.navy,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: F1Colors.ciano.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.av_timer, color: F1Colors.ciano, size: 28),
          const SizedBox(width: 12),
          Text(
            _formatLapTime(avgTime),
            style: F1TextStyles.lapTime.copyWith(
              color: F1Colors.ciano,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  String _formatLapTime(double seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes}:${remainingSeconds.toStringAsFixed(3).padLeft(6, '0')}';
  }
}
