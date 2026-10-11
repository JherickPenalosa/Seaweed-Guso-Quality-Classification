import '../models/classification_result.dart';
import '../models/selected_image.dart';

enum ClassificationFailureType {
  invalidImage,
  serviceUnavailable,
  requestTimeout,
  serverError,
  unknown,
}

class ClassificationServiceException implements Exception {
  const ClassificationServiceException({
    required this.type,
    required this.message,
  });

  final ClassificationFailureType type;
  final String message;

  @override
  String toString() => message;
}

class ClassificationService {
  const ClassificationService();

  Future<ClassificationResult> classifyImage(
    SelectedImage image,
  ) async {
    if (image.bytes.isEmpty) {
      throw const ClassificationServiceException(
        type: ClassificationFailureType.invalidImage,
        message:
            'The selected image contains no readable image data.',
      );
    }

    if (!image.isSupportedFormat) {
      throw const ClassificationServiceException(
        type: ClassificationFailureType.invalidImage,
        message:
            'Unsupported image format. Please use PNG, JPG, or JPEG.',
      );
    }

    /*
     * TEMPORARY FRONTEND MOCK
     *
     * This delay represents the classification request while
     * the frontend is not yet connected to the real FastAPI API.
     *
     * When backend integration begins, replace this section
     * with the real HTTP request.
     */

    await Future.delayed(
      const Duration(seconds: 3),
    );

    return ClassificationResult.mock();
  }
}