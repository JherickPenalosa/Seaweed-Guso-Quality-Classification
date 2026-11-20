import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class MobileAuthException implements Exception {
  final String message;
  final int? statusCode;

  const MobileAuthException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

/// Authentication and OTP integration for gUSo Mobile.
///
/// This service communicates directly with FastAPI and does not
/// depend on ClassificationService methods that might not exist
/// in the current mobile application.
///
/// JWTs are temporarily kept in memory. Classification and
/// History will be connected to this session separately.
class MobileAuthService {
  const MobileAuthService();

  static const String baseUrl = String.fromEnvironment(
    'GUSO_API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000',
  );

  static const Duration _timeout = Duration(seconds: 30);

  static String? _accessToken;

  static String? get accessToken => _accessToken;

  static bool get isLoggedIn =>
      _accessToken != null && _accessToken!.isNotEmpty;

  static Map<String, String> get authorizationHeaders {
    if (!isLoggedIn) {
      throw const MobileAuthException(
        'Please log in to your gUSo account first.',
      );
    }

    return {'Authorization': 'Bearer $_accessToken'};
  }

  static Uri _url(String path) {
    final root = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;

    return Uri.parse('$root$path');
  }

  /// POST /auth/register
  ///
  /// Email is optional. Contact number remains required.
  Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    String? email,
    required String contactNumber,
    required String password,
    required String confirmPassword,
  }) {
    final normalizedEmail = email?.trim().toLowerCase();

    return _postJson('/auth/register', {
      'first_name': firstName.trim(),
      'last_name': lastName.trim(),
      'email': normalizedEmail == null || normalizedEmail.isEmpty
          ? null
          : normalizedEmail,
      'contact_num': contactNumber.trim(),
      'password': password,
      'confirm_password': confirmPassword,
    }, expectedStatus: 201);
  }

  /// POST /auth/otp/email/send
  Future<Map<String, dynamic>> sendEmailOtp({
    required String email,
    required String password,
  }) {
    return _postJson('/auth/otp/email/send', {
      'email': email.trim().toLowerCase(),
      'password': password,
    }, expectedStatus: 200);
  }

  /// POST /auth/otp/email/verify
  Future<Map<String, dynamic>> verifyEmailOtp({
    required String email,
    required String password,
    required String code,
  }) {
    _validateCode(code);

    return _postJson('/auth/otp/email/verify', {
      'email': email.trim().toLowerCase(),
      'password': password,
      'code': code.trim(),
    }, expectedStatus: 200);
  }

  /// POST /auth/otp/send
  Future<Map<String, dynamic>> sendSmsOtp({
    required String contactNumber,
    required String password,
  }) {
    return _postJson('/auth/otp/send', {
      'contact_num': contactNumber.trim(),
      'password': password,
    }, expectedStatus: 200);
  }

  /// POST /auth/otp/verify
  Future<Map<String, dynamic>> verifySmsOtp({
    required String contactNumber,
    required String password,
    required String code,
  }) {
    _validateCode(code);

    return _postJson('/auth/otp/verify', {
      'contact_num': contactNumber.trim(),
      'password': password,
      'code': code.trim(),
    }, expectedStatus: 200);
  }

  /// POST /auth/login
  ///
  /// Authenticate through FastAPI and store the returned JWT.
  Future<void> login({
    required String identifier,
    required String password,
  }) async {
    if (identifier.trim().isEmpty || password.isEmpty) {
      throw const MobileAuthException(
        'Please enter your email/contact number and password.',
      );
    }

    // Clear the old session before starting another login.
    logout();

    final result = await _postJson('/auth/login', {
      'identifier': identifier.trim(),
      'password': password,
    }, expectedStatus: 200);

    final token = result['access_token'];

    if (token is! String || token.trim().isEmpty) {
      throw const MobileAuthException(
        'Login succeeded, but FastAPI returned no access token.',
      );
    }

    _accessToken = token;
  }

  /// Clear the temporary authentication session.
  void logout() {
    _accessToken = null;
  }

  /// POST /auth/password-reset/request
  Future<Map<String, dynamic>> requestPasswordReset({
    required String identifier,
  }) {
    return _postJson('/auth/password-reset/request', {
      'identifier': identifier.trim(),
    }, expectedStatus: 202);
  }

  /// POST /auth/password-reset/confirm
  Future<Map<String, dynamic>> confirmPasswordReset({
    required String identifier,
    required String code,
    required String newPassword,
    required String confirmPassword,
  }) async {
    _validateCode(code);

    final result = await _postJson('/auth/password-reset/confirm', {
      'identifier': identifier.trim(),
      'code': code.trim(),
      'new_password': newPassword,
      'confirm_password': confirmPassword,
    }, expectedStatus: 200);

    logout();

    return result;
  }

  /// Validate the six-digit code before sending the request.
  static void _validateCode(String code) {
    if (!RegExp(r'^\d{6}$').hasMatch(code.trim())) {
      throw const MobileAuthException(
        'Please enter a valid six-digit verification code.',
      );
    }
  }

  /// Shared HTTP helper for all authentication endpoints.
  Future<Map<String, dynamic>> _postJson(
    String path,
    Map<String, dynamic> payload, {
    required int expectedStatus,
  }) async {
    late final http.Response response;

    try {
      response = await http
          .post(
            _url(path),
            headers: const {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(payload),
          )
          .timeout(_timeout);
    } on TimeoutException {
      throw const MobileAuthException(
        'The backend request timed out. Please try again.',
      );
    } on SocketException {
      throw const MobileAuthException(
        'Cannot reach FastAPI. Check the Android connection.',
      );
    } on http.ClientException {
      throw const MobileAuthException(
        'Unable to communicate with the gUSo backend.',
      );
    }

    late final dynamic decoded;

    try {
      decoded = jsonDecode(response.body);
    } on FormatException {
      throw MobileAuthException(
        'FastAPI returned invalid JSON (HTTP ${response.statusCode}).',
        statusCode: response.statusCode,
      );
    }

    if (response.statusCode == expectedStatus && decoded is Map) {
      return Map<String, dynamic>.from(decoded);
    }

    throw MobileAuthException(
      _extractError(decoded, response.statusCode),
      statusCode: response.statusCode,
    );
  }

  /// Extract FastAPI error messages without exposing request data.
  static String _extractError(dynamic body, int statusCode) {
    if (body is Map) {
      final detail = body['detail'];

      if (detail is String && detail.trim().isNotEmpty) {
        return detail;
      }

      if (detail is List && detail.isNotEmpty) {
        final first = detail.first;

        if (first is Map && first['msg'] is String) {
          return first['msg'] as String;
        }
      }
    }

    return 'Request failed (HTTP $statusCode).';
  }
}
