import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../widgets/classification/image_upload_area.dart';

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

  bool get _hasImage => _selectedImage != null;

  void _handleImageChanged(Uint8List? imageBytes) {
    setState(() {
      _selectedImage = imageBytes;
    });
  }

  Future<void> _classifyImage() async {
    if (!_hasImage || _isAnalyzing) {
      return;
    }

    setState(() {
      _isAnalyzing = true;
    });

    // Temporary delay to simulate image processing.
    // This will later be replaced with the real backend API call.
    await Future.delayed(
      const Duration(seconds: 3),
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isAnalyzing = false;
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

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed:
                  _hasImage ? _classifyImage : null,
              icon: const Icon(
                Icons.auto_awesome_outlined,
              ),
              label: const Text('CLASSIFY'),
            ),
          ),
        ],
      ),
    );
  }
}