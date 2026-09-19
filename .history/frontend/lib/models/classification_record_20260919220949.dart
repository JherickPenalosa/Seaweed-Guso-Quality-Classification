import 'dart:typed_data';

import 'classification_result.dart';

class ClassificationRecord {
  final String id;
  final String fileName;
  final Uint8List imageBytes;
  final ClassificationResult result;
  final DateTime createdAt;

  const ClassificationRecord({
    required this.id,
    required this.fileName,
    required this.imageBytes,
    required this.result,
    required this.createdAt,
  });

  String get displayTitle {
    return '${result.qualityClass} · ${_formatTime(createdAt)}';
  }

  String get displayDate {
    return _formatDate(createdAt);
  }

  static String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');

    final period = hour >= 12 ? 'PM' : 'AM';

    final twelveHour = hour == 0
        ? 12
        : hour > 12
            ? hour - 12
            : hour;

    return '$twelveHour:$minute $period';
  }

  static String _formatDate(DateTime dateTime) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${months[dateTime.month - 1]} ${dateTime.day}, ${dateTime.year}';
  }
}