import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../widgets/classification/image_upload_area.dart';

import '../../models/classification_result.dart';

class ClassificationScreen extends StatefulWidget {
  const ClassificationScreen({super.key});

  @override
  State<ClassificationScreen> createState() =>
      _ClassificationScreenState();
}

class _ClassificationScreenState
    extends State<ClassificationScreen> {
  Uint8List? _selectedImage;

  bool _isAnalyzing = false;
  ClassificationResult? _result;

  bool get _hasImage => _selectedImage != null;
  bool get _hasResult => _result != null;

  void _handleImageChanged(Uint8List? imageBytes) {
    setState(() {
      _selectedImage = imageBytes;

      // Selecting or removing an image clears
      // the previous classification result.
      _result = null;
    });
  }

  Future<void> _classifyImage() async {
    if (!_hasImage || _isAnalyzing) {
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _result = null;
    });

    // Temporary frontend simulation.
    // Later this will become the real backend request.
    await Future.delayed(
      const Duration(seconds: 3),
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isAnalyzing = false;
      _result = ClassificationResult.mock();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius:
                  BorderRadius.circular(AppRadius.large),
              border: Border.all(
                color: AppColors.borderPrimary,
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Classify Guso Quality',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _isAnalyzing
                      ? 'Analyzing the uploaded Guso image. Please wait while the system processes the image.'
                      : _hasImage
                          ? 'Image ready for classification. '
                              'Review the selected image, then press Classify.'
                          : 'Upload a clear image of Guso seaweed to begin '
                              'classification. For better results, use an image '
                              'with good lighting and minimal background obstruction.',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          ImageUploadArea(
            onImageChanged: _handleImageChanged,
            isAnalyzing: _isAnalyzing,
          ),
          
          if (_hasResult) ...[
            const SizedBox(height: 20),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(
                  AppRadius.medium,
                ),
                border: Border.all(
                  color: AppColors.borderPrimary,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    color: AppColors.primary,
                    size: 30,
                  ),

                  const SizedBox(width: 16),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_result!.qualityClass} — '
                          '${_result!.qualityLabel}',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Text(
  _isAnalyzing
      ? 'Analyzing the uploaded Guso image. '
          'Please wait while the system processes the image.'
      : _hasResult
          ? 'Classification completed successfully. '
              'Review the classification result and observed characteristics below.'
          : _hasImage
              ? 'Image ready for classification. '
                  'Review the selected image, then press Classify.'
              : 'Upload a clear image of Guso seaweed to begin '
                  'classification. For better results, use an image '
                  'with good lighting and minimal background obstruction.',
  style: const TextStyle(
    color: AppColors.textSecondary,
    fontSize: 15,
    height: 1.5,
  ),
),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed:
                  _hasImage && !_isAnalyzing
                      ? _classifyImage
                      : null,
              icon: _isAnalyzing
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.black,
                      ),
                    )
                  : const Icon(
                      Icons.auto_awesome_outlined,
                    ),
              label: Text(
                _isAnalyzing
                    ? 'ANALYZING...'
                    : 'CLASSIFY',
              ),
            ),
          ),
        ],
      ),
    );
  }
}