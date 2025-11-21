import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/session_detail_provider.dart';
import '../../session_results/presentation/providers/session_results_provider.dart';
import '../widgets/session_result_card.dart';
import '../widgets/weather_widget.dart';
import '../widgets/race_control_feed.dart';
import '../../../../shared/widgets/live_indicator.dart';
import '../../../../shared/widgets/f1_app_bar.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/error_widget.dart' as custom;
import '../../../../core/theme/f1_colors.dart';

/// Session Detail Screen with tabbed view of session data
class SessionDetailScreen extends ConsumerStatefulWidget {
  final int sessionKey;

  const SessionDetailScreen({
    super.key,
    required this.sessionKey,
  });

  @override
  ConsumerState<SessionDetailScreen> createState() =>
      _SessionDetailScreenState();
}

class _SessionDetailScreenState extends ConsumerState<SessionDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  RaceControlFilter _raceControlFilter = RaceControlFilter.all;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Load session detail when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(sessionDetailProvider.notifier)
          .loadSessionDetail(widget.sessionKey);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sessionDetailState = ref.watch(sessionDetailProvider);

    return Scaffold(
      appBar: _buildAppBar(sessionDetailState),
      body: sessionDetailState.when(
        data: (state) {
          if (state.session == null) {
            return const Center(
              child: Text('Session not found'),
            );
          }

          return Column(
            children: [
              // Session header info
              _buildSessionHeader(state),
              // Tab bar
              _buildTabBar(),
              // Tab views
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildResultsTab(state),
                    _buildWeatherTab(state),
                    _buildRaceControlTab(state),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const LoadingWidget(),
        error: (error, stack) => custom.F1ErrorWidget(
          message: error.toString(),
          onRetry: () {
            ref
                .read(sessionDetailProvider.notifier)
                .loadSessionDetail(widget.sessionKey);
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(AsyncValue<SessionDetailState> state) {
    final session = state.valueOrNull?.session;

    return F1AppBar(
      title: session?.sessionName ?? 'Session Details',
      actions: [
        // Refresh button
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () {
            ref.read(sessionDetailProvider.notifier).refresh();
          },
        ),
      ],
    );
  }

  Widget _buildSessionHeader(SessionDetailState state) {
    final session = state.session!;
    final isLive = _isSessionLive(session);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: F1Colors.navy,
        border: Border(
          bottom: BorderSide(
            color: F1Colors.ciano.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.sessionType,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: F1Colors.ciano,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${session.circuitShortName} • ${session.countryName}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              if (isLive) const LiveIndicator(),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 16,
                color: F1Colors.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                _formatDateRange(session.dateStart, session.dateEnd),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: F1Colors.textSecondary,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: F1Colors.navyDeep,
        border: Border(
          bottom: BorderSide(
            color: F1Colors.ciano.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorColor: F1Colors.ciano,
        labelColor: F1Colors.ciano,
        unselectedLabelColor: F1Colors.textSecondary,
        tabs: const [
          Tab(text: 'Results', icon: Icon(Icons.emoji_events)),
          Tab(text: 'Weather', icon: Icon(Icons.wb_sunny)),
          Tab(text: 'Race Control', icon: Icon(Icons.message)),
        ],
      ),
    );
  }

  Widget _buildResultsTab(SessionDetailState state) {
    final resultsAsync = ref.watch(sessionResultsProvider(widget.sessionKey));

    return RefreshIndicator(
      onRefresh: () async {
        await ref
            .read(sessionDetailProvider.notifier)
            .refresh();
        ref.invalidate(sessionResultsProvider(widget.sessionKey));
      },
      child: resultsAsync.when(
        data: (results) {
          if (results.isEmpty) {
            return const Center(
              child: Text('No results available yet'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: results.length,
            itemBuilder: (context, index) {
              final result = results[index];
              final driver = state.drivers?.firstWhere(
                (d) => d.driverNumber == result.driverNumber,
                orElse: () => null as dynamic,
              );

              // Find fastest lap
              final fastestLap = results.reduce((a, b) =>
                  a.duration < b.duration && !a.dnf && !a.dns && !a.dsq
                      ? a
                      : b);

              return SessionResultCard(
                result: result,
                driver: driver,
                isFastestLap: result.driverNumber == fastestLap.driverNumber,
              );
            },
          );
        },
        loading: () => const LoadingWidget(),
        error: (error, stack) => custom.F1ErrorWidget(
          message: error.toString(),
          onRetry: () {
            ref.invalidate(sessionResultsProvider(widget.sessionKey));
          },
        ),
      ),
    );
  }

  Widget _buildWeatherTab(SessionDetailState state) {
    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(sessionDetailProvider.notifier).refresh();
      },
      child: state.weather == null || state.weather!.isEmpty
          ? const Center(
              child: Text('No weather data available'),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.weather!.length,
              itemBuilder: (context, index) {
                // Reverse to show latest first
                final weather =
                    state.weather![state.weather!.length - 1 - index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: WeatherWidget(weather: weather),
                );
              },
            ),
    );
  }

  Widget _buildRaceControlTab(SessionDetailState state) {
    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(sessionDetailProvider.notifier).refresh();
      },
      child: state.raceControl == null || state.raceControl!.isEmpty
          ? const Center(
              child: Text('No race control messages'),
            )
          : RaceControlFeed(
              messages: state.raceControl!,
              drivers: state.drivers,
              filter: _raceControlFilter,
              onFilterChanged: (filter) {
                setState(() {
                  _raceControlFilter = filter;
                });
              },
            ),
    );
  }

  bool _isSessionLive(dynamic session) {
    final now = DateTime.now();
    return now.isAfter(session.dateStart) && now.isBefore(session.dateEnd);
  }

  String _formatDateRange(DateTime start, DateTime end) {
    final localStart = start.toLocal();
    final localEnd = end.toLocal();

    final startStr =
        '${localStart.day}/${localStart.month} ${localStart.hour}:${localStart.minute.toString().padLeft(2, '0')}';
    final endStr =
        '${localEnd.hour}:${localEnd.minute.toString().padLeft(2, '0')}';

    return '$startStr - $endStr';
  }
}
