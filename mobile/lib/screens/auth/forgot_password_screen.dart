import 'package:flutter/material.dart';

import '../../app/theme.dart';

class ForgotPasswordScreen extends StatefulWidget {
  final VoidCallback onBackToLogin;

  const ForgotPasswordScreen({
    super.key,
    required this.onBackToLogin,
  });

  @override
  State<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState
    extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _identifierController =
      TextEditingController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _identifierController.dispose();
    super.dispose();
  }

  Future<void> _sendRecoveryRequest() async {
    FocusScope.of(context).unfocus();

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

    setState(() {
      _isSubmitting = false;
    });

    await _showSuccessDialog();
  }

  Future<void> _showSuccessDialog() {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          icon: const Icon(
            Icons.mark_email_read_outlined,
            color: AppColors.success,
            size: 46,
          ),
          title: const Text(
            'Recovery Request Sent',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: const Text(
            'A recovery code has been simulated for this prototype. '
            'You may now return to Login.',
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
                widget.onBackToLogin();
              },
              child: const Text(
                'Back to Login',
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

                      _buildRecoveryCard(context),
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
                _isSubmitting ? null : widget.onBackToLogin,
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: AppColors.textPrimary,
            ),
            tooltip: 'Back to Login',
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
          'Forgot Password?',
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
          'Enter your email or contact number to recover your account.',
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(
                color: AppColors.textSecondary,
                height: 1.4,
              ),
        ),
      ],
    );
  }

  Widget _buildRecoveryCard(
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
              'Account Recovery',
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
              'We will use this information to locate your account.',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.4,
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
                  TextInputAction.done,
              enabled: !_isSubmitting,
              onFieldSubmitted: (_) {
                _sendRecoveryRequest();
              },
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
                  Icons.account_circle_outlined,
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
              height: AppSpacing.xl,
            ),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed:
                    _isSubmitting
                        ? null
                        : _sendRecoveryRequest,
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
                        Icons.send_outlined,
                      ),
                label: Text(
                  _isSubmitting
                      ? 'Sending...'
                      : 'Send Recovery Code',
                ),
              ),
            ),

            const SizedBox(
              height: AppSpacing.lg,
            ),

            Center(
              child: TextButton.icon(
                onPressed: _isSubmitting
                    ? null
                    : widget.onBackToLogin,
                icon: const Icon(
                  Icons.arrow_back_outlined,
                ),
                label: const Text(
                  'Back to Login',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}