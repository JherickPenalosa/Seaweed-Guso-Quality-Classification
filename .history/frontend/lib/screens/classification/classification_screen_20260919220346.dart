import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../widgets/classification/image_upload_area.dart';

import '../../models/classification_result.dart';
import '../../widgets/classification/classification_summary.dart';
import '../../widgets/classification/characteristics_panel.dart';
import '../../widgets/classification/result_actions.dart';

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
  bool _isSaved = false;
  ClassificationResult? _result;

  bool get _hasImage => _selectedImage != null;
  bool get _hasResult => _result != null;

  void _handleImageChanged(Uint8List? imageBytes) {
    setState(() {
      _selectedImage = imageBytes;
      _result = null;
      _isSaved = false;
    });
  }

  void _uploadNext() {
    if (_hasResult && !_isSaved) {
      _showUnsavedWarning();
      return;
    }

    _resetClassification();
  }

  void _saveResult() {
    if (!_hasResult || _isSaved) {
      return;
    }

    setState(() {
      _isSaved = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Classification record saved successfully.',
        ),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _resetClassification() {
    setState(() {
      _selectedImage = null;
      _result = null;
      _isSaved = false;
      _isAnalyzing = false;
    });
  }

  Future<void> _showUnsavedWarning() async {
    final shouldContinue = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text(
            'Unsaved Result',
            style: TextStyle(
              color: AppColors.textPrimary,
            ),
          ),
          content: const Text(
            'This classification result has not been saved yet. '
            'Do you want to continue and upload another image?',
            style: TextStyle(
              color: AppColors.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('CANCEL'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('CONTINUE'),
            ),
          ],
        );
      },
    );

    if (shouldContinue == true) {
      _resetClassification();
    }
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
            const SizedBox(height: 24),

            ClassificationSummary(
              result: _result!,
            ),

            const SizedBox(height: 24),

            CharacteristicsPanel(
              result: _result!,
            ),
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