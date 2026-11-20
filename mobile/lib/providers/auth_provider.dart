import 'package:flutter/material.dart';

import '../services/mobile_auth_service.dart';
import '../services/mock_auth_service.dart';

/// Authentication state for gUSo Mobile.
///
/// Real authentication is performed by the FastAPI backend.
/// The JWT session is owned by MobileAuthService.
///
/// The legacy MockAuthAccount getter is temporarily retained
/// for compatibility with existing mobile widgets.
class AuthProvider extends ChangeNotifier {
  final MobileAuthService _authService = const MobileAuthService();

  /// The user is authenticated only when the backend
  /// authentication service has an access token.
  bool get isAuthenticated => MobileAuthService.isLoggedIn;

  /// Legacy compatibility getter.
  ///
  /// A mock account must never be treated as the currently
  /// authenticated backend user.
  ///
  /// Backend profile integration will replace this later.
  MockAuthAccount? get currentAccount => null;

  /// Temporary fallback until the authenticated user profile
  /// is connected to FastAPI.
  String get firstName => 'User';

  /// Perform real authentication through FastAPI.
  ///
  /// Returns true only when FastAPI accepts the credentials
  /// and provides a JWT access token.
  Future<bool> login({
    required String identifier,
    required String password,
  }) async {
    try {
      await _authService.login(identifier: identifier, password: password);

      notifyListeners();

      return isAuthenticated;
    } on MobileAuthException {
      notifyListeners();
      return false;
    } catch (_) {
      notifyListeners();
      return false;
    }
  }

  /// Refresh widgets that depend on authentication state.
  ///
  /// Use this when a screen logs in directly through
  /// MobileAuthService instead of AuthProvider.login().
  void syncWithBackendSession() {
    notifyListeners();
  }

  /// Logout from the shared backend authentication session.
  ///
  /// Removes the temporary JWT and notifies the application.
  void logout() {
    _authService.logout();

    notifyListeners();
  }
}
