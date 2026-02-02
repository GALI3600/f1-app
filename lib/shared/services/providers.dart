import 'package:f1sync/shared/services/cache/cache_service.dart';
import 'package:f1sync/shared/services/connectivity_service.dart';
import 'package:f1sync/shared/services/storage_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'providers.g.dart';

/// Provides the StorageService instance
///
/// Used for persistent key-value storage (user preferences, app state).
///
/// The service is initialized lazily on first access.
///
/// Usage:
/// ```dart
/// final storage = ref.watch(storageServiceProvider);
/// await storage.setString('theme', 'dark');
/// final theme = storage.getString('theme');
/// ```
@riverpod
StorageService storageService(StorageServiceRef ref) {
  final service = StorageService();

  // Initialize on first access (async initialization)
  service.init();

  return service;
}

/// Provides the CacheService instance
///
/// Used for multi-layer caching (Memory → Disk → Network).
///
/// The service is initialized lazily on first access.
/// Uses keepAlive: true to persist cache across navigation.
///
/// Usage:
/// ```dart
/// final cache = ref.watch(cacheServiceProvider);
/// final data = await cache.getCached(
///   key: 'drivers_latest',
///   ttl: Duration(hours: 1),
///   fetch: () => apiClient.getDrivers(),
/// );
/// ```
@Riverpod(keepAlive: true)
CacheService cacheService(CacheServiceRef ref) {
  final service = CacheService();

  // Initialize on first access (async initialization)
  service.init();

  // Clean up on dispose (only when app closes)
  ref.onDispose(() {
    service.close();
  });

  return service;
}

/// Provides the ConnectivityService instance
///
/// Used for monitoring network connectivity status.
///
/// Usage:
/// ```dart
/// final connectivity = ref.watch(connectivityServiceProvider);
/// final isConnected = await connectivity.isConnected;
///
/// // Listen to changes
/// ref.listen(connectivityStatusProvider, (previous, next) {
///   if (next == ConnectivityStatus.offline) {
///     // Show offline banner
///   }
/// });
/// ```
@riverpod
ConnectivityService connectivityService(ConnectivityServiceRef ref) {
  final service = ConnectivityService();

  // Clean up on dispose
  ref.onDispose(() {
    service.dispose();
  });

  return service;
}

/// Provides a stream of connectivity status changes
///
/// Emits the current connectivity status whenever it changes.
///
/// Usage:
/// ```dart
/// ref.listen(connectivityStatusProvider, (previous, next) {
///   switch (next) {
///     case AsyncData(:final value):
///       print('Connectivity: ${value.description}');
///     case AsyncError(:final error):
///       print('Error checking connectivity: $error');
///     case AsyncLoading():
///       print('Checking connectivity...');
///   }
/// });
/// ```
@riverpod
Stream<ConnectivityStatus> connectivityStatus(ConnectivityStatusRef ref) {
  final connectivity = ref.watch(connectivityServiceProvider);
  return connectivity.onConnectivityChanged;
}

/// Provides the current connectivity status as a future
///
/// Useful for one-time connectivity checks.
///
/// Usage:
/// ```dart
/// final statusAsync = ref.watch(currentConnectivityStatusProvider);
/// statusAsync.when(
///   data: (status) => Text(status.description),
///   loading: () => CircularProgressIndicator(),
///   error: (error, stack) => Text('Error: $error'),
/// );
/// ```
@riverpod
Future<ConnectivityStatus> currentConnectivityStatus(
  CurrentConnectivityStatusRef ref,
) async {
  final connectivity = ref.watch(connectivityServiceProvider);
  return await connectivity.currentStatus;
}

/// Provides whether the device is currently connected to the internet
///
/// Convenience provider for quick connectivity checks.
///
/// Usage:
/// ```dart
/// final isConnectedAsync = ref.watch(isConnectedProvider);
/// if (isConnectedAsync.value == true) {
///   // Make network request
/// }
/// ```
@riverpod
Future<bool> isConnected(IsConnectedRef ref) async {
  final connectivity = ref.watch(connectivityServiceProvider);
  return await connectivity.isConnected;
}
