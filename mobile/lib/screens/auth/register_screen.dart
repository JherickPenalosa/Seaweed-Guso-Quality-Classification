import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../app/theme.dart';

class RegisterScreen extends StatefulWidget {
  final VoidCallback onRegistrationSuccess;
  final VoidCallback onBack;

  const RegisterScreen({
    super.key,
    required this.onRegistrationSuccess,
    required this.onBack,
  });

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  static const String _baseUrl = String.fromEnvironment(
    'GUSO_API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000',
  );

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _firstNameController = TextEditingController();

  final TextEditingController _lastNameController = TextEditingController();

  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _contactController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _contactController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String _getBackendError(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);

      if (decoded is Map) {
        final detail = decoded['detail'];

        if (detail is String && detail.isNotEmpty) {
          return detail;
        }

        if (detail is List && detail.isNotEmpty) {
          final first = detail.first;

          if (first is Map && first['msg'] is String) {
            return first['msg'] as String;
          }
        }
      }
    } catch (_) {
      // Use an appropriate HTTP error message instead.
    }

    switch (response.statusCode) {
      case 409:
        return 'The email or contact number is already registered.';

      case 422:
        return 'Please check your registration information.';

      case 429:
        return 'Too many requests. Please try again later.';

      case 500:
      case 502:
      case 503:
        return 'The gUSo server is temporarily unavailable.';

      default:
        return 'Registration failed '
            '(HTTP ${response.statusCode}).';
    }
  }

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 5),
        ),
      );
  }

  Future<void> _register() async {
    if (_isSubmitting) return;

    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final firstName = _firstNameController.text.trim();

    final lastName = _lastNameController.text.trim();

    final email = _emailController.text.trim().toLowerCase();

    final contact = _contactController.text.trim();

    final password = _passwordController.text;

    final confirmPassword = _confirmPasswordController.text;

    setState(() {
      _isSubmitting = true;
    });

    bool registered = false;
    String? errorMessage;

    try {
      final uri = Uri.parse(
        '${_baseUrl.replaceFirst(RegExp(r"/$"), "")}/auth/register',
      );

      final response = await http
          .post(
            uri,
            headers: const {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'first_name': firstName,
              'last_name': lastName,
              'email': email,
              'contact_num': contact,
              'password': password,
              'confirm_password': confirmPassword,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode != 201) {
        errorMessage = _getBackendError(response);
      } else {
        final decoded = jsonDecode(response.body);

        if (decoded is! Map || decoded['user'] is! Map) {
          errorMessage =
              'The server returned an invalid registration response.';
        } else {
          final user = decoded['user'] as Map;

          if (user['email']?.toString().toLowerCase() != email) {
            errorMessage =
                'The server returned unexpected account information.';
          } else {
            registered = true;
          }
        }
      }
    } on TimeoutException {
      errorMessage =
          'Registration timed out. Check your connection '
          'before trying again.';
    } on http.ClientException {
      errorMessage = 'Cannot reach FastAPI. Check your Android connection.';
    } on FormatException {
      errorMessage = 'The server returned an invalid response.';
    } catch (_) {
      errorMessage =
          'Unable to complete registration. '
          'Please check your connection and try again.';
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }

    if (!mounted) return;

    if (!registered) {
      _showError(errorMessage ?? 'Registration failed.');
      return;
    }

    await _showSuccessDialog();

    if (!mounted) return;

    // auth_flow.dart opens the email OTP verification
    // screen through this existing callback.
    widget.onRegistrationSuccess();
  }

  Future<void> _showSuccessDialog() {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            backgroundColor: AppColors.surface,
            icon: const Icon(
              Icons.mark_email_unread_outlined,
              color: AppColors.success,
              size: 46,
            ),
            title: const Text(
              'Account Created',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            content: const Text(
              'Your account has been saved successfully.\n\n'
              'Email verification is required before you '
              'can log in.\n\n'
              'Continue to the next screen to request '
              'your six-digit verification code.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, height: 1.5),
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
                child: const Text('Continue to Email Verification'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
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
        child: SafeArea(
          child: Column(
            children: [
              _buildTopBar(),
              Expanded(
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.md,
                    AppSpacing.lg,
                    AppSpacing.xl,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildBranding(context),
                      const SizedBox(height: AppSpacing.lg),
                      _buildRegisterCard(context),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.sm,
        AppSpacing.sm,
        AppSpacing.lg,
        0,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: _isSubmitting ? null : widget.onBack,
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: AppColors.textPrimary,
            ),
            tooltip: 'Back',
          ),
        ],
      ),
    );
  }

  Widget _buildBranding(BuildContext context) {
    return Column(
      children: [
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: Theme.of(context).textTheme.displaySmall
                ?.copyWith(fontWeight: FontWeight.w900, letterSpacing: 1.5),
            children: const [
              TextSpan(
                text: 'g',
                style: TextStyle(color: AppColors.textPrimary),
              ),
              TextSpan(
                text: 'US',
                style: TextStyle(color: AppColors.primary),
              ),
              TextSpan(
                text: 'o',
                style: TextStyle(color: AppColors.textPrimary),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Create an Account',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Fill in your information to get started.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildRegisterCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Register',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            TextFormField(
              controller: _firstNameController,
              textInputAction: TextInputAction.next,
              enabled: !_isSubmitting,
              textCapitalization: TextCapitalization.words,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                labelText: 'First Name',
                hintText: 'Enter first name',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'First name is required.';
                }
                return null;
              },
              autofillHints: const [AutofillHints.givenName],
            ),

            const SizedBox(height: AppSpacing.md),

            TextFormField(
              controller: _lastNameController,
              textInputAction: TextInputAction.next,
              enabled: !_isSubmitting,
              textCapitalization: TextCapitalization.words,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                labelText: 'Last Name',
                hintText: 'Enter last name',
                prefixIcon: Icon(Icons.badge_outlined),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Last name is required.';
                }
                return null;
              },
              autofillHints: const [AutofillHints.familyName],
            ),

            const SizedBox(height: AppSpacing.md),

            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              enabled: !_isSubmitting,
              autocorrect: false,
              enableSuggestions: false,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'Enter email address',
                prefixIcon: Icon(Icons.email_outlined),
              ),
              validator: (value) {
                final email = value?.trim() ?? '';

                if (email.isEmpty) {
                  return 'Email is required for OTP verification.';
                }

                final emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

                if (!emailPattern.hasMatch(email)) {
                  return 'Enter a valid email address.';
                }

                return null;
              },
              autofillHints: const [AutofillHints.email],
            ),

            const SizedBox(height: AppSpacing.md),

            TextFormField(
              controller: _contactController,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              enabled: !_isSubmitting,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                labelText: 'Contact Number',
                hintText: 'Enter contact number',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
              validator: (value) {
                final contact = value?.trim() ?? '';

                if (contact.isEmpty) {
                  return 'Contact number is required.';
                }

                final digitsOnly = RegExp(r'^[0-9]+$');

                if (!digitsOnly.hasMatch(contact)) {
                  return 'Contact number must contain numbers only.';
                }

                if (contact.length < 10 || contact.length > 11) {
                  return 'Enter a valid 10 or 11-digit contact number.';
                }

                return null;
              },
              autofillHints: const [AutofillHints.telephoneNumber],
            ),

            const SizedBox(height: AppSpacing.md),

            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.next,
              enabled: !_isSubmitting,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                labelText: 'Password',
                hintText: 'Create a password',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  onPressed: _isSubmitting
                      ? null
                      : () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Password is required.';
                }

                if (value.length < 8) {
                  return 'Password must be at least 8 characters.';
                }

                if (value.length > 128) {
                  return 'Password must be at most 128 characters.';
                }

                return null;
              },
              autofillHints: const [AutofillHints.newPassword],
            ),

            const SizedBox(height: AppSpacing.md),

            TextFormField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              textInputAction: TextInputAction.done,
              enabled: !_isSubmitting,
              onFieldSubmitted: (_) {
                _register();
              },
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                hintText: 'Re-enter your password',
                prefixIcon: const Icon(Icons.lock_reset_outlined),
                suffixIcon: IconButton(
                  onPressed: _isSubmitting
                      ? null
                      : () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please confirm your password.';
                }

                if (value != _passwordController.text) {
                  return 'Passwords do not match.';
                }

                return null;
              },
              autofillHints: const [AutofillHints.newPassword],
            ),

            const SizedBox(height: AppSpacing.xl),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _register,
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.person_add_alt_1_outlined),
                label: Text(
                  _isSubmitting ? 'Creating Account...' : 'Create Account',
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Already have an account?',
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(color: AppColors.textSecondary),
                ),
                TextButton(
                  onPressed: _isSubmitting ? null : widget.onBack,
                  child: const Text('Login'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
