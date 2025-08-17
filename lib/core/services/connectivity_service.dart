import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Service for managing network connectivity status
/// 
/// Provides real-time connectivity monitoring and offline/online state management
/// for the Nefer e-commerce app's offline-first architecture.
class ConnectivityService {
  final Connectivity _connectivity;
  
  StreamController<bool>? _connectivityController;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  
  bool _isConnected = true;
  bool _hasBeenInitialized = false;

  ConnectivityService(this._connectivity);

  /// Stream of connectivity status changes
  Stream<bool> get connectivityStream {
    _connectivityController ??= StreamController<bool>.broadcast();
    
    if (!_hasBeenInitialized) {
      _initializeConnectivity();
    }
    
    return _connectivityController!.stream;
  }

  /// Current connectivity status
  bool get isConnected => _isConnected;

  /// Initialize connectivity monitoring
  Future<void> _initializeConnectivity() async {
    _hasBeenInitialized = true;
    
    // Check initial connectivity
    final result = await _connectivity.checkConnectivity();
    _updateConnectionStatus(result);
    
    // Listen for connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _updateConnectionStatus,
      onError: (error) {
        print('Connectivity error: $error');
        _updateConnectionStatus(ConnectivityResult.none);
      },
    );
  }

  /// Update connection status based on connectivity result
  void _updateConnectionStatus(ConnectivityResult result) {
    final wasConnected = _isConnected;
    _isConnected = result != ConnectivityResult.none;
    
    // Only emit if status changed
    if (wasConnected != _isConnected) {
      _connectivityController?.add(_isConnected);
      print('Connectivity changed: ${_isConnected ? 'Online' : 'Offline'}');
    }
  }

  /// Check if device is currently connected to internet
  Future<bool> checkConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _updateConnectionStatus(result);
      return _isConnected;
    } catch (e) {
      print('Error checking connectivity: $e');
      return false;
    }
  }

  /// Get detailed connectivity information
  Future<ConnectivityInfo> getConnectivityInfo() async {
    try {
      final result = await _connectivity.checkConnectivity();
      return ConnectivityInfo(
        isConnected: result != ConnectivityResult.none,
        connectionType: _getConnectionType(result),
        result: result,
      );
    } catch (e) {
      print('Error getting connectivity info: $e');
      return ConnectivityInfo(
        isConnected: false,
        connectionType: ConnectionType.none,
        result: ConnectivityResult.none,
      );
    }
  }

  /// Convert ConnectivityResult to ConnectionType
  ConnectionType _getConnectionType(ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.wifi:
        return ConnectionType.wifi;
      case ConnectivityResult.mobile:
        return ConnectionType.mobile;
      case ConnectivityResult.ethernet:
        return ConnectionType.ethernet;
      case ConnectivityResult.bluetooth:
        return ConnectionType.bluetooth;
      case ConnectivityResult.vpn:
        return ConnectionType.vpn;
      case ConnectivityResult.other:
        return ConnectionType.other;
      case ConnectivityResult.none:
      default:
        return ConnectionType.none;
    }
  }

  /// Dispose resources
  void dispose() {
    _connectivitySubscription?.cancel();
    _connectivityController?.close();
  }
}

/// Detailed connectivity information
class ConnectivityInfo {
  final bool isConnected;
  final ConnectionType connectionType;
  final ConnectivityResult result;

  const ConnectivityInfo({
    required this.isConnected,
    required this.connectionType,
    required this.result,
  });

  @override
  String toString() {
    return 'ConnectivityInfo(isConnected: $isConnected, type: $connectionType)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ConnectivityInfo &&
        other.isConnected == isConnected &&
        other.connectionType == connectionType &&
        other.result == result;
  }

  @override
  int get hashCode {
    return isConnected.hashCode ^ connectionType.hashCode ^ result.hashCode;
  }
}

/// Connection type enumeration
enum ConnectionType {
  none,
  wifi,
  mobile,
  ethernet,
  bluetooth,
  vpn,
  other,
}

extension ConnectionTypeExtension on ConnectionType {
  /// Get human-readable name
  String get displayName {
    switch (this) {
      case ConnectionType.none:
        return 'No Connection';
      case ConnectionType.wifi:
        return 'WiFi';
      case ConnectionType.mobile:
        return 'Mobile Data';
      case ConnectionType.ethernet:
        return 'Ethernet';
      case ConnectionType.bluetooth:
        return 'Bluetooth';
      case ConnectionType.vpn:
        return 'VPN';
      case ConnectionType.other:
        return 'Other';
    }
  }

  /// Check if connection is metered (mobile data)
  bool get isMetered {
    return this == ConnectionType.mobile;
  }

  /// Check if connection is high-speed
  bool get isHighSpeed {
    return this == ConnectionType.wifi || 
           this == ConnectionType.ethernet;
  }

  /// Check if connection is reliable for large downloads
  bool get isReliableForDownloads {
    return this == ConnectionType.wifi || 
           this == ConnectionType.ethernet;
  }
}
