import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../widgets/classification/image_upload_area.dart';

import '../../models/classification_result.dart';
import '../../widgets/classification/classification_summary.dart';
import '../../widgets/classification/characteristics_panel.dart';
import '../../widgets/classification/result_actions.dart';
import '../../models/selected_image.dart';

import 'package:provider/provider.dart';

import '../../models/classification_record.dart';
import '../../providers/classification_provider.dart';

import '../../providers/settings_provider.dart';
import '../../widgets/common/error_message.dart';
import '../../providers/connectivity_provider.dart';
import '../../widgets/common/offline_banner.dart';

import '../../services/classification_service.dart';

class ClassificationScreen extends StatefulWidget {
  const ClassificationScreen({super.key});

  @override
  State<ClassificationScreen> createState() => _ClassificationScreenState();
}

class _ClassificationScreenState extends State<ClassificationScreen> {
  final ClassificationService _classificationService =
      const ClassificationService();

  SelectedImage? _selectedImage;

  bool _isAnalyzing = false;
  bool _isSaved = false;
  bool _isSaving = false;
  bool _saveFailed = false;

  ClassificationResult? _result;
  String? _errorMessage;

  bool get _hasImage => _selectedImage != null;
  bool get _hasResult => _result != null;

  // This field is used to control the carousel of images displayed at the top of the screen. It allows users to swipe through different images for classification.

  final PageController _carouselController = PageController();

  int _currentCarouselIndex = 0;

  final List<String> _carouselImages = const [
    'assets/images/carousel/carousel_1.jpg',
    'assets/images/carousel/carousel_2.jpg',
    'assets/images/carousel/carousel_3.jpg',
    'assets/images/carousel/carousel_4.jpg',
    'assets/images/carousel/carousel_5.jpg',
    'assets/images/carousel/carousel_6.jpg',
    'assets/images/carousel/carousel_7.jpg',
  ];

  void _handleImageChanged(SelectedImage? image) {
    setState(() {
      _selectedImage = image;
      _result = null;
      _isSaved = false;
      _isSaving = false;
      _saveFailed = false;
      _errorMessage = null;
    });

    context.read<ClassificationProvider>().clearSelectedRecord();
  }

  void _uploadNext() {
    final settings = context.read<SettingsProvider>();

    if (_hasResult && !_isSaved && settings.confirmBeforeDiscard) {
      _showUnsavedWarning();
      return;
    }

    _resetClassification();
  }

  Future<void> _saveResult() async {
    if (!_hasResult || _isSaved || _isSaving || _selectedImage == null) {
      return;
    }

    setState(() {
      _isSaving = true;
      _saveFailed = false;
    });

    try {
      final record = ClassificationRecord(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        fileName: _selectedImage!.fileName,
        imageBytes: _selectedImage!.bytes,
        result: _result!,
        createdAt: DateTime.now(),
      );

      context.read<ClassificationProvider>().addRecord(record);

      if (!mounted) {
        return;
      }

      setState(() {
        _isSaved = true;
        _saveFailed = false;
      });

      context.read<ClassificationProvider>().setUnsavedResult(false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Classification record saved successfully.'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _saveFailed = true;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _resetClassification() {
    setState(() {
      _selectedImage = null;
      _result = null;
      _isSaved = false;
      _isAnalyzing = false;
      _isSaving = false;
      _saveFailed = false;
      _errorMessage = null;
    });

    context.read<ClassificationProvider>().setUnsavedResult(false);

    context.read<ClassificationProvider>().clearSelectedRecord();
  }

  Future<void> _showUnsavedWarning() async {
    final shouldContinue = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text(
            'Unsaved Result',
            style: TextStyle(color: AppColors.textPrimary),
          ),
          content: const Text(
            'This classification result has not been saved yet. '
            'Do you want to continue and upload another image?',
            style: TextStyle(color: AppColors.textSecondary),
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
    final connectivity = context.read<ConnectivityProvider>();

    if (connectivity.isOffline) {
      setState(() {
        _errorMessage =
            'No internet connection. Connect to the internet '
            'and try classification again.';
      });

      return;
    }

    if (!_hasImage || _isAnalyzing) {
      return;
    }

    final image = _selectedImage;

    if (image == null) {
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _result = null;
      _errorMessage = null;
    });

    try {
      final result = await _classificationService.classifyImage(image);

      if (!mounted) {
        return;
      }

      setState(() {
        _result = result;
      });

      context.read<ClassificationProvider>().setUnsavedResult(true);
    } on ClassificationServiceException catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        switch (e.type) {
          case ClassificationFailureType.invalidImage:
            _errorMessage =
                'The selected image could not be processed. '
                'Please upload a valid PNG, JPG, or JPEG image.';
            break;

          case ClassificationFailureType.serviceUnavailable:
            _errorMessage =
                'The classification service is currently unavailable. '
                'Please try again later.';
            break;

          case ClassificationFailureType.requestTimeout:
            _errorMessage =
                'The classification request took too long. '
                'Please check your connection and try again.';
            break;

          case ClassificationFailureType.serverError:
            _errorMessage =
                'The server encountered an error while processing the image. '
                'Please try again.';
            break;

          case ClassificationFailureType.unknown:
            _errorMessage =
                'An unexpected classification error occurred. '
                'Please try again.';
            break;
        }
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage =
            'Unable to classify this image. '
            'Please try again or upload another image.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });
      }
    }
  }

  // Greeting section at the top of the screen

  Widget _buildGreetingSection(BuildContext context) {
    const firstName = 'User';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome back, $firstName',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Ready to check your seaweed quality today?',
          style: Theme.of(context).textTheme.bodyLarge
              ?.copyWith(color: AppColors.textSecondary, height: 1.4),
        ),
      ],
    );
  }

  // This is the method that displays the carousel of images at the top of the screen. It allows users to swipe through different images for classification.

  Widget _buildCarouselSection(BuildContext context) {
    return Column(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.large),
                  child: AspectRatio(
                    aspectRatio: 1600 / 700,
                    child: PageView.builder(
                      controller: _carouselController,
                      itemCount: _carouselImages.length,
                      onPageChanged: (index) {
                        setState(() {
                          _currentCarouselIndex = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        return Image.asset(
                          _carouselImages[index],
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: AppColors.surfaceDark,
                              child: const Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.image_not_supported_outlined,
                                      color: AppColors.textMuted,
                                      size: 42,
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      'Carousel image unavailable',
                                      style: TextStyle(
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),

                Positioned(
                  left: 16,
                  child: _buildCarouselArrow(
                    icon: Icons.chevron_left,
                    onPressed: _previousCarouselImage,
                  ),
                ),

                Positioned(
                  right: 16,
                  child: _buildCarouselArrow(
                    icon: Icons.chevron_right,
                    onPressed: _nextCarouselImage,
                  ),
                ),
              ],
            );
          },
        ),

        const SizedBox(height: 12),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_carouselImages.length, (index) {
            final isActive = index == _currentCarouselIndex;

            return AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: isActive ? 22 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary : AppColors.borderLight,
                borderRadius: BorderRadius.circular(999),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildCarouselArrow({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.black.withValues(alpha: 0.45),
      shape: const CircleBorder(),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: AppColors.textPrimary, size: 30),
        tooltip: 'Change carousel image',
      ),
    );
  }

  void _previousCarouselImage() {
    final previousIndex = _currentCarouselIndex == 0
        ? _carouselImages.length - 1
        : _currentCarouselIndex - 1;

    _carouselController.animateToPage(
      previousIndex,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _nextCarouselImage() {
    final nextIndex = _currentCarouselIndex == _carouselImages.length - 1
        ? 0
        : _currentCarouselIndex + 1;

    _carouselController.animateToPage(
      nextIndex,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  // Disposal
  @override
  void dispose() {
    _carouselController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final connectivity = context.watch<ConnectivityProvider>();
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.fromARGB(255, 3, 78, 3),
            Color(0xFF0B2D0D),
            Color(0xFF001000),
          ],
          stops: [0.0, 0.48, 1.0],
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.large),
                border: Border.all(color: AppColors.borderPrimary, width: 1.5),
              ),

              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.image_search_outlined,
                    color: AppColors.primary,
                    size: 32,
                  ),

                  const SizedBox(width: 16),

                  Expanded(
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

                        const SizedBox(height: 8),

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
                              : 'Upload a clear image of Guso seaweed to begin classification. '
                                    'For better results, use an image with good lighting '
                                    'and minimal background obstruction.',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            _buildGreetingSection(context),

            const SizedBox(height: 24),

            _buildCarouselSection(context),

            if (connectivity.isOffline) ...[
              const SizedBox(height: 16),

              OfflineBanner(
                message:
                    'Internet connection is required to classify '
                    'Guso images. You can still review the selected '
                    'image while offline.',
                onRetry: () async {
                  final connectivityProvider = context
                      .read<ConnectivityProvider>();

                  await connectivityProvider.refreshConnection();

                  if (!mounted) return;

                  if (connectivityProvider.isOnline) {
                    setState(() {
                      _errorMessage = null;
                    });
                  }
                },
              ),
            ],

            if (_errorMessage != null) ...[
              const SizedBox(height: 16),

              ErrorMessage(
                message: _errorMessage!,
                onDismiss: () {
                  setState(() {
                    _errorMessage = null;
                  });
                },
              ),
            ],

            const SizedBox(height: 24),

            ImageUploadArea(
              onImageChanged: _handleImageChanged,
              isAnalyzing: _isAnalyzing,
            ),

            if (_hasResult) ...[
              const SizedBox(height: 24),

              ClassificationSummary(result: _result!),

              const SizedBox(height: 24),

              CharacteristicsPanel(result: _result!),

              const SizedBox(height: 24),

              ResultActions(
                onUploadNext: _uploadNext,
                onSave: _saveResult,
                isSaved: _isSaved,
                isSaving: _isSaving,
                saveFailed: _saveFailed,
              ),
            ],

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed:
                    _hasImage &&
                        !_isAnalyzing &&
                        !_hasResult &&
                        connectivity.isOnline
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
                    : const Icon(Icons.auto_awesome_outlined),
                label: Text(
                  _isAnalyzing
                      ? 'ANALYZING...'
                      : connectivity.isOffline
                      ? 'OFFLINE'
                      : 'CLASSIFY',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
