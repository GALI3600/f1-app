import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:f1sync/shared/services/connectivity_service.dart';
import 'package:f1sync/shared/services/providers.dart';
import 'package:f1sync/core/theme/f1_colors.dart';

/// Provider for connectivity status stream
final connectivityStatusProvider = StreamProvider<ConnectivityStatus>((ref) {
  final connectivity = ref.watch(connectivityServiceProvider);
  return connectivity.onConnectivityChanged;
});

/// Banner that appears when the device is offline
///
/// Shows a persistent banner at the top of the screen when there's no
/// internet connection, informing users that they're viewing cached data.
///
/// Features:
/// - Auto-shows when offline
/// - Auto-hides when back online
/// - Shows connection type when online
/// - Smooth animations
///
/// Usage:
/// ```dart
/// Scaffold(
///   body: Column(
///     children: [
///       const OfflineBanner(),
///       Expanded(child: YourContent()),
///     ],
///   ),
/// )
/// ```
class OfflineBanner extends ConsumerWidget {
  final bool showWhenOnline;
  final Duration animationDuration;

  const OfflineBanner({
    super.key,
    this.showWhenOnline = false,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivityAsync = ref.watch(connectivityStatusProvider);

    return connectivityAsync.when(
      data: (status) {
        final isOffline = status == ConnectivityStatus.offline;

        // Show banner only when offline (or always if showWhenOnline is true)
        if (!isOffline && !showWhenOnline) {
          return const SizedBox.shrink();
        }

        return AnimatedContainer(
          duration: animationDuration,
          height: isOffline ? 40 : 0,
          child: AnimatedOpacity(
            duration: animationDuration,
            opacity: isOffline ? 1.0 : 0.0,
            child: isOffline
                ? _buildBanner(context, status)
                : const SizedBox.shrink(),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildBanner(BuildContext context, ConnectivityStatus status) {
    final isOffline = status == ConnectivityStatus.offline;

    return Container(
      width: double.infinity,
      height: 40,
      decoration: BoxDecoration(
        color: isOffline ? F1Colors.danger : F1Colors.success,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isOffline ? Icons.cloud_off : Icons.cloud_done,
              size: 18,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Text(
              isOffline
                  ? 'No Internet - Viewing Cached Data'
                  : status.description,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Wrapper widget that shows offline message for uncached content
///
/// Use this to wrap content that requires internet and isn't available offline.
///
/// Usage:
/// ```dart
/// OfflineAwareWidget(
///   offlineMessage: 'Live timing requires internet connection',
///   child: LiveTimingWidget(),
/// )
/// ```
class OfflineAwareWidget extends ConsumerWidget {
  final Widget child;
  final String offlineMessage;
  final Widget? offlineWidget;

  const OfflineAwareWidget({
    super.key,
    required this.child,
    this.offlineMessage = 'This feature requires an internet connection',
    this.offlineWidget,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivityAsync = ref.watch(connectivityStatusProvider);

    return connectivityAsync.when(
      data: (status) {
        if (status == ConnectivityStatus.offline) {
          return offlineWidget ?? _buildOfflineMessage(context);
        }
        return child;
      },
      loading: () => child,
      error: (_, __) => child,
    );
  }

  Widget _buildOfflineMessage(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off,
              size: 64,
              color: F1Colors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              offlineMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: F1Colors.textSecondary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please check your internet connection',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: F1Colors.textTertiary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Snackbar helper for connectivity changes
class ConnectivitySnackbar {
  static void show(BuildContext context, ConnectivityStatus status) {
    final isOffline = status == ConnectivityStatus.offline;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isOffline ? Icons.cloud_off : Icons.cloud_done,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                isOffline
                    ? 'You are offline. Viewing cached data.'
                    : 'Back online!',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: isOffline ? F1Colors.danger : F1Colors.success,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
