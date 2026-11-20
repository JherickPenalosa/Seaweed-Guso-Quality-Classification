import 'package:flutter/material.dart';

import '../../app/theme.dart';

class RetryState extends StatelessWidget {
  const RetryState({
    super.key,
    required this.title,
    required this.message,
    required this.onRetry,
    this.icon = Icons.error_outline_rounded,
    this.retryLabel = 'Retry',
  });

  final String title;
  final String message;
  final VoidCallback onRetry;
  final IconData icon;
  final String retryLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 32,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(
          AppRadius.medium,
        ),
        border: Border.all(
          color: AppColors.error,
          width: 1.2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(
                AppRadius.medium,
              ),
              border: Border.all(
                color: AppColors.error,
              ),
            ),
            child: Icon(
              icon,
              color: AppColors.error,
              size: 28,
            ),
          ),

          const SizedBox(height: 18),

          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 8),

          ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 440,
            ),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ),

          const SizedBox(height: 20),

          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(
              Icons.refresh_rounded,
              size: 18,
            ),
            label: Text(retryLabel),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: const BorderSide(
                color: AppColors.error,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}