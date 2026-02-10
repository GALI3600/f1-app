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
import '../providers/driver_race_history_provider.dart';
import '../widgets/driver_profile_header.dart';
import '../widgets/career_stats_card.dart';
import '../widgets/race_history_list.dart';

final _logger = Logger();

/// Screen displaying detailed driver information with tabs
class DriverDetailScreen extends ConsumerStatefulWidget {
  final String driverId;

  const DriverDetailScreen({
    super.key,
    required this.driverId,
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
    _tabController = TabController(length: 2, vsync: this);
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
      return F1Colors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    _logger.i('DriverDetailScreen.build() for driver #${widget.driverId}');

    final detailAsync = ref.watch(driverDetailNotifierProvider(
      driverId: widget.driverId,
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
            color: F1Colors.textSecondary,
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
                driverId: widget.driverId,
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
                  Tab(text: 'Race History'),
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

          // Race history tab
          _buildRaceHistoryTab(teamColor),
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
                    Tab(text: 'Race History'),
                  ],
                ),
              ),

              // Tab content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildProfileTab(detail),
                    _buildRaceHistoryTab(teamColor),
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
      driverId: widget.driverId,
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
              return CareerStatsCard(career: career);
            },
            loading: () => Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: F1Colors.navy,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  F1WheelLoading(
                    size: 24,
                    color: F1Colors.textSecondary,
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
        ],
      ),
    );
  }

  Widget _buildRaceHistoryTab(Color teamColor) {
    final historyAsync = ref.watch(driverRaceHistoryNotifierProvider(
      driverId: widget.driverId,
    ));

    return historyAsync.when(
      data: (results) => RaceHistoryList(
        results: results,
        teamColor: teamColor,
      ),
      loading: () => const Center(
        child: F1LoadingWidget(
          size: 40,
          color: F1Colors.textSecondary,
          message: 'Loading race history...',
        ),
      ),
      error: (error, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: F1Colors.vermelho,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load race history',
              style: F1TextStyles.bodyMedium.copyWith(
                color: F1Colors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                ref.invalidate(driverRaceHistoryNotifierProvider(
                  driverId: widget.driverId,
                ));
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
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
