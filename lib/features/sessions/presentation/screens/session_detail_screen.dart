import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/session_detail_provider.dart';
import '../../../session_results/presentation/providers/session_results_provider.dart';
import '../widgets/session_result_card.dart';
import '../../../../shared/widgets/live_indicator.dart';
import '../../../../shared/widgets/f1_app_bar.dart';
import '../../../../shared/widgets/f1_loading.dart';
import '../../../../shared/widgets/error_widget.dart' as custom;
import '../../../../core/theme/f1_colors.dart';

/// Session Detail Screen showing session results
///
/// Note: Weather and Race Control tabs have been removed as they are not
/// available in the Jolpica API (historical data only).
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

class _SessionDetailScreenState extends ConsumerState<SessionDetailScreen> {
  @override
  void initState() {
    super.initState();

    // Load session detail when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(sessionDetailProvider.notifier)
          .loadSessionDetail(widget.sessionKey);
    });
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
              // Results list
              Expanded(
                child: _buildResultsSection(state),
              ),
            ],
          );
        },
        loading: () => const Center(
          child: F1LoadingWidget(
            size: 50,
            color: F1Colors.ciano,
            message: 'Loading session...',
          ),
        ),
        error: (error, stack) => custom.F1ErrorWidget(
          title: 'Failed to Load Session',
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
            color: F1Colors.ciano.withValues(alpha: 0.3),
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

  Widget _buildResultsSection(SessionDetailState state) {
    final session = state.session!;
    final resultsAsync = ref.watch(sessionResultsProvider((
      sessionKey: widget.sessionKey,
      sessionType: session.sessionType,
    )));

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(sessionDetailProvider.notifier).refresh();
        ref.invalidate(sessionResultsProvider((
          sessionKey: widget.sessionKey,
          sessionType: session.sessionType,
        )));
      },
      child: resultsAsync.when(
        data: (results) {
          if (results.isEmpty) {
            final isPractice = session.sessionType.toLowerCase() == 'practice';
            return ListView(
              children: [
                const SizedBox(height: 100),
                Center(
                  child: Column(
                    children: [
                      Icon(
                        isPractice ? Icons.info_outline : Icons.hourglass_empty,
                        size: 48,
                        color: F1Colors.textSecondary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        isPractice
                            ? 'Practice sessions don\'t have official results'
                            : 'No results available yet',
                        style: const TextStyle(color: F1Colors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: results.length,
            itemBuilder: (context, index) {
              final result = results[index];
              // Match by driverId first (more reliable), then by driverNumber
              final driver = state.drivers?.cast<dynamic>().firstWhere(
                (d) => d.driverId == result.driverId ||
                    (result.driverNumber > 0 && d.driverNumber == result.driverNumber),
                orElse: () => null,
              );

              // Find fastest lap (only for finished drivers)
              final finishedResults = results.where((r) => r.finished && r.duration > 0).toList();
              final hasFastestLap = finishedResults.isNotEmpty &&
                  result.finished &&
                  result.duration > 0 &&
                  (result.fastestLapRank == 1 ||
                      finishedResults.every((r) => result.duration <= r.duration));

              return SessionResultCard(
                result: result,
                driver: driver,
                isFastestLap: hasFastestLap,
              );
            },
          );
        },
        loading: () => const Center(
          child: F1LoadingWidget(
            size: 50,
            color: F1Colors.ciano,
            message: 'Loading results...',
          ),
        ),
        error: (error, stack) => custom.F1ErrorWidget(
          title: 'Failed to Load Results',
          message: error.toString(),
          onRetry: () {
            ref.invalidate(sessionResultsProvider((
              sessionKey: widget.sessionKey,
              sessionType: session.sessionType,
            )));
          },
        ),
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
