import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/f1_colors.dart';
import '../../../../core/theme/f1_text_styles.dart';
import '../../../../shared/widgets/f1_loading.dart';
import '../../../../core/error/error_mapper.dart';
import '../providers/driver_detail_provider.dart';
import '../providers/driver_career_provider.dart';
import '../providers/driver_race_history_provider.dart';
import 'driver_profile_header.dart';
import 'career_stats_card.dart';
import 'race_history_list.dart';

/// Panel widget for displaying driver details in a side panel (tablet landscape mode)
class DriverDetailPanel extends ConsumerStatefulWidget {
  final String driverId;
  final VoidCallback? onClose;

  const DriverDetailPanel({
    super.key,
    required this.driverId,
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
      return F1Colors.ciano;
    }
  }

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(driverDetailNotifierProvider(
      driverId: widget.driverId,
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
                    driverId: widget.driverId,
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
    );
  }

  Widget _buildProfileTab(DriverDetailData detail) {
    final careerAsync = ref.watch(driverCareerNotifierProvider(
      driverId: widget.driverId,
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
              return CareerStatsCard(career: career);
            },
            loading: () => Container(
              padding: const EdgeInsets.all(12),
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
          color: F1Colors.ciano,
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
