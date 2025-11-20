import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:f1sync/core/theme/f1_colors.dart';
import 'package:f1sync/core/theme/f1_text_styles.dart';
import 'package:f1sync/core/theme/f1_gradients.dart';
import 'package:f1sync/core/constants/app_constants.dart';
import 'package:f1sync/features/home/presentation/providers/current_gp_provider.dart';
import 'package:f1sync/features/home/presentation/providers/current_session_provider.dart';
import 'package:f1sync/features/home/presentation/providers/current_drivers_provider.dart';
import 'package:f1sync/features/home/presentation/widgets/current_gp_card.dart';
import 'package:f1sync/features/home/presentation/widgets/quick_stats_card.dart';
import 'package:f1sync/features/home/presentation/widgets/navigation_card.dart';
import 'package:f1sync/shared/widgets/loading_widget.dart';
import 'package:f1sync/shared/widgets/error_widget.dart';
import 'package:f1sync/shared/widgets/live_indicator.dart';

/// Home Screen - F1Sync Dashboard
///
/// Main dashboard showing:
/// - Current/Next Grand Prix
/// - Quick statistics
/// - Navigation grid
/// - Live session indicator (when active)
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch all providers
    final gpAsync = ref.watch(currentGPProvider);
    final sessionAsync = ref.watch(currentSessionProvider);
    final driversAsync = ref.watch(currentDriversProvider);

    return Scaffold(
      // Gradient AppBar using F1 colors
      appBar: AppBar(
        title: ShaderMask(
          shaderCallback: (bounds) => F1Gradients.main.createShader(bounds),
          child: const Text(
            'F1Sync',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: F1Gradients.cianRoxo,
          ),
        ),
        actions: [
          // Live indicator (if session is active)
          sessionAsync.whenOrNull(
            data: (session) => session != null
                ? const Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: LiveIndicator(isLive: true),
                  )
                : null,
          ) ?? const SizedBox.shrink(),

          // Settings icon
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () {
              // TODO: Navigate to settings
            },
          ),
        ],
      ),

      // Main content with pull-to-refresh
      body: RefreshIndicator(
        onRefresh: () async {
          // Refresh all providers
          await Future.wait([
            ref.refresh(currentGPProvider.future),
            ref.refresh(currentSessionProvider.future),
            ref.refresh(currentDriversProvider.future),
          ]);
        },
        color: F1Colors.ciano,
        backgroundColor: F1Colors.navy,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome message
              Text(
                'Welcome to F1Sync',
                style: F1TextStyles.headlineMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Your Formula 1 companion',
                style: F1TextStyles.bodyMedium.copyWith(
                  color: F1Colors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),

              // Current GP Card
              _buildCurrentGPSection(gpAsync),
              const SizedBox(height: 24),

              // Quick Stats Section
              _buildQuickStatsSection(driversAsync, sessionAsync),
              const SizedBox(height: 24),

              // Navigation Grid
              const NavigationGrid(),

              // Bottom spacing
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  /// Build the Current GP section with loading/error/data states
  Widget _buildCurrentGPSection(AsyncValue gpAsync) {
    return gpAsync.when(
      data: (meeting) => CurrentGPCard(
        meeting: meeting,
        onTap: () {
          // TODO: Navigate to GP details
        },
      ),
      loading: () => const LoadingWidget.card(height: 200),
      error: (error, stackTrace) => F1ErrorWidget(
        title: 'Failed to load current GP',
        message: error.toString(),
        onRetry: () {
          // The RefreshIndicator will handle the retry
        },
      ),
    );
  }

  /// Build the Quick Stats section with loading/error/data states
  Widget _buildQuickStatsSection(
    AsyncValue driversAsync,
    AsyncValue sessionAsync,
  ) {
    // Combine both async values to show stats
    return driversAsync.when(
      data: (drivers) {
        // Get session name if available
        final sessionName = sessionAsync.whenOrNull(
          data: (session) => session?.sessionName,
        );

        return QuickStatsCard(
          drivers: drivers,
          sessionName: sessionName,
          onStatTap: (statType) {
            // TODO: Navigate to appropriate screen based on stat type
            switch (statType) {
              case 'leader':
              case 'drivers':
                // Navigate to drivers list
                break;
              case 'teams':
                // Navigate to teams list
                break;
              case 'session':
                // Navigate to session details
                break;
            }
          },
        );
      },
      loading: () => const LoadingWidget.card(height: 180),
      error: (error, stackTrace) => F1CompactErrorWidget(
        message: 'Failed to load statistics',
        onRetry: () {
          // The RefreshIndicator will handle the retry
        },
      ),
    );
  }
}
