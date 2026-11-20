import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Authentication and verification calls for the gUSo FastAPI backend.
///
/// Never put SMS provider credentials or OTP generation logic in Flutter.
/// The backend owns both processes. This service only submits user input.
class AuthService {
  const AuthService();

  // Keep this aligned with ClassificationService for local/tunnel builds.
  static const String _baseUrl = String.fromEnvironment(
    'GUSO_API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000',
  );

  static const String _tokenStorageKey = 'guso_access_token';
  static const String _displayNameStorageKey = 'guso_user_display_name';
  static final SharedPreferencesAsync _storage = SharedPreferencesAsync();

  static String? _accessToken;

  // The sidebar listens for the real account name after a successful login.
  static final ValueNotifier<String?> displayNameListenable =
      ValueNotifier<String?>(null);

  static String? get displayName => displayNameListenable.value;

  static String? _normalizeDisplayName(Object? name) {
    if (name is! String) return null;
    final cleaned = name.trim().replaceAll(RegExp(r'\s+'), ' ');
    return cleaned.isEmpty ? null : cleaned;
  }

  static String? get accessToken => _accessToken;

  static bool get hasAccessToken =>
      _accessToken != null && _accessToken!.isNotEmpty;

  static Map<String, String> get authorizationHeaders {
    if (!hasAccessToken) {
      throw StateError('No login session. Please log in.');
    }
    return {'Authorization': 'Bearer $_accessToken'};
  }

  // Restore the JWT after a Flutter Web browser refresh.
  static Future<bool> restoreSession() async {
    final storedToken = await _storage.getString(_tokenStorageKey);
    if (storedToken == null || storedToken.isEmpty) {
      _accessToken = null;
      displayNameListenable.value = null;
      await _storage.remove(_displayNameStorageKey);
      return false;
    }
    _accessToken = storedToken;
    final storedName = await _storage.getString(_displayNameStorageKey);
    displayNameListenable.value = _normalizeDisplayName(storedName);
    return true;
  }

  // Clear both the active token and the persisted copy.
  static Future<void> clearSession() async {
    _accessToken = null;
    displayNameListenable.value = null;
    await _storage.remove(_tokenStorageKey);
    await _storage.remove(_displayNameStorageKey);
  }

  // Validate a restored token using the protected history endpoint.
  Future<bool> validateSession() async {
    if (!hasAccessToken) return false;

    final response = await http
        .get(Uri.parse('$_baseUrl/history/me'), headers: authorizationHeaders)
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) return true;
    if (response.statusCode == 401) {
      await clearSession();
      return false;
    }
    throw Exception('Unable to validate login (HTTP ${response.statusCode}).');
  }

  // Keep the existing registration request and response contract.
  Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String contactNumber,
    required String password,
    required String confirmPassword,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'first_name': firstName.trim(),
        'last_name': lastName.trim(),
        'email': email.trim().isEmpty ? null : email.trim(),
        'contact_num': contactNumber.trim(),
        'password': password,
        'confirm_password': confirmPassword,
      }),
    );

    final dynamic decoded = jsonDecode(response.body);
    if (response.statusCode == 201 && decoded is Map) {
      return Map<String, dynamic>.from(decoded);
    }
    throw Exception(_errorMessage(decoded, 'Registration failed.'));
  }

  // Keep the existing JWT persistence and sidebar account-name behavior.
  Future<Map<String, dynamic>> login({
    required String identifier,
    required String password,
  }) async {
    await clearSession();

    final response = await http.post(
      Uri.parse('$_baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'identifier': identifier.trim(), 'password': password}),
    );

    final dynamic decoded = jsonDecode(response.body);
    if (response.statusCode == 200 && decoded is Map) {
      final result = Map<String, dynamic>.from(decoded);
      final token = result['access_token'];
      if (token is! String || token.isEmpty) {
        throw Exception('Login succeeded, but no JWT was returned.');
      }

      final user = result['user'];
      final name = user is Map
          ? _normalizeDisplayName(user['full_name'])
          : null;

      _accessToken = token;
      await _storage.setString(_tokenStorageKey, token);
      if (name == null) {
        await _storage.remove(_displayNameStorageKey);
      } else {
        await _storage.setString(_displayNameStorageKey, name);
      }
      displayNameListenable.value = name;
      return result;
    }
    throw Exception(_errorMessage(decoded, 'Login failed.'));
  }

  Future<void> logout() => clearSession();

  // POST /auth/otp/send: requires the REGISTERED phone and account password.
  // The OTP goes to the backend's configured delivery adapter, never to Flutter.
  Future<Map<String, dynamic>> sendRegistrationOtp({
    required String contactNumber,
    required String password,
  }) {
    return _postJson(
      '/auth/otp/send',
      {'contact_num': contactNumber.trim(), 'password': password},
      expectedStatus: 200,
      failureMessage: 'Unable to send verification code.',
    );
  }

  // POST /auth/otp/verify: backend verifies the hashed code in PostgreSQL.
  Future<Map<String, dynamic>> verifyRegistrationOtp({
    required String contactNumber,
    required String password,
    required String code,
  }) {
    return _postJson(
      '/auth/otp/verify',
      {
        'contact_num': contactNumber.trim(),
        'password': password,
        'code': code.trim(),
      },
      expectedStatus: 200,
      failureMessage: 'Unable to verify the code.',
    );
  }

  // POST /auth/otp/email/send: requires the account's registered email
  // address and password. Gmail delivery is handled entirely by FastAPI.
  Future<Map<String, dynamic>> sendEmailOtp({
    required String email,
    required String password,
  }) {
    return _postJson(
      '/auth/otp/email/send',
      {'email': email.trim().toLowerCase(), 'password': password},
      expectedStatus: 200,
      failureMessage: 'Unable to send email verification code.',
    );
  }

  // POST /auth/otp/email/verify: the backend compares the email-specific
  // hashed OTP and marks email_verified (not contact_verified) as true.
  Future<Map<String, dynamic>> verifyEmailOtp({
    required String email,
    required String password,
    required String code,
  }) {
    return _postJson(
      '/auth/otp/email/verify',
      {
        'email': email.trim().toLowerCase(),
        'password': password,
        'code': code.trim(),
      },
      expectedStatus: 200,
      failureMessage: 'Unable to verify email code.',
    );
  }

  // POST /auth/password-reset/request: always returns a generic message.
  // The code goes to the account's already-verified mobile number.
  Future<Map<String, dynamic>> requestPasswordReset({
    required String identifier,
  }) {
    return _postJson(
      '/auth/password-reset/request',
      {'identifier': identifier.trim()},
      expectedStatus: 202,
      failureMessage: 'Unable to request a recovery code.',
    );
  }

  // POST /auth/password-reset/confirm: password changes only after OTP success.
  // The backend consumes the OTP and revokes previously issued JWTs.
  Future<Map<String, dynamic>> confirmPasswordReset({
    required String identifier,
    required String code,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final result = await _postJson(
      '/auth/password-reset/confirm',
      {
        'identifier': identifier.trim(),
        'code': code.trim(),
        'new_password': newPassword,
        'confirm_password': confirmPassword,
      },
      expectedStatus: 200,
      failureMessage: 'Unable to reset your password.',
    );

    // If this browser holds a token, don't keep a revoked session locally.
    await clearSession();
    return result;
  }

  // Helper for newly added OTP/recovery requests. No JWT is required here.
  Future<Map<String, dynamic>> _postJson(
    String path,
    Map<String, dynamic> body, {
    required int expectedStatus,
    required String failureMessage,
  }) async {
    late final http.Response response;
    try {
      response = await http
          .post(
            Uri.parse('$_baseUrl$path'),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 30));
    } on TimeoutException {
      throw Exception('The request timed out. Please try again.');
    } on http.ClientException {
      throw Exception('Cannot connect to the gUSo backend.');
    }

    dynamic decoded;
    try {
      decoded = jsonDecode(response.body);
    } on FormatException {
      throw Exception(
        '$failureMessage (HTTP ${response.statusCode}; invalid server response.)',
      );
    }

    if (response.statusCode == expectedStatus && decoded is Map) {
      return Map<String, dynamic>.from(decoded);
    }
    throw Exception(
      _errorMessage(decoded, '$failureMessage (HTTP ${response.statusCode}).'),
    );
  }

  static String _errorMessage(dynamic decoded, String fallback) {
    if (decoded is Map) {
      final detail = decoded['detail'];
      if (detail is String && detail.trim().isNotEmpty) {
        return detail;
      }
      // Pydantic sends a list for validation errors (HTTP 422).
      // Never show the raw request input, which may include passwords/OTPs.
      if (detail is List && detail.isNotEmpty) {
        final first = detail.first;
        if (first is Map && first['msg'] is String) {
          return first['msg'] as String;
        }
      }
    }
    return fallback;
  }
}
