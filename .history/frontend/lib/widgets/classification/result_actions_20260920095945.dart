import 'package:flutter/material.dart';

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
    return LayoutBuilder(
  builder: (context, constraints) {
    final isCompact = constraints.maxWidth < 500;

    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 56,
            child: OutlinedButton.icon(
              onPressed: onUploadNext,
              icon: const Icon(
                Icons.add_photo_alternate_outlined,
                size: 20,
              ),
              label: Text(
                isCompact ? 'NEXT IMAGE' : 'UPLOAD NEXT',
              ),
            ),
          ),
        ),

        const SizedBox(width: 16),

        Expanded(
          child: SizedBox(
            height: 56,
            child: ElevatedButton.icon(
              onPressed: isSaved ? null : onSave,
              icon: Icon(
                isSaved
                    ? Icons.check_circle_outline
                    : Icons.save_outlined,
                size: 20,
              ),
              label: Text(
                isSaved ? 'SAVED' : 'SAVE',
              ),
            ),
          ),
        ),
      ],
    );
  },
);
}