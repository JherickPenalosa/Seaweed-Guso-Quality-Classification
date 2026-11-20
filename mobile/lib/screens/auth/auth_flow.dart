import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../widgets/layout/main_layout.dart';

import 'forgot_password_screen.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import 'welcome_screen.dart';

enum AuthPage { welcome, login, register, forgotPassword, verifyEmail }

class AuthFlow extends StatefulWidget {
  const AuthFlow({super.key});

  @override
  State<AuthFlow> createState() => _AuthFlowState();
}

class _AuthFlowState extends State<AuthFlow> {
  AuthPage _currentPage = AuthPage.welcome;

  void _goToWelcome() {
    setState(() {
      _currentPage = AuthPage.welcome;
    });
  }

  void _goToLogin() {
    setState(() {
      _currentPage = AuthPage.login;
    });
  }

  void _goToRegister() {
    setState(() {
      _currentPage = AuthPage.register;
    });
  }

  void _goToForgotPassword() {
    setState(() {
      _currentPage = AuthPage.forgotPassword;
    });
  }

  void _goToVerifyEmail() {
    setState(() {
      _currentPage = AuthPage.verifyEmail;
    });
  }

  void _loginSuccess() {
    context.read<AuthProvider>().syncWithBackendSession();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    if (authProvider.isAuthenticated) {
      return const MainLayout();
    }

    switch (_currentPage) {
      case AuthPage.welcome:
        return WelcomeScreen(onLogin: _goToLogin, onRegister: _goToRegister);

      case AuthPage.login:
        return LoginScreen(
          onLoginSuccess: _loginSuccess,
          onRegister: _goToRegister,
          onForgotPassword: _goToForgotPassword,
          onBack: _goToWelcome,
        );

      case AuthPage.register:
        return RegisterScreen(
          onRegistrationSuccess: _goToVerifyEmail,
          onBack: _goToLogin,
        );

      case AuthPage.forgotPassword:
        return ForgotPasswordScreen(onBackToLogin: _goToLogin);

      case AuthPage.verifyEmail:
        return _RegistrationEmailOtpScreen(
          onVerified: _goToLogin,
          onBackToLogin: _goToLogin,
        );
    }
  }
}

class _OtpRequestException implements Exception {
  const _OtpRequestException(this.message);

  final String message;
}

class _RegistrationEmailOtpScreen extends StatefulWidget {
  const _RegistrationEmailOtpScreen({
    required this.onVerified,
    required this.onBackToLogin,
  });

  final VoidCallback onVerified;
  final VoidCallback onBackToLogin;

  @override
  State<_RegistrationEmailOtpScreen> createState() =>
      _RegistrationEmailOtpScreenState();
}

class _RegistrationEmailOtpScreenState
    extends State<_RegistrationEmailOtpScreen> {
  static const String _baseUrl = String.fromEnvironment(
    'GUSO_API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000',
  );

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _codeController = TextEditingController();

  Timer? _cooldownTimer;

  bool _isSubmitting = false;
  bool _codeRequested = false;
  bool _hidePassword = true;

  int _cooldown = 0;
  String? _message;
  bool _isError = false;

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    _emailController.dispose();
    _passwordController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> _post(
    String endpoint,
    Map<String, dynamic> payload,
  ) async {
    final response = await http
        .post(
          Uri.parse('$_baseUrl$endpoint'),
          headers: const {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode(payload),
        )
        .timeout(const Duration(seconds: 30));

    Map<String, dynamic> data = {};

    try {
      final decoded = jsonDecode(response.body);

      if (decoded is Map) {
        data = Map<String, dynamic>.from(decoded);
      }
    } on FormatException {
      // Report the HTTP status for non-JSON errors.
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final detail = data['detail'];

      throw _OtpRequestException(
        detail is String
            ? detail
            : 'Request failed (HTTP ${response.statusCode}).',
      );
    }

    return data;
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
  }

  void _startCooldown() {
    _cooldownTimer?.cancel();

    setState(() {
      _cooldown = 60;
    });

    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_cooldown <= 1) {
        timer.cancel();

        setState(() {
          _cooldown = 0;
        });
      } else {
        setState(() {
          _cooldown--;
        });
      }
    });
  }

  void _showFeedback(String message, {required bool error}) {
    if (!mounted) return;

    setState(() {
      _message = message;
      _isError = error;
    });
  }

  Future<void> _sendCode() async {
    if (_isSubmitting || _cooldown > 0) return;

    FocusScope.of(context).unfocus();

    final email = _emailController.text.trim().toLowerCase();

    final password = _passwordController.text;

    if (!_isValidEmail(email)) {
      _showFeedback('Enter your registered email address.', error: true);
      return;
    }

    if (password.isEmpty) {
      _showFeedback('Enter your registered account password.', error: true);
      return;
    }

    setState(() {
      _isSubmitting = true;
      _message = null;
    });

    try {
      await _post('/auth/otp/email/send', {
        'email': email,
        'password': password,
      });

      if (!mounted) return;

      setState(() {
        _codeRequested = true;
      });

      _startCooldown();

      _showFeedback(
        'Verification code requested. '
        'Check your email inbox and Spam folder.',
        error: false,
      );
    } on _OtpRequestException catch (error) {
      _showFeedback(error.message, error: true);
    } on TimeoutException {
      _showFeedback('The request timed out. Please try again.', error: true);
    } catch (_) {
      _showFeedback(
        'Unable to communicate with the gUSo backend.',
        error: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<void> _verifyCode() async {
    if (_isSubmitting || !_codeRequested) return;

    FocusScope.of(context).unfocus();

    final code = _codeController.text.trim();

    if (!RegExp(r'^[0-9]{6}$').hasMatch(code)) {
      _showFeedback('Enter the six-digit verification code.', error: true);
      return;
    }

    setState(() {
      _isSubmitting = true;
      _message = null;
    });

    try {
      final response = await _post('/auth/otp/email/verify', {
        'email': _emailController.text.trim().toLowerCase(),
        'password': _passwordController.text,
        'code': code,
      });

      if (!mounted) return;

      if (response['email_verified'] != true ||
          response['is_verified'] != true) {
        _showFeedback('Email verification is not yet complete.', error: true);
        return;
      }

      _cooldownTimer?.cancel();

      widget.onVerified();
    } on _OtpRequestException catch (error) {
      _showFeedback(error.message, error: true);
    } on TimeoutException {
      _showFeedback('Verification timed out. Please try again.', error: true);
    } catch (_) {
      _showFeedback(
        'Unable to verify the code. Check your connection.',
        error: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  InputDecoration _fieldDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFFBFCCB7)),
      prefixIcon: Icon(icon, color: const Color(0xFF83E44D)),
      filled: true,
      fillColor: const Color(0xFF061604),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF53664C)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF83E44D), width: 1.5),
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
    );
  }

  Widget _primaryButton(String label, VoidCallback? action) {
    return SizedBox(
      height: 50,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : action,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF83E44D),
          foregroundColor: const Color(0xFF061604),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: _isSubmitting
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF061604),
                ),
              )
            : Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF001000),
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      tooltip: 'Back to Login',
                      onPressed: _isSubmitting ? null : widget.onBackToLogin,
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  const Text(
                    'gUSo',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF83E44D),
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    'Verify Your Account',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    'Enter the email address and password '
                    'you used during registration to request '
                    'your verification code.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFFBFCCB7), height: 1.5),
                  ),

                  const SizedBox(height: 28),

                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0C2108),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: const Color(0xFF52664B)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(
                          controller: _emailController,
                          enabled: !_isSubmitting && !_codeRequested,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          autocorrect: false,
                          enableSuggestions: false,
                          autofillHints: const [AutofillHints.email],
                          style: const TextStyle(color: Colors.white),
                          decoration: _fieldDecoration(
                            'Registered email address',
                            Icons.email_outlined,
                          ),
                        ),

                        const SizedBox(height: 16),

                        TextField(
                          controller: _passwordController,
                          enabled: !_isSubmitting && !_codeRequested,
                          obscureText: _hidePassword,
                          textInputAction: TextInputAction.done,
                          style: const TextStyle(color: Colors.white),
                          decoration:
                              _fieldDecoration(
                                'Account password',
                                Icons.lock_outline,
                              ).copyWith(
                                suffixIcon: IconButton(
                                  tooltip: _hidePassword
                                      ? 'Show password'
                                      : 'Hide password',
                                  icon: Icon(
                                    _hidePassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color: Colors.white70,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _hidePassword = !_hidePassword;
                                    });
                                  },
                                ),
                              ),
                        ),

                        const SizedBox(height: 22),

                        if (!_codeRequested)
                          _primaryButton('SEND EMAIL OTP', _sendCode),

                        if (_codeRequested) ...[
                          const Text(
                            'Six-digit email verification code',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          const SizedBox(height: 10),

                          TextField(
                            controller: _codeController,
                            enabled: !_isSubmitting,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.done,
                            maxLength: 6,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            autofillHints: const [AutofillHints.oneTimeCode],
                            style: const TextStyle(
                              color: Colors.white,
                              letterSpacing: 4,
                            ),
                            decoration: _fieldDecoration(
                              'Email OTP code',
                              Icons.password_outlined,
                            ).copyWith(counterText: ''),
                            onSubmitted: (_) {
                              _verifyCode();
                            },
                          ),

                          const SizedBox(height: 18),

                          _primaryButton('VERIFY EMAIL', _verifyCode),

                          const SizedBox(height: 12),

                          TextButton(
                            onPressed: _isSubmitting || _cooldown > 0
                                ? null
                                : _sendCode,
                            child: Text(
                              _cooldown > 0
                                  ? 'Resend in ${_cooldown}s'
                                  : 'Resend Email OTP',
                            ),
                          ),
                        ],

                        if (_message != null) ...[
                          const SizedBox(height: 16),

                          Text(
                            _message!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _isError
                                  ? const Color(0xFFFF7B7B)
                                  : const Color(0xFF83E44D),
                              height: 1.5,
                            ),
                          ),
                        ],

                        const SizedBox(height: 14),

                        TextButton(
                          onPressed: _isSubmitting
                              ? null
                              : widget.onBackToLogin,
                          child: const Text('Back to Login'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
