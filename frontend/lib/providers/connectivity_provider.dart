import 'dart:async';

import 'package:flutter/foundation.dart';

import '../services/connectivity_service.dart';

class ConnectivityProvider extends ChangeNotifier {
  ConnectivityProvider({
    ConnectivityService? connectivityService,
  }) : _connectivityService =
            connectivityService ?? ConnectivityService() {
    _initialize();
  }

  final ConnectivityService _connectivityService;

  StreamSubscription<bool>? _connectionSubscription;

  bool _isOnline = true;
  bool _isInitialized = false;

  bool get isOnline => _isOnline;
  bool get isOffline => !_isOnline;
  bool get isInitialized => _isInitialized;

  Future<void> _initialize() async {
    try {
      _isOnline = await _connectivityService.hasConnection();
      _isInitialized = true;
      notifyListeners();

      _connectionSubscription =
          _connectivityService.connectionStream.listen(
        (isOnline) {
          if (_isOnline == isOnline) {
            return;
          }

          _isOnline = isOnline;
          notifyListeners();
        },
      );
    } catch (_) {
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> refreshConnection() async {
    try {
      final isOnline =
          await _connectivityService.hasConnection();

      if (_isOnline != isOnline) {
        _isOnline = isOnline;
        notifyListeners();
      }
    } catch (_) {
      // Keep the previous connectivity state
      // if the connectivity check fails.
    }
  }

  @override
  void dispose() {
    _connectionSubscription?.cancel();
    super.dispose();
  }
}