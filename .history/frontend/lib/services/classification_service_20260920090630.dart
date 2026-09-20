import '../models/classification_result.dart';
import '../models/selected_image.dart';

class ClassificationService {
  const ClassificationService();

  Future<ClassificationResult> classifyImage(
    SelectedImage image,
  ) async {
    // Temporary frontend simulation.
    //
    // This delay represents the time that will later be spent
    // sending the image to the backend and waiting for the
    // classification response.
    await Future.delayed(
      const Duration(seconds: 3),
    );

    // The image parameter is intentionally kept here because
    // the real implementation will send image.bytes and
    // image.fileName to the backend.
    if (image.bytes.isEmpty) {
      throw Exception(
        'The selected image contains no data.',
      );
    }

    return ClassificationResult.mock();
  }
}