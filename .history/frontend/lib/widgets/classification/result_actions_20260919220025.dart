import 'package:flutter/material.dart';

import '../../app/theme.dart';

class ResultActions extends StatelessWidget {
  final VoidCallback onUploadNext;
  final VoidCallback onSave;
  final bool isSaved;

  const ResultActions({
    super.key,
    required this.onUploadNext,
    required this.onSave,
    this.isSaved = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onUploadNext,
            icon: const Icon(
              Icons.add_photo_alternate_outlined,
            ),
            label: const Text(
              'UPLOAD NEXT',
            ),
          ),
        ),

        const SizedBox(width: 16),

        Expanded(
          child: ElevatedButton.icon(
            onPressed: isSaved ? null : onSave,
            icon: Icon(
              isSaved
                  ? Icons.check_circle_outline
                  : Icons.save_outlined,
            ),
            label: Text(
              isSaved
                  ? 'SAVED'
                  : 'SAVE',
            ),
          ),
        ),
      ],
    );
  }
}