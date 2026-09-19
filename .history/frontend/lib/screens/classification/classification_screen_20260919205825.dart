import 'package:flutter/material.dart';

import '../../app/theme.dart';



class ClassificationScreen extends StatelessWidget {
  const ClassificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top information panel
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.large),
              border: Border.all(
                color: AppColors.borderPrimary,
                width: 1.5,
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Classify Guso Quality',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Upload a clear image of Guso seaweed to begin classification. '
                  'For better results, use an image with good lighting and minimal background obstruction.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Main image upload / preview area
          Container(
            width: double.infinity,
            height: 460,
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              borderRadius: BorderRadius.circular(AppRadius.large),
              border: Border.all(
                color: AppColors.borderLight,
                width: 2,
              ),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add,
                    size: 78,
                    color: AppColors.textPrimary,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'No image selected',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          const Text(
            'Supported formats: PNG, JPG, JPEG',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 24),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Image picker will be added in the next file.
                  },
                  icon: const Icon(Icons.upload_file_outlined),
                  label: const Text('UPLOAD IMAGE'),
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: ElevatedButton.icon(
                  onPressed: null,
                  icon: const Icon(Icons.auto_awesome_outlined),
                  label: const Text('CLASSIFY'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}