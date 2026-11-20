import 'package:flutter/material.dart';

/// Action buttons for a completed classification result.
///
/// The parent screen owns the actual save request and any confirmation
/// shown when the user chooses to discard an unsaved result.
class ResultActions extends StatelessWidget {
  final VoidCallback onUploadNext;
  final VoidCallback onSave;
  final bool isSaved;

  /// Set true while the parent screen is saving to PostgreSQL.
  final bool isSaving;
  final bool saveFailed;

  /// Set true while the parent is otherwise busy (for example, analyzing).
  final bool isBusy;

  /// Set false for rejected images or results without a savable record.
  final bool canSaveResult;

  const ResultActions({
    super.key,
    required this.onUploadNext,
    required this.onSave,
    this.isSaved = false,
    this.isSaving = false,
    this.saveFailed = false,
    this.isBusy = false,
    this.canSaveResult = true,
  });

  @override
  Widget build(BuildContext context) {
    final canUploadNext = !isSaving && !isBusy;
    final canSave = canSaveResult && !isSaved && !isSaving && !isBusy;

    String statusText;
    IconData statusIcon;

    if (isSaving) {
      statusText = 'Saving classification to History...';
      statusIcon = Icons.sync_outlined;
    } else if (saveFailed) {
      statusText = 'Saving failed. Please try again.';
      statusIcon = Icons.error_outline;
    } else if (isSaved) {
      statusText = 'Classification saved to History.';
      statusIcon = Icons.check_circle_outline;
    } else if (!canSaveResult) {
      statusText = 'This result cannot be saved. Upload another image.';
      statusIcon = Icons.info_outline;
    } else {
      statusText =
          'Not saved yet. Uploading another image may discard this result.';
      statusIcon = Icons.info_outline;
    }

    Widget uploadButton({required bool compact}) {
      return SizedBox(
        height: 56,
        child: OutlinedButton.icon(
          onPressed: canUploadNext ? onUploadNext : null,
          icon: const Icon(Icons.add_photo_alternate_outlined, size: 20),
          label: Text(compact ? 'NEXT IMAGE' : 'UPLOAD NEXT'),
        ),
      );
    }

    Widget saveButton() {
      return SizedBox(
        height: 56,
        child: ElevatedButton.icon(
          onPressed: canSave ? onSave : null,
          icon: isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(
                  isSaved ? Icons.check_circle_outline : Icons.save_outlined,
                  size: 20,
                ),
          label: Text(
            isSaving
                ? 'SAVING...'
                : isSaved
                ? 'SAVED'
                : canSaveResult
                ? 'SAVE RESULT'
                : 'NOT SAVABLE',
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 520;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (compact)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  saveButton(),
                  const SizedBox(height: 12),
                  uploadButton(compact: true),
                ],
              )
            else
              Row(
                children: [
                  Expanded(child: uploadButton(compact: false)),
                  const SizedBox(width: 16),
                  Expanded(child: saveButton()),
                ],
              ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  statusIcon,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  size: 17,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    statusText,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
