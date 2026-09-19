import 'dart:typed_data';

class SelectedImage {
  final String fileName;
  final Uint8List bytes;

  const SelectedImage({
    required this.fileName,
    required this.bytes,
  });

  String get extension {
    final parts = fileName.split('.');

    if (parts.length < 2) {
      return '';
    }

    return parts.last.toLowerCase();
  }

  bool get isSupportedFormat {
    const supportedExtensions = {
      'png',
      'jpg',
      'jpeg',
    };

    return supportedExtensions.contains(extension);
  }
}