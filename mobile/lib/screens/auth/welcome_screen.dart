import 'package:flutter/material.dart';

import '../../app/theme.dart';

class WelcomeScreen extends StatelessWidget {
  final VoidCallback onLogin;
  final VoidCallback onRegister;

  const WelcomeScreen({
    super.key,
    required this.onLogin,
    required this.onRegister,
  });

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
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                style: Theme.of(context)
                                    .textTheme
                                    .displayMedium
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

                            const SizedBox(height: AppSpacing.sm),

                            Text(
                              'Seaweed Quality Classification',
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),

                            const SizedBox(height: AppSpacing.lg),

                            Text(
                              'Identify, classify, and learn more about seaweed quality '
                              'through a simple mobile experience.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: AppColors.textSecondary,
                                    height: 1.5,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                _buildActions(context),

                const SizedBox(
                  height: AppSpacing.md,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(
        AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark.withValues(
          alpha: 0.90,
        ),
        borderRadius: BorderRadius.circular(
          AppRadius.large,
        ),
        border: Border.all(
          color: AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton.icon(
            onPressed: onLogin,
            icon: const Icon(
              Icons.login_outlined,
            ),
            label: const Text(
              'Login',
            ),
          ),

          const SizedBox(
            height: AppSpacing.md,
          ),

          OutlinedButton.icon(
            onPressed: onRegister,
            icon: const Icon(
              Icons.person_add_alt_1_outlined,
            ),
            label: const Text(
              'Create Account',
            ),
          ),

          const SizedBox(
            height: AppSpacing.md,
          ),

          Text(
            'Classify • Learn • Explore',
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(
                  color: AppColors.textMuted,
                  letterSpacing: 0.4,
                ),
          ),
        ],
      ),
    );
  }
}