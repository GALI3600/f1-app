import 'package:f1sync/core/theme/f1_colors.dart';
import 'package:f1sync/features/meetings/presentation/providers/meetings_providers.dart';
import 'package:f1sync/features/meetings/presentation/widgets/gp_header_card.dart';
import 'package:f1sync/features/meetings/presentation/widgets/session_schedule_list.dart';
import 'package:f1sync/shared/widgets/error_widget.dart';
import 'package:f1sync/shared/widgets/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Meeting Detail Screen
/// Displays GP information and session schedule:
/// - GP header with country, name, dates
/// - List of all sessions (FP, Quali, Race)
/// - Session status indicators (Upcoming, Live, Completed)
/// - Tap session to view details (future implementation)
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
            // Custom App Bar with back button
            SliverAppBar(
              expandedHeight: 0,
              floating: true,
              pinned: true,
              backgroundColor: F1Colors.navyDeep,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => context.pop(),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  onPressed: () {
                    ref.invalidate(meetingDetailProvider(meetingKey));
                  },
                ),
              ],
            ),

            // GP Header Card
            SliverToBoxAdapter(
              child: GPHeaderCard(meeting: meetingDetail.meeting),
            ),

            // Sessions Section Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 24,
                      decoration: BoxDecoration(
                        color: F1Colors.ciano,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Session Schedule',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: F1Colors.textPrimary,
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
                  // Navigate to session detail (future implementation)
                  // context.push('/sessions/${session.sessionKey}');

                  // For now, show a snackbar
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Session detail for ${session.sessionName}'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ),

            // Bottom padding
            const SliverToBoxAdapter(
              child: SizedBox(height: 24),
            ),
          ],
        ),
        loading: () => const Center(child: LoadingWidget()),
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
