import 'package:f1sync/core/theme/f1_colors.dart';
import 'package:f1sync/core/theme/f1_text_styles.dart';
import 'package:f1sync/features/meetings/presentation/providers/meetings_providers.dart';
import 'package:f1sync/features/meetings/presentation/widgets/gp_header_card.dart';
import 'package:f1sync/features/meetings/presentation/widgets/session_schedule_list.dart';
import 'package:f1sync/shared/widgets/error_widget.dart';
import 'package:f1sync/shared/widgets/f1_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Meeting Detail Screen
/// Displays GP information and session schedule:
/// - GP header with flag, name, circuit, dates
/// - List of all sessions with type-specific accents
/// - Session status indicators (Upcoming, Live, Completed)
/// - Tap session to view details
class MeetingDetailScreen extends ConsumerWidget {
  final int meetingKey;

  const MeetingDetailScreen({
    super.key,
    required this.meetingKey,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meetingDetailAsync = ref.watch(meetingDetailProvider(meetingKey));

    return Scaffold(
      backgroundColor: F1Colors.navyDeep,
      body: meetingDetailAsync.when(
        data: (meetingDetail) => CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              floating: true,
              pinned: true,
              backgroundColor: F1Colors.navyDeep,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => context.pop(),
              ),
              title: Text(
                meetingDetail.meeting.meetingName,
                style: F1TextStyles.headlineSmall.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  onPressed: () {
                    ref.invalidate(meetingDetailProvider(meetingKey));
                  },
                ),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1),
                child: Container(height: 1, color: F1Colors.border),
              ),
            ),

            // GP Header Card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: GPHeaderCard(meeting: meetingDetail.meeting),
              ),
            ),

            // Sessions Section Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 4),
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
                      'Sessions',
                      style: F1TextStyles.headlineSmall.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: F1Colors.navyLight.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${meetingDetail.sessions.length}',
                        style: F1TextStyles.labelSmall.copyWith(
                          color: F1Colors.textSecondary,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Sessions List
            SliverToBoxAdapter(
              child: SessionScheduleList(
                sessions: meetingDetail.sessions,
                onSessionTap: (session) {
                  context.push('/sessions/${session.sessionKey}');
                },
              ),
            ),

            // Bottom padding
            const SliverToBoxAdapter(
              child: SizedBox(height: 24),
            ),
          ],
        ),
        loading: () => const Center(
          child: F1LoadingWidget(
            size: 50,
            color: F1Colors.textSecondary,
            message: 'Loading meeting...',
          ),
        ),
        error: (error, stack) => Center(
          child: F1ErrorWidget(
            title: 'Error Loading Meeting',
            message: error.toString(),
            errorDetails: stack.toString(),
            showDetails: true,
            onRetry: () {
              ref.invalidate(meetingDetailProvider(meetingKey));
            },
          ),
        ),
      ),
    );
  }
}
