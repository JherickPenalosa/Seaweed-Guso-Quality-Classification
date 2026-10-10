import 'package:flutter/material.dart';

import '../../app/theme.dart';

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({
    super.key,
    this.message = 'No internet connection. Some features may be unavailable.',
    this.onRetry,
  });

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(
          color: AppColors.warning,
          width: 1.2,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 520;

          if (isCompact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMessage(),
                if (onRetry != null) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: _buildRetryButton(),
                  ),
                ],
              ],
            );
          }

          return Row(
            children: [
              Expanded(
                child: _buildMessage(),
              ),
              if (onRetry != null) ...[
                const SizedBox(width: 16),
                _buildRetryButton(),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildMessage() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.wifi_off_rounded,
          color: AppColors.warning,
          size: 22,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'You are offline',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                message,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRetryButton() {
    return OutlinedButton.icon(
      onPressed: onRetry,
      icon: const Icon(
        Icons.refresh_rounded,
        size: 18,
      ),
      label: const Text('Retry'),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.warning,
        side: const BorderSide(
          color: AppColors.warning,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }
}