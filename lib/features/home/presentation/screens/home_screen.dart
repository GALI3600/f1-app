import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:f1sync/core/theme/f1_colors.dart';
import 'package:f1sync/core/theme/f1_text_styles.dart';
import 'package:f1sync/core/constants/app_constants.dart';
import 'package:f1sync/features/home/presentation/providers/current_gp_provider.dart';
import 'package:f1sync/features/home/presentation/providers/current_session_provider.dart';
import 'package:f1sync/features/home/presentation/providers/standings_provider.dart';
import 'package:f1sync/features/home/presentation/widgets/current_gp_card.dart';
import 'package:f1sync/features/home/presentation/widgets/quick_stats_card.dart';
import 'package:f1sync/features/home/presentation/widgets/navigation_card.dart';
import 'package:f1sync/shared/widgets/loading_widget.dart';
import 'package:f1sync/shared/widgets/error_widget.dart';
import 'package:f1sync/shared/widgets/live_indicator.dart';
import 'package:f1sync/shared/widgets/f1_logo.dart';

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
    final standingsAsync = ref.watch(currentStandingsProvider);

    return Scaffold(
      // Gradient AppBar using F1 colors
      appBar: AppBar(
        centerTitle: false,
        toolbarHeight: 72,
        title: const F1Logo(
          size: 64,
          color: Colors.white,
        ),
        backgroundColor: F1Colors.navyDeep,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: F1Colors.border),
        ),
        actions: [
          // Live indicator (if session is active)
          sessionAsync.whenOrNull(
            data: (session) => session != null
                ? const Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: LiveIndicator(),
                  )
                : null,
          ) ?? const SizedBox.shrink(),
          // Settings button
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () => context.go('/settings'),
            tooltip: 'Configurações',
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
            ref.refresh(currentStandingsProvider.future),
          ]);
        },
        color: F1Colors.vermelho,
        backgroundColor: F1Colors.navy,
        child: OrientationBuilder(
          builder: (context, orientation) {
            final isLandscape = orientation == Orientation.landscape;

            if (isLandscape) {
              return _buildLandscapeLayout(
                context,
                gpAsync,
                standingsAsync,
                sessionAsync,
              );
            }

            return _buildPortraitLayout(
              context,
              gpAsync,
              standingsAsync,
              sessionAsync,
            );
          },
        ),
      ),
    );
  }

  /// Build portrait layout (vertical scroll)
  Widget _buildPortraitLayout(
    BuildContext context,
    AsyncValue gpAsync,
    AsyncValue standingsAsync,
    AsyncValue sessionAsync,
  ) {
    return SingleChildScrollView(
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
          _buildQuickStatsSection(standingsAsync, sessionAsync),
          const SizedBox(height: 24),

          // Navigation Grid
          NavigationGrid(
            onNavigate: (route) => context.go(route),
          ),

          // Bottom spacing
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  /// Build landscape layout (side-by-side panels)
  Widget _buildLandscapeLayout(
    BuildContext context,
    AsyncValue gpAsync,
    AsyncValue standingsAsync,
    AsyncValue sessionAsync,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left panel - GP Card and Stats
        Expanded(
          flex: 2,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome message - compact
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome to F1Sync',
                            style: F1TextStyles.headlineSmall.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Your Formula 1 companion',
                            style: F1TextStyles.bodySmall.copyWith(
                              color: F1Colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Current GP Card
                _buildCurrentGPSection(gpAsync),
                const SizedBox(height: 16),

                // Quick Stats Section
                _buildQuickStatsSection(standingsAsync, sessionAsync),
              ],
            ),
          ),
        ),

        // Divider
        Container(
          width: 1,
          color: F1Colors.border,
        ),

        // Right panel - Navigation Grid
        Expanded(
          flex: 3,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quick Access',
                  style: F1TextStyles.headlineSmall.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                NavigationGrid(
                  onNavigate: (route) => context.go(route),
                  crossAxisCount: 2,
                  showTitle: false,
                ),
              ],
            ),
          ),
        ),
      ],
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
    AsyncValue standingsAsync,
    AsyncValue sessionAsync,
  ) {
    // Combine both async values to show stats
    return standingsAsync.when(
      data: (standings) {
        // Get session name if available
        final sessionName = sessionAsync.whenOrNull(
          data: (session) => session?.sessionName as String?,
        );

        return QuickStatsCard(
          standings: standings,
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
