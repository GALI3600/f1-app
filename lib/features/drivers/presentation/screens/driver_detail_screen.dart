import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../../../../core/theme/f1_colors.dart';
import '../../../../core/theme/f1_text_styles.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../shared/widgets/f1_loading.dart';
import '../../../../core/error/error_mapper.dart';
import '../providers/driver_detail_provider.dart';
import '../providers/driver_career_provider.dart';
import '../widgets/driver_profile_header.dart';
import '../widgets/lap_times_chart.dart';
import '../widgets/stints_timeline.dart';
import '../widgets/career_stats_card.dart';

final _logger = Logger();

/// Screen displaying detailed driver information with tabs
class DriverDetailScreen extends ConsumerStatefulWidget {
  final int driverNumber;

  const DriverDetailScreen({
    super.key,
    required this.driverNumber,
  });

  @override
  ConsumerState<DriverDetailScreen> createState() =>
      _DriverDetailScreenState();
}

class _DriverDetailScreenState extends ConsumerState<DriverDetailScreen>
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
    _logger.i('DriverDetailScreen.build() for driver #${widget.driverNumber}');

    final detailAsync = ref.watch(driverDetailNotifierProvider(
      driverNumber: widget.driverNumber,
    ));
    final isLandscape = ResponsiveUtils.isLandscape(context);

    _logger.d('detailAsync state: ${detailAsync.isLoading ? "loading" : detailAsync.hasError ? "error" : "data"}');
    if (detailAsync.hasError) {
      _logger.e('detailAsync error: ${detailAsync.error}');
      _logger.e('detailAsync stackTrace: ${detailAsync.stackTrace}');
    }

    return Scaffold(
      body: detailAsync.when(
        data: (detail) {
          _logger.i('Rendering driver detail for ${detail.driver.fullName}');
          final teamColor = _getTeamColor(detail.driver.teamColour);

          if (isLandscape) {
            return _buildLandscapeLayout(detail, teamColor);
          }
          return _buildPortraitLayout(detail, teamColor);
        },
        loading: () => const Center(
          child: F1LoadingWidget(
            size: 50,
            color: F1Colors.ciano,
            message: 'Loading driver data...',
          ),
        ),
        error: (error, stack) => Scaffold(
          appBar: AppBar(
            backgroundColor: F1Colors.navyDeep,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: ErrorMapper.mapToWidget(
            error,
            onRetry: () {
              ref.invalidate(driverDetailNotifierProvider(
                driverNumber: widget.driverNumber,
              ));
            },
          ),
        ),
      ),
    );
  }

  /// Build portrait layout with collapsing header
  Widget _buildPortraitLayout(DriverDetailData detail, Color teamColor) {
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          // App bar with driver header
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: F1Colors.navyDeep,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: DriverProfileHeader(
                driver: detail.driver,
                height: 300,
              ),
            ),
          ),

          // Tab bar
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverTabBarDelegate(
              TabBar(
                controller: _tabController,
                indicatorColor: teamColor,
                indicatorWeight: 3,
                labelColor: teamColor,
                unselectedLabelColor: F1Colors.textSecondary,
                labelStyle: F1TextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                tabs: const [
                  Tab(text: 'Profile'),
                  Tab(text: 'Lap Times'),
                  Tab(text: 'Strategy'),
                ],
              ),
              teamColor,
            ),
          ),
        ];
      },
      body: TabBarView(
        controller: _tabController,
        children: [
          // Profile tab
          _buildProfileTab(detail),

          // Lap times tab
          _buildLapTimesTab(detail, teamColor),

          // Strategy tab
          _buildStrategyTab(detail),
        ],
      ),
    );
  }

  /// Build landscape layout with side-by-side panels
  Widget _buildLandscapeLayout(DriverDetailData detail, Color teamColor) {
    return Row(
      children: [
        // Left side - Driver header (fixed)
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.35,
          child: Stack(
            children: [
              // Driver header taking full height
              Positioned.fill(
                child: DriverProfileHeader(
                  driver: detail.driver,
                  height: double.infinity,
                  isLandscape: true,
                ),
              ),

              // Back button
              Positioned(
                top: MediaQuery.of(context).padding.top + 8,
                left: 8,
                child: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ),

        // Divider
        Container(
          width: 1,
          color: teamColor.withValues(alpha: 0.3),
        ),

        // Right side - Tabs content
        Expanded(
          child: Column(
            children: [
              // Safe area padding at top
              SizedBox(height: MediaQuery.of(context).padding.top),

              // Tab bar
              Container(
                color: F1Colors.navyDeep,
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: teamColor,
                  indicatorWeight: 3,
                  labelColor: teamColor,
                  unselectedLabelColor: F1Colors.textSecondary,
                  labelStyle: F1TextStyles.bodyLarge.copyWith(
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
          ),
        ),
      ],
    );
  }

  Widget _buildProfileTab(DriverDetailData detail) {
    // Watch career stats
    final careerAsync = ref.watch(driverCareerNotifierProvider(
      driverNumber: widget.driverNumber,
    ));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Career Statistics Card (from Jolpica API)
          careerAsync.when(
            data: (career) {
              if (career == null) {
                return const SizedBox.shrink();
              }
              return Column(
                children: [
                  CareerStatsCard(career: career),
                  const SizedBox(height: 24),
                ],
              );
            },
            loading: () => Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: F1Colors.navy,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  F1WheelLoading(
                    size: 24,
                    color: F1Colors.ciano,
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Loading career stats...',
                    style: TextStyle(color: F1Colors.textSecondary),
                  ),
                ],
              ),
            ),
            error: (_, __) => const SizedBox.shrink(),
          ),

          // Session stats header
          Text(
            'Session Stats',
            style: F1TextStyles.headlineMedium,
          ),
          const SizedBox(height: 12),

          // Stats cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Laps',
                  detail.totalLaps.toString(),
                  Icons.flag,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Pit Stops',
                  detail.pitStops.toString(),
                  Icons.build,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Position',
                  detail.currentPosition?.toString() ?? 'N/A',
                  Icons.emoji_events,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Positions',
                  detail.positionChanges > 0
                      ? '+${detail.positionChanges}'
                      : detail.positionChanges.toString(),
                  detail.positionChanges > 0
                      ? Icons.trending_up
                      : Icons.trending_down,
                  valueColor: detail.positionChanges > 0
                      ? F1Colors.success
                      : detail.positionChanges < 0
                          ? F1Colors.error
                          : null,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Fastest lap card
          if (detail.fastestLap != null) ...[
            Text(
              'Fastest Lap',
              style: F1TextStyles.headlineMedium,
            ),
            const SizedBox(height: 12),
            _buildFastestLapCard(detail.fastestLap!),
            const SizedBox(height: 24),
          ],

          // Average lap time
          Text(
            'Average Lap Time',
            style: F1TextStyles.headlineMedium,
          ),
          const SizedBox(height: 12),
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

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon, {
    Color? valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: F1Colors.navy,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: F1Colors.ciano.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: F1Colors.ciano,
            size: 22,
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: F1TextStyles.displaySmall.copyWith(
              fontSize: 28,
              color: valueColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: F1TextStyles.bodyMedium.copyWith(
              color: F1Colors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFastestLapCard(lap) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: F1Colors.navy,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: F1Colors.dourado.withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.timer,
            color: F1Colors.dourado,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatLapTime(lap.lapDuration),
                  style: F1TextStyles.lapTime.copyWith(
                    color: F1Colors.dourado,
                    fontSize: 22,
                  ),
                ),
                Text(
                  'Lap ${lap.lapNumber}',
                  style: F1TextStyles.bodyMedium.copyWith(
                    color: F1Colors.textSecondary,
                    fontSize: 12,
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: F1Colors.navy,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: F1Colors.ciano.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.av_timer,
            color: F1Colors.ciano,
            size: 32,
          ),
          const SizedBox(width: 16),
          Text(
            _formatLapTime(avgTime),
            style: F1TextStyles.lapTime.copyWith(
              color: F1Colors.ciano,
              fontSize: 24,
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

/// Delegate for sticky tab bar
class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  final Color teamColor;

  _SliverTabBarDelegate(this.tabBar, this.teamColor);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: F1Colors.navyDeep,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return false;
  }
}
