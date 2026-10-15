class ClassificationResult {
  final int? classificationId;
  final String species;
  final double confidence;
  final String? modelName;

  const ClassificationResult({
    this.classificationId,
    required this.species,
    required this.confidence,
    this.modelName,
  });

  factory ClassificationResult.fromJson(Map<String, dynamic> json) {
    return ClassificationResult(
      classificationId: _parseInt(json['classification_id']),
      species: json['species']?.toString() ?? 'Unknown',
      confidence: _parseDouble(json['confidence']),
      modelName: json['model_name']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'classification_id': classificationId,
      'species': species,
      'confidence': confidence,
      'model_name': modelName,
    };
  }

  double get confidencePercentage {
    if (confidence <= 1) {
      return confidence * 100;
    }

    return confidence;
  }

  String get formattedConfidence {
    return '${confidencePercentage.toStringAsFixed(2)}%';
  }

  static double _parseDouble(dynamic value) {
    if (value is double) {
      return value;
    }

    if (value is int) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }

  static int? _parseInt(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is int) {
      return value;
    }

    return int.tryParse(value.toString());
  }
}