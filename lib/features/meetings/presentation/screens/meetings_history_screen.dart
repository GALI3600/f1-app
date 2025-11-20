import 'package:f1sync/features/meetings/presentation/providers/meetings_providers.dart';
import 'package:f1sync/features/meetings/presentation/widgets/gp_list_tile.dart';
import 'package:f1sync/features/meetings/presentation/widgets/year_selector.dart';
import 'package:f1sync/shared/widgets/f1_app_bar.dart';
import 'package:f1sync/shared/widgets/f1_error_widget.dart';
import 'package:f1sync/shared/widgets/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Meetings History Screen
/// Browse Grand Prix by year with:
/// - Year selector (2023-2025)
/// - Filterable list of GPs
/// - Tap to navigate to detail
class MeetingsHistoryScreen extends ConsumerWidget {
  const MeetingsHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedYear = ref.watch(selectedYearProvider);
    final meetingsAsync = ref.watch(meetingsListProvider(selectedYear));

    return Scaffold(
      appBar: F1AppBar(
        title: 'Grand Prix History',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Refresh the meetings list
              ref.invalidate(meetingsListProvider(selectedYear));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),

          // Year Selector
          YearSelector(
            selectedYear: selectedYear,
            onYearChanged: (year) {
              ref.read(selectedYearProvider.notifier).setYear(year);
            },
          ),

          const SizedBox(height: 16),

          // Meetings List
          Expanded(
            child: meetingsAsync.when(
              data: (meetings) {
                if (meetings.isEmpty) {
                  return _buildEmptyState(selectedYear);
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(meetingsListProvider(selectedYear));
                  },
                  child: ListView.builder(
                    itemCount: meetings.length,
                    itemBuilder: (context, index) {
                      final meeting = meetings[index];
                      return GPListTile(
                        meeting: meeting,
                        onTap: () {
                          // Navigate to meeting detail
                          context.push(
                            '/meetings/${meeting.meetingKey}',
                          );
                        },
                      );
                    },
                  ),
                );
              },
              loading: () => const LoadingWidget(),
              error: (error, stack) => F1ErrorWidget(
                error: error,
                stackTrace: stack,
                onRetry: () {
                  ref.invalidate(meetingsListProvider(selectedYear));
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(int year) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.event_busy,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'No Grand Prix found for $year',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Try selecting a different year',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
