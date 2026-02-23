import 'package:connectivity_plus/connectivity_plus.dart';

/// Connectivity service matching iOS Connectivity.swift and Reach.swift.
/// Singleton pattern using connectivity_plus package.
class ConnectivityService {
  ConnectivityService._();

  static ConnectivityService? _instance;
  static ConnectivityService get instance =>
      _instance ??= ConnectivityService._();

  final Connectivity _connectivity = Connectivity();

  /// Check if device is connected to network.
  /// Matches iOS Connectivity.isConnectedToNetwork() logic:
  /// Returns true if reachable (WiFi or mobile data).
  Future<bool> get isConnected async {
    final results = await _connectivity.checkConnectivity();
    return results.any((result) => result != ConnectivityResult.none);
  }

  /// Stream of connectivity changes.
  /// Matches iOS Reach.monitorReachabilityChanges() pattern.
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      _connectivity.onConnectivityChanged;
}
