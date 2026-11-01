import 'package:flutter/material.dart';

import '../services/mock_auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final MockAuthService _authService =
      MockAuthService.instance;

  bool _isAuthenticated = false;

  bool get isAuthenticated =>
      _isAuthenticated;

  MockAuthAccount? get currentAccount =>
    _authService.currentAccount;

  String get firstName {
    final name =
        _authService.currentAccount?.firstName.trim();

    if (name == null || name.isEmpty) {
      return 'User';
    }

    return name;
  }

  bool login({
    required String identifier,
    required String password,
  }) {
    final success = _authService.login(
      identifier: identifier,
      password: password,
    );

    if (!success) {
      return false;
    }

    _isAuthenticated = true;
    notifyListeners();

    return true;
  }

  void logout() {
    _authService.logout();

    _isAuthenticated = false;

    notifyListeners();
  }
}