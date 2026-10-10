import 'package:flutter/material.dart';

import '../../app/theme.dart';

class ErrorMessage extends StatelessWidget {
  const ErrorMessage({
    super.key,
    required this.message,
    this.title = 'Something went wrong',
    this.onDismiss,
  });

  final String title;
  final String message;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact =
              constraints.maxWidth < 520;

          if (isCompact) {
            return Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                _buildMessageContent(),

                if (onDismiss != null) ...[
                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    child: _buildDismissButton(),
                  ),
                ],
              ],
            );
          }

          return Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildMessageContent(),
              ),

              if (onDismiss != null) ...[
                const SizedBox(width: 16),
                _buildDismissButton(),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildMessageContent() {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.error_outline_rounded,
          color: AppColors.error,
          size: 24,
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color:
                      AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight:
                      FontWeight.w600,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                message,
                style: const TextStyle(
                  color:
                      AppColors.textSecondary,
                  fontSize: 13,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDismissButton() {
    return OutlinedButton.icon(
      onPressed: onDismiss,
      icon: const Icon(
        Icons.close_rounded,
        size: 17,
      ),
      label: const Text('Dismiss'),
      style: OutlinedButton.styleFrom(
        foregroundColor:
            AppColors.error,
        side: const BorderSide(
          color: AppColors.error,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 11,
        ),
      ),
    );
  }
}