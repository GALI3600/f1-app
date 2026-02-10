import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../providers/session_detail_provider.dart';
import '../../../session_results/presentation/providers/session_results_provider.dart';
import '../widgets/session_result_card.dart';
import '../../../../shared/widgets/live_indicator.dart';
import '../../../../shared/widgets/f1_loading.dart';
import '../../../../shared/widgets/error_widget.dart' as custom;
import '../../../../core/theme/f1_colors.dart';
import '../../../../core/theme/f1_text_styles.dart';

/// Session Detail Screen showing session results
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
      backgroundColor: F1Colors.navyDeep,
      body: sessionDetailState.when(
        data: (state) {
          if (state.session == null) {
            return const Center(
              child: Text(
                'Session not found',
                style: TextStyle(color: F1Colors.textSecondary),
              ),
            );
          }

          return CustomScrollView(
            slivers: [
              // Custom SliverAppBar
              _buildAppBar(state),

              // Session header card
              SliverToBoxAdapter(
                child: _buildSessionHeader(state),
              ),

              // Results header
              SliverToBoxAdapter(
                child: _buildResultsHeader(state),
              ),

              // Results list
              _buildResultsList(state),

              // Bottom padding
              const SliverToBoxAdapter(
                child: SizedBox(height: 24),
              ),
            ],
          );
        },
        loading: () => const Center(
          child: F1LoadingWidget(
            size: 50,
            color: F1Colors.textSecondary,
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

  Widget _buildAppBar(SessionDetailState state) {
    final session = state.session!;
    final isLive = _isSessionLive(session);

    return SliverAppBar(
      floating: true,
      pinned: true,
      backgroundColor: F1Colors.navyDeep,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        session.sessionName,
        style: F1TextStyles.headlineSmall.copyWith(
          fontWeight: FontWeight.w700,
          fontSize: 17,
        ),
      ),
      actions: [
        if (isLive)
          const Padding(
            padding: EdgeInsets.only(right: 4),
            child: LiveIndicator(),
          ),
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: () {
            ref.read(sessionDetailProvider.notifier).refresh();
          },
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: F1Colors.border),
      ),
    );
  }

  Widget _buildSessionHeader(SessionDetailState state) {
    final session = state.session!;
    final accentColor = _getSessionAccentColor(session.sessionType);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: F1Colors.navy,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: F1Colors.border, width: 1),
      ),
      child: Row(
        children: [
          // Session type icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: accentColor.withValues(alpha: 0.25),
                width: 1,
              ),
            ),
            child: Icon(
              _getSessionIcon(session.sessionType),
              color: accentColor,
              size: 24,
            ),
          ),

          const SizedBox(width: 14),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Session type label
                Text(
                  session.sessionType.toUpperCase(),
                  style: F1TextStyles.labelSmall.copyWith(
                    color: accentColor,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                    fontSize: 11,
                  ),
                ),

                const SizedBox(height: 4),

                // Circuit + country
                Text(
                  '${session.circuitShortName} \u2022 ${session.countryName}',
                  style: F1TextStyles.bodyMedium.copyWith(
                    color: F1Colors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 4),

                // Date + time
                Row(
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      size: 13,
                      color: F1Colors.textTertiary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDateRange(session.dateStart, session.dateEnd),
                      style: F1TextStyles.bodySmall.copyWith(
                        color: F1Colors.textTertiary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsHeader(SessionDetailState state) {
    final session = state.session!;
    final resultsAsync = ref.watch(sessionResultsProvider((
      sessionKey: widget.sessionKey,
      sessionType: session.sessionType,
    )));

    final count = resultsAsync.whenOrNull(data: (r) => r.length) ?? 0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 22,
            decoration: BoxDecoration(
              color: F1Colors.vermelho,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'Results',
            style: F1TextStyles.headlineSmall.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          if (count > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: F1Colors.navyLight.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '$count',
                style: F1TextStyles.labelSmall.copyWith(
                  color: F1Colors.textSecondary,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildResultsList(SessionDetailState state) {
    final session = state.session!;
    final resultsAsync = ref.watch(sessionResultsProvider((
      sessionKey: widget.sessionKey,
      sessionType: session.sessionType,
    )));

    return resultsAsync.when(
      data: (results) {
        if (results.isEmpty) {
          final isPractice = session.sessionType.toLowerCase() == 'practice';
          return SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 48),
              child: Column(
                children: [
                  Icon(
                    isPractice ? Icons.info_outline_rounded : Icons.hourglass_empty_rounded,
                    size: 44,
                    color: F1Colors.textTertiary,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    isPractice
                        ? 'Practice sessions don\'t have official results'
                        : 'No results available yet',
                    style: F1TextStyles.bodyMedium.copyWith(
                      color: F1Colors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final result = results[index];
              final driver = state.drivers?.cast<dynamic>().firstWhere(
                (d) =>
                    d.driverId == result.driverId ||
                    (result.driverNumber > 0 &&
                        d.driverNumber == result.driverNumber),
                orElse: () => null,
              );

              final finishedResults =
                  results.where((r) => r.finished && r.duration > 0).toList();
              final hasFastestLap = finishedResults.isNotEmpty &&
                  result.finished &&
                  result.duration > 0 &&
                  (result.fastestLapRank == 1 ||
                      finishedResults
                          .every((r) => result.duration <= r.duration));

              return SessionResultCard(
                result: result,
                driver: driver,
                isFastestLap: hasFastestLap,
              );
            },
            childCount: results.length,
          ),
        );
      },
      loading: () => const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 48),
          child: Center(
            child: F1LoadingWidget(
              size: 50,
              color: F1Colors.textSecondary,
              message: 'Loading results...',
            ),
          ),
        ),
      ),
      error: (error, stack) => SliverToBoxAdapter(
        child: custom.F1ErrorWidget(
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

  Color _getSessionAccentColor(String sessionType) {
    switch (sessionType.toLowerCase()) {
      case 'practice':
        return F1Colors.textSecondary;
      case 'qualifying':
      case 'sprint qualifying':
        return F1Colors.dourado;
      case 'sprint':
        return F1Colors.roxo;
      case 'race':
        return F1Colors.vermelho;
      default:
        return F1Colors.textSecondary;
    }
  }

  IconData _getSessionIcon(String sessionType) {
    switch (sessionType.toLowerCase()) {
      case 'practice':
        return Icons.build_rounded;
      case 'qualifying':
      case 'sprint qualifying':
        return Icons.timer_rounded;
      case 'sprint':
        return Icons.bolt_rounded;
      case 'race':
        return Icons.emoji_events_rounded;
      default:
        return Icons.event_rounded;
    }
  }

  String _formatDateRange(DateTime start, DateTime end) {
    final datePart = DateFormat('dd MMM yyyy').format(start);
    final startTime = DateFormat('HH:mm').format(start);
    final endTime = DateFormat('HH:mm').format(end);
    return '$datePart \u2022 $startTime - $endTime';
  }
}
