import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Network connectivity monitoring service
///
/// Provides real-time information about network connectivity status.
///
/// Features:
/// - Check current connectivity status
/// - Stream of connectivity changes
/// - Determine connection type (WiFi, Mobile, Ethernet, None)
/// - Useful for showing offline banners and disabling network features
///
/// Usage:
/// ```dart
/// final connectivity = ConnectivityService();
///
/// // Check current status
/// final isConnected = await connectivity.isConnected;
/// final status = await connectivity.currentStatus;
///
/// // Listen to changes
/// connectivity.onConnectivityChanged.listen((status) {
///   if (status == ConnectivityStatus.offline) {
///     // Show offline banner
///   }
/// });
/// ```
class ConnectivityService {
  final Connectivity _connectivity;
  StreamController<ConnectivityStatus>? _statusController;

  ConnectivityService({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  /// Get current connectivity status
  Future<ConnectivityStatus> get currentStatus async {
    final results = await _connectivity.checkConnectivity();
    return _mapToStatus(results);
  }

  /// Check if device is connected to internet
  Future<bool> get isConnected async {
    final status = await currentStatus;
    return status != ConnectivityStatus.offline;
  }

  /// Check if connected via WiFi
  Future<bool> get isWiFi async {
    final status = await currentStatus;
    return status == ConnectivityStatus.wifi;
  }

  /// Check if connected via mobile data
  Future<bool> get isMobile async {
    final status = await currentStatus;
    return status == ConnectivityStatus.mobile;
  }

  /// Check if connected via ethernet
  Future<bool> get isEthernet async {
    final status = await currentStatus;
    return status == ConnectivityStatus.ethernet;
  }

  /// Stream of connectivity status changes
  ///
  /// Emits a new status whenever the connectivity changes.
  /// The stream is broadcast and can have multiple listeners.
  Stream<ConnectivityStatus> get onConnectivityChanged {
    _statusController ??= StreamController<ConnectivityStatus>.broadcast(
      onListen: _startListening,
      onCancel: _stopListening,
    );
    return _statusController!.stream;
  }

  StreamSubscription<List<ConnectivityResult>>? _subscription;

  void _startListening() {
    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      final status = _mapToStatus(results);
      _statusController?.add(status);
    });
  }

  void _stopListening() {
    _subscription?.cancel();
    _subscription = null;
  }

  /// Map ConnectivityResult to simplified ConnectivityStatus
  ConnectivityStatus _mapToStatus(List<ConnectivityResult> results) {
    // If any connection is available, prioritize in this order:
    // WiFi > Ethernet > Mobile > VPN > Other

    if (results.contains(ConnectivityResult.wifi)) {
      return ConnectivityStatus.wifi;
    }

    if (results.contains(ConnectivityResult.ethernet)) {
      return ConnectivityStatus.ethernet;
    }

    if (results.contains(ConnectivityResult.mobile)) {
      return ConnectivityStatus.mobile;
    }

    if (results.contains(ConnectivityResult.vpn)) {
      return ConnectivityStatus.other;
    }

    if (results.contains(ConnectivityResult.other)) {
      return ConnectivityStatus.other;
    }

    // No connection
    return ConnectivityStatus.offline;
  }

  /// Dispose of resources
  void dispose() {
    _subscription?.cancel();
    _statusController?.close();
  }
}

/// Simplified connectivity status
enum ConnectivityStatus {
  /// Connected via WiFi
  wifi,

  /// Connected via mobile data
  mobile,

  /// Connected via ethernet
  ethernet,

  /// Connected via other means (VPN, Bluetooth, etc.)
  other,

  /// No internet connection
  offline;

  /// Check if connected (any type except offline)
  bool get isConnected => this != ConnectivityStatus.offline;

  /// Check if on metered connection (mobile data)
  ///
  /// Useful for deciding whether to download large files or stream video.
  bool get isMetered => this == ConnectivityStatus.mobile;

  /// Get human-readable description
  String get description {
    return switch (this) {
      ConnectivityStatus.wifi => 'Connected via WiFi',
      ConnectivityStatus.mobile => 'Connected via Mobile Data',
      ConnectivityStatus.ethernet => 'Connected via Ethernet',
      ConnectivityStatus.other => 'Connected',
      ConnectivityStatus.offline => 'No Internet Connection',
    };
  }

  /// Get icon name for UI display
  String get iconName {
    return switch (this) {
      ConnectivityStatus.wifi => 'wifi',
      ConnectivityStatus.mobile => 'signal_cellular_alt',
      ConnectivityStatus.ethernet => 'settings_ethernet',
      ConnectivityStatus.other => 'cloud',
      ConnectivityStatus.offline => 'cloud_off',
    };
  }
}
