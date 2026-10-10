import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../models/selected_image.dart';
import '../common/error_message.dart';
import 'analyzing_overlay.dart';

class ImageUploadArea extends StatefulWidget {
  final ValueChanged<SelectedImage?> onImageChanged;
  final bool isAnalyzing;

  const ImageUploadArea({
    super.key,
    required this.onImageChanged,
    this.isAnalyzing = false,
  });

  @override
  State<ImageUploadArea> createState() =>
      _ImageUploadAreaState();
}

class _ImageUploadAreaState
    extends State<ImageUploadArea> {
  static const int _maxFileSizeBytes =
      10 * 1024 * 1024;

  SelectedImage? _selectedImage;
  String? _validationError;

  Future<void> _pickImage() async {
    setState(() {
      _validationError = null;
    });

    final result =
        await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'png',
        'jpg',
        'jpeg',
      ],
      withData: true,
    );

    if (result == null ||
        result.files.isEmpty) {
      return;
    }

    final file = result.files.first;

    if (file.bytes == null ||
        file.bytes!.isEmpty) {
      setState(() {
        _validationError =
            'The selected image could not be read. '
            'Please choose another image.';
      });

      return;
    }

    if (file.size > _maxFileSizeBytes) {
      setState(() {
        _validationError =
            'The selected image is too large. '
            'Please upload an image smaller than 10 MB.';
      });

      return;
    }

    final selectedImage = SelectedImage(
      fileName: file.name,
      bytes: file.bytes!,
    );

    if (!selectedImage.isSupportedFormat) {
      setState(() {
        _validationError =
            'Unsupported file format. '
            'Please upload a PNG, JPG, or JPEG image.';
      });

      return;
    }

    setState(() {
      _selectedImage = selectedImage;
      _validationError = null;
    });

    widget.onImageChanged(selectedImage);
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
      _validationError = null;
    });

    widget.onImageChanged(null);
  }

  @override
  Widget build(BuildContext context) {
    final hasImage =
        _selectedImage != null;

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        AnalyzingOverlay(
          isAnalyzing:
              widget.isAnalyzing,
          child: Container(
            width: double.infinity,
            height: 460,
            decoration: BoxDecoration(
              color:
                  AppColors.surfaceDark,
              borderRadius:
                  BorderRadius.circular(
                AppRadius.large,
              ),
              border: Border.all(
                color:
                    AppColors.borderLight,
                width: 2,
              ),
            ),
            child: ClipRRect(
              borderRadius:
                  BorderRadius.circular(
                AppRadius.large - 2,
              ),
              child: hasImage
                  ? _buildImagePreview()
                  : _buildEmptyState(),
            ),
          ),
        ),

        if (_validationError != null) ...[
          const SizedBox(height: 12),

          ErrorMessage(
            message:
                _validationError!,
            onDismiss: () {
              setState(() {
                _validationError =
                    null;
              });
            },
          ),
        ],

        const SizedBox(height: 12),

        if (hasImage) ...[
          _buildSelectedImageInfo(),
        ],

        if (!hasImage)
          const Text(
            'Supported formats: PNG, JPG, JPEG · Maximum size: 10 MB',
            style: TextStyle(
              color:
                  AppColors.textMuted,
              fontSize: 13,
            ),
          ),

        const SizedBox(height: 20),

        SizedBox(
          width: double.infinity,
          child:
              OutlinedButton.icon(
            onPressed:
                widget.isAnalyzing
                    ? null
                    : _pickImage,
            icon: Icon(
              hasImage
                  ? Icons.image_outlined
                  : Icons
                      .upload_file_outlined,
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

  Widget _buildSelectedImageInfo() {
    return LayoutBuilder(
      builder: (
        context,
        constraints,
      ) {
        final isCompact =
            constraints.maxWidth < 520;

        if (isCompact) {
          return Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.image_outlined,
                    size: 18,
                    color:
                        AppColors.textMuted,
                  ),

                  const SizedBox(width: 8),

                  Expanded(
                    child: Text(
                      _selectedImage!
                          .fileName,
                      maxLines: 1,
                      overflow:
                          TextOverflow
                              .ellipsis,
                      style:
                          const TextStyle(
                        color: AppColors
                            .textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              Row(
                children: [
                  Expanded(
                    child:
                        TextButton.icon(
                      onPressed:
                          widget.isAnalyzing
                              ? null
                              : _pickImage,
                      icon:
                          const Icon(
                        Icons
                            .swap_horiz,
                        size: 18,
                      ),
                      label:
                          const Text(
                        'Change',
                      ),
                    ),
                  ),

                  const SizedBox(
                    width: 8,
                  ),

                  Expanded(
                    child:
                        TextButton.icon(
                      onPressed:
                          widget.isAnalyzing
                              ? null
                              : _removeImage,
                      icon:
                          const Icon(
                        Icons.close,
                        size: 18,
                      ),
                      label:
                          const Text(
                        'Remove',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        }

        return Row(
          children: [
            const Icon(
              Icons.image_outlined,
              size: 18,
              color:
                  AppColors.textMuted,
            ),

            const SizedBox(width: 8),

            Expanded(
              child: Text(
                _selectedImage!
                    .fileName,
                maxLines: 1,
                overflow:
                    TextOverflow
                        .ellipsis,
                style:
                    const TextStyle(
                  color: AppColors
                      .textSecondary,
                  fontSize: 13,
                ),
              ),
            ),

            TextButton.icon(
              onPressed:
                  widget.isAnalyzing
                      ? null
                      : _pickImage,
              icon: const Icon(
                Icons.swap_horiz,
                size: 18,
              ),
              label:
                  const Text(
                'Change',
              ),
            ),

            const SizedBox(width: 4),

            TextButton.icon(
              onPressed:
                  widget.isAnalyzing
                      ? null
                      : _removeImage,
              icon: const Icon(
                Icons.close,
                size: 18,
              ),
              label:
                  const Text(
                'Remove',
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return InkWell(
      onTap:
          widget.isAnalyzing
              ? null
              : _pickImage,
      child: const Center(
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add,
              size: 78,
              color:
                  AppColors.textPrimary,
            ),

            SizedBox(height: 12),

            Text(
              'Click to upload an image',
              style: TextStyle(
                color: AppColors
                    .textSecondary,
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
        _selectedImage!.bytes,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.contain,
        filterQuality:
            FilterQuality.high,
        errorBuilder: (
          context,
          error,
          stackTrace,
        ) {
          return const Center(
            child: Column(
              mainAxisSize:
                  MainAxisSize.min,
              children: [
                Icon(
                  Icons
                      .broken_image_outlined,
                  size: 48,
                  color:
                      AppColors.error,
                ),

                SizedBox(height: 12),

                Text(
                  'Unable to display this image.',
                  style: TextStyle(
                    color: AppColors
                        .textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}