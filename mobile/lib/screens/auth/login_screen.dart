import 'package:flutter/material.dart';
import '../../app/theme.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onLoginSuccess;
  final VoidCallback onRegister;
  final VoidCallback onForgotPassword;
  final VoidCallback onBack;

  const LoginScreen({
    super.key,
    required this.onLoginSuccess,
    required this.onRegister,
    required this.onForgotPassword,
    required this.onBack,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _identifierController =
      TextEditingController();

  final TextEditingController _passwordController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _isSubmitting = false;

  String? _loginError;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    FocusScope.of(context).unfocus();

    setState(() {
      _loginError = null;
    });

    if (!_formKey.currentState!.validate()) {
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

    final identifier =
        _identifierController.text.trim();

    final password =
        _passwordController.text;

    final loginSuccessful =
        context.read<AuthProvider>().login(
      identifier: identifier,
      password: password,
    );

    if (!loginSuccessful) {
      setState(() {
        _isSubmitting = false;
        _loginError =
            'Incorrect email/contact number or password.';
      });

      return;
    }

    setState(() {
      _isSubmitting = false;
      _loginError = null;
    });

    widget.onLoginSuccess();
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
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.xl,
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.stretch,
                    children: [
                      _buildBranding(context),

                      const SizedBox(
                        height: AppSpacing.xl,
                      ),

                      _buildLoginCard(context),
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
          'Welcome Back',
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
          height: AppSpacing.sm,
        ),

        Text(
          'Login to continue using gUSo.',
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

  Widget _buildLoginCard(
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
              'Login',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
            ),

            const SizedBox(
              height: AppSpacing.sm,
            ),

            Text(
              'Enter your account details below.',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),

            const SizedBox(
              height: AppSpacing.lg,
            ),

            TextFormField(
              controller:
                  _identifierController,
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
                labelText:
                    'Email or Contact Number',
                hintText:
                    'Enter email or contact number',
                prefixIcon: Icon(
                  Icons.person_outline,
                ),
              ),
              validator: (value) {
                if (value == null ||
                    value.trim().isEmpty) {
                  return 'Email or contact number is required.';
                }

                return null;
              },
            ),

            const SizedBox(
              height: AppSpacing.md,
            ),

            TextFormField(
              controller:
                  _passwordController,
              obscureText: _obscurePassword,
              textInputAction:
                  TextInputAction.done,
              enabled: !_isSubmitting,
              onFieldSubmitted: (_) {
                _login();
              },
              style: const TextStyle(
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                labelText: 'Password',
                hintText:
                    'Enter your password',
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

                return null;
              },
            ),

            Align(
              alignment:
                  Alignment.centerRight,
              child: TextButton(
                onPressed: _isSubmitting
                    ? null
                    : widget.onForgotPassword,
                child: const Text(
                  'Forgot Password?',
                ),
              ),
            ),

            if (_loginError != null) ...[
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.all(
                  AppSpacing.md,
                ),
                decoration: BoxDecoration(
                  color: AppColors.error
                      .withValues(
                    alpha: 0.10,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    AppRadius.medium,
                  ),
                  border: Border.all(
                    color: AppColors.error,
                  ),
                ),
                child: Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: AppColors.error,
                      size: 20,
                    ),
                    const SizedBox(
                      width: AppSpacing.sm,
                    ),
                    Expanded(
                      child: Text(
                        _loginError!,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(
                              color:
                                  AppColors.error,
                              height: 1.4,
                            ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: AppSpacing.md,
              ),
            ],

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed:
                    _isSubmitting
                        ? null
                        : _login,
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
                        Icons.login_outlined,
                      ),
                label: Text(
                  _isSubmitting
                      ? 'Logging in...'
                      : 'Login',
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
                  'Don\'t have an account?',
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
                      : widget.onRegister,
                  child: const Text(
                    'Register',
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