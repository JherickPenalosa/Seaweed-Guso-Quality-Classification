import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../app/theme.dart';

import 'analyzing_overlay.dart';

class ImageUploadArea extends StatefulWidget {
  final ValueChanged<Uint8List?> onImageChanged;
  final bool isAnalyzing;

  const ImageUploadArea({
    super.key,
    required this.onImageChanged,
    this.isAnalyzing = false,
  });

  @override
  State<ImageUploadArea> createState() => _ImageUploadAreaState();
}

class _ImageUploadAreaState extends State<ImageUploadArea> {
  Uint8List? _imageBytes;
  String? _fileName;

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'png',
        'jpg',
        'jpeg',
      ],
      withData: true,
    );

    if (result == null || result.files.isEmpty) {
      return;
    }

    final file = result.files.first;

    if (file.bytes == null) {
      return;
    }

    setState(() {
      _imageBytes = file.bytes;
      _fileName = file.name;
    });

    widget.onImageChanged(_imageBytes);
  }

  void _removeImage() {
    setState(() {
      _imageBytes = null;
      _fileName = null;
    });

    widget.onImageChanged(null);
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = _imageBytes != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnalyzingOverlay(
          isAnalyzing: widget.isAnalyzing,
          child: Container(
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
            child: ClipRRect(
              borderRadius: BorderRadius.circular(
                AppRadius.large - 2,
              ),
              child: hasImage
                  ? _buildImagePreview()
                  : _buildEmptyState(),
            ),
          ),
        ),

        const SizedBox(height: 12),

        if (hasImage) ...[
          Row(
            children: [
              const Icon(
                Icons.image_outlined,
                size: 18,
                color: AppColors.textMuted,
              ),
              const SizedBox(width: 8),

              Expanded(
                child: Text(
                  _fileName ?? 'Selected image',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ),

              TextButton.icon(
                onPressed: widget.isAnalyzing ? null : _pickImage,
                icon: const Icon(
                  Icons.swap_horiz,
                  size: 18,
                ),
                label: const Text('Change'),
              ),

              const SizedBox(width: 4),

              TextButton.icon(
                onPressed: _removeImage,
                icon: const Icon(
                  Icons.close,
                  size: 18,
                ),
                label: const Text('Remove'),
              ),
            ],
          ),
        ],

        if (!hasImage)
          const Text(
            'Supported formats: PNG, JPG, JPEG',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 13,
            ),
          ),

        const SizedBox(height: 20),

        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _pickImage,
            icon: Icon(
              hasImage
                  ? Icons.image_outlined
                  : Icons.upload_file_outlined,
            ),
            label: Text(
              hasImage
                  ? 'CHANGE IMAGE'
                  : 'UPLOAD IMAGE',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return InkWell(
      onTap: _pickImage,
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
              'Click to upload an image',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: AppColors.surfaceDark,
      alignment: Alignment.center,
      child: Image.memory(
        _imageBytes!,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
      ),
    );
  }
}