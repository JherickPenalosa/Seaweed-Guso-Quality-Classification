import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/theme.dart';
import '../../services/auth_service.dart';

enum ForgotPasswordReturnAction { login, register }

enum _RecoveryStage { requestCode, resetPassword }

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key, this.onRecoverySubmitted});

  // Kept for compatibility with the existing LandingScreen (File 112).
  // The old landing callback displays a placeholder and is deliberately
  // not called; this screen now handles both recovery API requests itself.
  final void Function(String identifier)? onRecoverySubmitted;

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final AuthService _authService = const AuthService();
  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  _RecoveryStage _stage = _RecoveryStage.requestCode;
  String _requestedIdentifier = '';
  String? _feedback;
  bool _busy = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;
  int _resendSeconds = 0;
  Timer? _resendTimer;

  @override
  void dispose() {
    _resendTimer?.cancel();
    _identifierController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _backToLanding(ForgotPasswordReturnAction action) {
    if (_busy) return;
    Navigator.of(context).pop(action);
  }

  void _showFeedback(String message) {
    if (!mounted) return;
    setState(() => _feedback = message);
  }

  String _messageFrom(Object error) {
    final text = error.toString();
    return text.startsWith('Exception: ')
        ? text.substring('Exception: '.length)
        : text;
  }

  void _startResendCooldown() {
    _resendTimer?.cancel();
    setState(() => _resendSeconds = 60);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_resendSeconds <= 1) {
        timer.cancel();
        setState(() => _resendSeconds = 0);
      } else {
        setState(() => _resendSeconds--);
      }
    });
  }

  Future<void> _requestCode({bool resend = false}) async {
    if (_busy || (resend && _resendSeconds > 0)) return;

    final identifier = resend
        ? _requestedIdentifier
        : _identifierController.text.trim();

    if (identifier.length < 5) {
      _showFeedback('Enter your registered email or contact number.');
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _busy = true;
      _feedback = null;
    });

    try {
      await _authService.requestPasswordReset(identifier: identifier);
      if (!mounted) return;
      setState(() {
        _requestedIdentifier = identifier;
        _stage = _RecoveryStage.resetPassword;
        _codeController.clear();
        _feedback =
            'If this account has a verified recovery number, '
            'a six-digit code will be sent to it. Enter the code below.';
      });
      _startResendCooldown();
    } catch (error) {
      _showFeedback(_messageFrom(error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _confirmReset() async {
    if (_busy) return;

    final code = _codeController.text.trim();
    final newPassword = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (!RegExp(r'^\d{6}$').hasMatch(code)) {
      _showFeedback('Enter exactly six digits from your recovery code.');
      return;
    }
    if (newPassword.length < 8 || newPassword.length > 128) {
      _showFeedback('The new password must be 8–128 characters long.');
      return;
    }
    if (newPassword != confirmPassword) {
      _showFeedback('The passwords do not match.');
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _busy = true;
      _feedback = null;
    });

    try {
      await _authService.confirmPasswordReset(
        identifier: _requestedIdentifier,
        code: code,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );
      if (!mounted) return;

      // Do not retain the OTP or new password after a successful reset.
      _codeController.clear();
      _passwordController.clear();
      _confirmPasswordController.clear();

      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text(
            'Password updated',
            style: TextStyle(color: AppColors.textPrimary),
          ),
          content: const Text(
            'Your password was reset successfully. '
            'Please log in with your new password.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.black,
              ),
              child: const Text('RETURN TO LOGIN'),
            ),
          ],
        ),
      );
      if (!mounted) return;
      Navigator.of(context).pop(ForgotPasswordReturnAction.login);
    } catch (error) {
      _showFeedback(_messageFrom(error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _editIdentifier() {
    if (_busy) return;
    _resendTimer?.cancel();
    _codeController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();
    setState(() {
      _stage = _RecoveryStage.requestCode;
      _requestedIdentifier = '';
      _resendSeconds = 0;
      _feedback = null;
    });
  }

  InputDecoration _inputDecoration(String hint, IconData icon) =>
      InputDecoration(hintText: hint, prefixIcon: Icon(icon));

  Widget _primaryAction({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _busy ? null : onPressed,
        style: ButtonStyle(
          elevation: const WidgetStatePropertyAll(0),
          backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.disabled)) {
              return AppColors.primaryDark;
            }
            if (states.contains(WidgetState.hovered)) return Colors.white;
            return AppColors.primary;
          }),
          foregroundColor: const WidgetStatePropertyAll(Colors.black),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.medium),
            ),
          ),
        ),
        icon: _busy
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(icon),
        label: Text(_busy ? 'PLEASE WAIT...' : label),
      ),
    );
  }

  Widget _requestForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Enter the email or contact number associated with your gUSo '
          'account. A recovery code can only be sent to its previously '
          'verified mobile number.',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 15,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 28),
        TextField(
          controller: _identifierController,
          enabled: !_busy,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          style: const TextStyle(color: AppColors.textPrimary),
          onSubmitted: (_) => _requestCode(),
          decoration: _inputDecoration(
            'Email or contact number',
            Icons.person_search_outlined,
          ),
        ),
        const SizedBox(height: 24),
        _primaryAction(
          label: 'SEND RECOVERY CODE',
          icon: Icons.send_outlined,
          onPressed: () => _requestCode(),
        ),
      ],
    );
  }

  Widget _resetForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Check the phone number verified on your account. '
          'The code expires after 5 minutes.',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 15,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Recovery requested for: $_requestedIdentifier',
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: _busy ? null : _editIdentifier,
            child: const Text('Use another email or phone number'),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _codeController,
          enabled: !_busy,
          autofocus: true,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.oneTimeCode],
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(6),
          ],
          maxLength: 6,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: _inputDecoration(
            'Six-digit recovery code',
            Icons.pin_outlined,
          ).copyWith(counterText: ''),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _passwordController,
          enabled: !_busy,
          obscureText: !_showNewPassword,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.newPassword],
          style: const TextStyle(color: AppColors.textPrimary),
          decoration:
              _inputDecoration(
                'New password (8 characters minimum)',
                Icons.lock_outline_rounded,
              ).copyWith(
                suffixIcon: IconButton(
                  tooltip: _showNewPassword ? 'Hide password' : 'Show password',
                  onPressed: () => setState(() {
                    _showNewPassword = !_showNewPassword;
                  }),
                  icon: Icon(
                    _showNewPassword ? Icons.visibility_off : Icons.visibility,
                  ),
                ),
              ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _confirmPasswordController,
          enabled: !_busy,
          obscureText: !_showConfirmPassword,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.newPassword],
          style: const TextStyle(color: AppColors.textPrimary),
          onSubmitted: (_) => _confirmReset(),
          decoration:
              _inputDecoration(
                'Confirm new password',
                Icons.lock_reset_rounded,
              ).copyWith(
                suffixIcon: IconButton(
                  tooltip: _showConfirmPassword
                      ? 'Hide confirmation password'
                      : 'Show confirmation password',
                  onPressed: () => setState(() {
                    _showConfirmPassword = !_showConfirmPassword;
                  }),
                  icon: Icon(
                    _showConfirmPassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                ),
              ),
        ),
        const SizedBox(height: 24),
        _primaryAction(
          label: 'RESET PASSWORD',
          icon: Icons.lock_reset_rounded,
          onPressed: () => _confirmReset(),
        ),
        const SizedBox(height: 14),
        Center(
          child: TextButton.icon(
            onPressed: _busy || _resendSeconds > 0
                ? null
                : () => _requestCode(resend: true),
            icon: const Icon(Icons.refresh_rounded),
            label: Text(
              _resendSeconds > 0
                  ? 'Resend code in ${_resendSeconds}s'
                  : 'Resend recovery code',
            ),
          ),
        ),
      ],
    );
  }

  Widget _navigationLinks() {
    return Column(
      children: [
        const SizedBox(height: 26),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const Text(
              'Remember your password? ',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
            TextButton(
              onPressed: _busy
                  ? null
                  : () => _backToLanding(ForgotPasswordReturnAction.login),
              child: const Text('Login'),
            ),
          ],
        ),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const Text(
              "Don't have an account? ",
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
            TextButton(
              onPressed: _busy
                  ? null
                  : () => _backToLanding(ForgotPasswordReturnAction.register),
              child: const Text('Register'),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromARGB(255, 2, 76, 2),
              Color(0xFF0B2D0D),
              Color(0xFF001000),
            ],
            stops: [0.0, 0.48, 1.0],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.extraLarge),
                  border: Border.all(
                    color: AppColors.borderPrimary,
                    width: 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          tooltip: 'Back to login',
                          onPressed: _busy
                              ? null
                              : () => _backToLanding(
                                  ForgotPasswordReturnAction.login,
                                ),
                          icon: const Icon(
                            Icons.arrow_back_rounded,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.primaryDark,
                            borderRadius: BorderRadius.circular(
                              AppRadius.medium,
                            ),
                          ),
                          child: const Icon(
                            Icons.lock_reset_rounded,
                            color: AppColors.primary,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 26),
                    Text(
                      _stage == _RecoveryStage.requestCode
                          ? 'Forgot Password?'
                          : 'Reset Your Password',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 14),
                    if (_feedback != null) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.primaryDark,
                          borderRadius: BorderRadius.circular(AppRadius.medium),
                        ),
                        child: Text(
                          _feedback!,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            height: 1.45,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                    ],
                    if (_stage == _RecoveryStage.requestCode)
                      _requestForm()
                    else
                      _resetForm(),
                    _navigationLinks(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
