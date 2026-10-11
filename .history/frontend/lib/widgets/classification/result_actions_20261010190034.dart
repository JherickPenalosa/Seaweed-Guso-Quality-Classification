import 'package:flutter/material.dart';

import '../../app/theme.dart';

class ResultActions extends StatelessWidget {
  const ResultActions({
    super.key,
    required this.onUploadNext,
    required this.onSave,
    required this.isSaved,
    this.isSaving = false,
    this.saveFailed = false,
  });

  final VoidCallback onUploadNext;
  final VoidCallback onSave;

  final bool isSaved;
  final bool isSaving;
  final bool saveFailed;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact =
            constraints.maxWidth < 520;

        if (isCompact) {
          return Column(
            children: [
              SizedBox(
                width: double.infinity,
                height: 54,
                child: _buildUploadNextButton(),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: _buildSaveButton(),
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 54,
                child: _buildUploadNextButton(),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: SizedBox(
                height: 54,
                child: _buildSaveButton(),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildUploadNextButton() {
    return OutlinedButton.icon(
      onPressed:
          isSaving ? null : onUploadNext,
      icon: const Icon(
        Icons.add_photo_alternate_outlined,
      ),
      label: const Text(
        'UPLOAD NEXT',
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor:
            AppColors.textPrimary,
        side: const BorderSide(
          color: AppColors.borderLight,
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    if (isSaved) {
      return ElevatedButton.icon(
        onPressed: null,
        icon: const Icon(
          Icons.check_circle_outline,
        ),
        label: const Text(
          'SAVED',
        ),
        style: ElevatedButton.styleFrom(
          disabledBackgroundColor:
              AppColors.primaryDark,
          disabledForegroundColor:
              AppColors.primary,
        ),
      );
    }

    if (isSaving) {
      return ElevatedButton.icon(
        onPressed: null,
        icon: const SizedBox(
          width: 18,
          height: 18,
          child:
              CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.black,
          ),
        ),
        label: const Text(
          'SAVING...',
        ),
      );
    }

    if (saveFailed) {
      return OutlinedButton.icon(
        onPressed: onSave,
        icon: const Icon(
          Icons.refresh_rounded,
        ),
        label: const Text(
          'RETRY SAVE',
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor:
              AppColors.error,
          side: const BorderSide(
            color: AppColors.error,
          ),
        ),
      );
    }

    return ElevatedButton.icon(
      onPressed: onSave,
      icon: const Icon(
        Icons.save_outlined,
      ),
      label: const Text(
        'SAVE',
      ),
    );
  }
}