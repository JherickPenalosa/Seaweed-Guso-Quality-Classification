import 'package:flutter/material.dart';
import '../../services/mock_auth_service.dart';

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
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _firstNameController =
      TextEditingController();

  final TextEditingController _lastNameController =
      TextEditingController();

  final TextEditingController _emailController =
      TextEditingController();

  final TextEditingController _contactController =
      TextEditingController();

  final TextEditingController _passwordController =
      TextEditingController();

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

  Future<void> _register() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final firstName =
        _firstNameController.text.trim();

    final lastName =
        _lastNameController.text.trim();

    final email =
        _emailController.text.trim();

    final contact =
        _contactController.text.trim();

    final password =
        _passwordController.text;

    final authService =
        MockAuthService.instance;

    if (email.isNotEmpty &&
        authService.isEmailTaken(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'This email is already registered.',
          ),
          backgroundColor: AppColors.error,
        ),
      );

      return;
    }

    if (authService.isContactTaken(contact)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'This contact number is already registered.',
          ),
          backgroundColor: AppColors.error,
        ),
      );

      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    await Future.delayed(
      const Duration(milliseconds: 700),
    );

    if (!mounted) {
      return;
    }

    authService.register(
      firstName: firstName,
      lastName: lastName,
      email: email,
      contactNumber: contact,
      password: password,
    );

    setState(() {
      _isSubmitting = false;
    });

    await _showSuccessDialog();

    if (!mounted) {
      return;
    }

    widget.onRegistrationSuccess();
  }

  Future<void> _showSuccessDialog() {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          icon: const Icon(
            Icons.check_circle_outline,
            color: AppColors.success,
            size: 46,
          ),
          title: const Text(
            'Registration Successful',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: const Text(
            'Your account has been created successfully. '
            'You can now return to Login.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text(
                'Continue to Login',
              ),
            ),
          ],
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
            stops: [
              0.0,
              0.48,
              1.0,
            ],
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
                    crossAxisAlignment:
                        CrossAxisAlignment.stretch,
                    children: [
                      _buildBranding(context),

                      const SizedBox(
                        height: AppSpacing.lg,
                      ),

                      _buildRegisterCard(context),

                      const SizedBox(
                        height: AppSpacing.lg,
                      ),
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
            onPressed:
                _isSubmitting ? null : widget.onBack,
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

  Widget _buildBranding(
    BuildContext context,
  ) {
    return Column(
      children: [
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: Theme.of(context)
                .textTheme
                .displaySmall
                ?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
            children: const [
              TextSpan(
                text: 'g',
                style: TextStyle(
                  color: AppColors.textPrimary,
                ),
              ),
              TextSpan(
                text: 'US',
                style: TextStyle(
                  color: AppColors.primary,
                ),
              ),
              TextSpan(
                text: 'o',
                style: TextStyle(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(
          height: AppSpacing.sm,
        ),

        Text(
          'Create an Account',
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
        ),

        const SizedBox(
          height: 6,
        ),

        Text(
          'Fill in your information to get started.',
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
      ],
    );
  }

  Widget _buildRegisterCard(
    BuildContext context,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(
        AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark.withValues(
          alpha: 0.88,
        ),
        borderRadius: BorderRadius.circular(
          AppRadius.large,
        ),
        border: Border.all(
          color: AppColors.borderLight,
        ),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.stretch,
          children: [
            Text(
              'Register',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
            ),

            const SizedBox(
              height: AppSpacing.md,
            ),

            TextFormField(
              controller:
                  _firstNameController,
              textInputAction:
                  TextInputAction.next,
              enabled: !_isSubmitting,
              textCapitalization:
                  TextCapitalization.words,
              style: const TextStyle(
                color: AppColors.textPrimary,
              ),
              decoration:
                  const InputDecoration(
                labelText: 'First Name',
                hintText: 'Enter first name',
                prefixIcon: Icon(
                  Icons.person_outline,
                ),
              ),
              validator: (value) {
                if (value == null ||
                    value.trim().isEmpty) {
                  return 'First name is required.';
                }

                return null;
              },

              autofillHints: const [
                AutofillHints.givenName,
              ],
            ),

            const SizedBox(
              height: AppSpacing.md,
            ),

            TextFormField(
              controller:
                  _lastNameController,
              textInputAction:
                  TextInputAction.next,
              enabled: !_isSubmitting,
              textCapitalization:
                  TextCapitalization.words,
              style: const TextStyle(
                color: AppColors.textPrimary,
              ),
              decoration:
                  const InputDecoration(
                labelText: 'Last Name',
                hintText: 'Enter last name',
                prefixIcon: Icon(
                  Icons.badge_outlined,
                ),
              ),
              validator: (value) {
                if (value == null ||
                    value.trim().isEmpty) {
                  return 'Last name is required.';
                }

                return null;
              },

              autofillHints: const [
                AutofillHints.familyName,
              ],
            ),

            const SizedBox(
              height: AppSpacing.md,
            ),

            TextFormField(
              controller:
                  _emailController,
              keyboardType:
                  TextInputType.emailAddress,
              textInputAction:
                  TextInputAction.next,
              enabled: !_isSubmitting,
              style: const TextStyle(
                color: AppColors.textPrimary,
              ),
              decoration:
                  const InputDecoration(
                labelText: 'Email (Optional)',
                hintText: 'Enter email address',
                prefixIcon: Icon(
                  Icons.email_outlined,
                ),
              ),
              validator: (value) {
                final email =
                    value?.trim() ?? '';

                if (email.isEmpty) {
                  return null;
                }

                final emailPattern =
                    RegExp(
                  r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                );

                if (!emailPattern
                    .hasMatch(email)) {
                  return 'Enter a valid email address.';
                }

                return null;
              },

              autofillHints: const [
                AutofillHints.email,
              ],
            ),

            const SizedBox(
              height: AppSpacing.md,
            ),

            TextFormField(
              controller:
                  _contactController,
              keyboardType:
                  TextInputType.phone,
              textInputAction:
                  TextInputAction.next,
              enabled: !_isSubmitting,
              style: const TextStyle(
                color: AppColors.textPrimary,
              ),
              decoration:
                  const InputDecoration(
                labelText: 'Contact Number',
                hintText:
                    'Enter contact number',
                prefixIcon: Icon(
                  Icons.phone_outlined,
                ),
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

              autofillHints: const [
                AutofillHints.telephoneNumber,
              ],
            ),

            const SizedBox(
              height: AppSpacing.md,
            ),

            TextFormField(
              controller:
                  _passwordController,
              obscureText: _obscurePassword,
              textInputAction:
                  TextInputAction.next,
              enabled: !_isSubmitting,
              style: const TextStyle(
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                labelText: 'Password',
                hintText:
                    'Create a password',
                prefixIcon: const Icon(
                  Icons.lock_outline,
                ),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _obscurePassword =
                          !_obscurePassword;
                    });
                  },
                  icon: Icon(
                    _obscurePassword
                        ? Icons
                            .visibility_outlined
                        : Icons
                            .visibility_off_outlined,
                  ),
                ),
              ),
              validator: (value) {
                if (value == null ||
                    value.isEmpty) {
                  return 'Password is required.';
                }

                if (value.length < 6) {
                  return 'Password must be at least 6 characters.';
                }

                return null;
              },

              autofillHints: const [
                AutofillHints.newPassword,
              ],
            ),

            const SizedBox(
              height: AppSpacing.md,
            ),

            TextFormField(
              controller:
                  _confirmPasswordController,
              obscureText:
                  _obscureConfirmPassword,
              textInputAction:
                  TextInputAction.done,
              enabled: !_isSubmitting,
              onFieldSubmitted: (_) {
                _register();
              },
              style: const TextStyle(
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                labelText:
                    'Confirm Password',
                hintText:
                    'Re-enter your password',
                prefixIcon: const Icon(
                  Icons.lock_reset_outlined,
                ),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword =
                          !_obscureConfirmPassword;
                    });
                  },
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons
                            .visibility_outlined
                        : Icons
                            .visibility_off_outlined,
                  ),
                ),
              ),
              validator: (value) {
                if (value == null ||
                    value.isEmpty) {
                  return 'Please confirm your password.';
                }

                if (value !=
                    _passwordController.text) {
                  return 'Passwords do not match.';
                }

                return null;
              },

              autofillHints: const [
                AutofillHints.newPassword,
              ],
            ),

            const SizedBox(
              height: AppSpacing.xl,
            ),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed:
                    _isSubmitting
                        ? null
                        : _register,
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(
                        Icons.person_add_alt_1_outlined,
                      ),
                label: Text(
                  _isSubmitting
                      ? 'Creating Account...'
                      : 'Create Account',
                ),
              ),
            ),

            const SizedBox(
              height: AppSpacing.lg,
            ),

            Row(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                Text(
                  'Already have an account?',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(
                        color: AppColors
                            .textSecondary,
                      ),
                ),
                TextButton(
                  onPressed: _isSubmitting
                      ? null
                      : widget.onBack,
                  child: const Text(
                    'Login',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}