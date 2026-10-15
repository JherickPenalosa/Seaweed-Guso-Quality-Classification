import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../models/classification_result.dart';

enum ClassificationFailureType {
  invalidImage,
  serviceUnavailable,
  requestTimeout,
  serverError,
  unknown,
}

class ClassificationServiceException implements Exception {
  final ClassificationFailureType type;
  final String message;

  const ClassificationServiceException({
    required this.type,
    required this.message,
  });

  @override
  String toString() => message;
}

class ClassificationService {
  const ClassificationService();

  // IMPORTANT:
  // Replace this with your computer's local IPv4 address.
  //
  // Example:
  // http://192.168.1.5:8000
  //
  // Do NOT use localhost or 127.0.0.1 on a physical phone,
  // because that would point to the phone itself.
  static const String baseUrl = 'http://192.168.1.8:8000';

  Future<ClassificationResult> classifyImage(XFile image) async {
    try {
      final uri = Uri.parse('$baseUrl/api/classify');

      final request = http.MultipartRequest(
        'POST',
        uri,
      );

      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          image.path,
        ),
      );

      final streamedResponse = await request.send().timeout(
            const Duration(seconds: 30),
          );

      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> json =
            jsonDecode(response.body) as Map<String, dynamic>;

        return ClassificationResult.fromJson(json);
      }

      if (response.statusCode == 400 ||
          response.statusCode == 415 ||
          response.statusCode == 422) {
        throw const ClassificationServiceException(
          type: ClassificationFailureType.invalidImage,
          message:
              'The selected image could not be processed. Please choose another image.',
        );
      }

      if (response.statusCode >= 500) {
        throw const ClassificationServiceException(
          type: ClassificationFailureType.serverError,
          message:
              'The classification server encountered an error. Please try again.',
        );
      }

      throw ClassificationServiceException(
        type: ClassificationFailureType.unknown,
        message:
            'Classification failed with status code ${response.statusCode}.',
      );
    } on ClassificationServiceException {
      rethrow;
    } on http.ClientException {
      throw const ClassificationServiceException(
        type: ClassificationFailureType.serviceUnavailable,
        message:
            'Unable to connect to the classification server. Check that the backend is running and both devices are on the same network.',
      );
    } on FormatException {
      throw const ClassificationServiceException(
        type: ClassificationFailureType.serverError,
        message:
            'The server returned an invalid response.',
      );
    } catch (error) {
      final errorText = error.toString().toLowerCase();

      if (errorText.contains('timeout')) {
        throw const ClassificationServiceException(
          type: ClassificationFailureType.requestTimeout,
          message:
              'The classification request timed out. Please try again.',
        );
      }

      throw ClassificationServiceException(
        type: ClassificationFailureType.unknown,
        message: 'Unable to classify image: $error',
      );
    }
  }
}