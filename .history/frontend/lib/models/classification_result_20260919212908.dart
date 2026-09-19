class ClassificationResult {
  final String qualityClass;
  final String qualityLabel;
  final double confidence;

  final String commonName;
  final String? scientificName;
  final String localName;

  final String freshnessLevel;
  final String imageQuality;

  final String color;
  final String visualTexture;
  final String surfaceCondition;
  final String visibleDefects;

  final String summary;

  const ClassificationResult({
    required this.qualityClass,
    required this.qualityLabel,
    required this.confidence,
    required this.commonName,
    this.scientificName,
    required this.localName,
    required this.freshnessLevel,
    required this.imageQuality,
    required this.color,
    required this.visualTexture,
    required this.surfaceCondition,
    required this.visibleDefects,
    required this.summary,
  });

  /// Temporary frontend-only result.
  ///
  /// This will eventually be replaced by data returned
  /// by the real classification backend.
  factory ClassificationResult.mock() {
    return const ClassificationResult(
      qualityClass: 'Class A',
      qualityLabel: 'High Quality',
      confidence: 94.0,
      commonName: 'Guso',
      scientificName: 'Eucheuma denticulatum',
      localName: 'Guso',
      freshnessLevel: 'Fresh',
      imageQuality: 'Clear',
      color: 'Healthy green coloration',
      visualTexture: 'Firm-looking and intact',
      surfaceCondition: 'Clean surface with minimal discoloration',
      visibleDefects: 'No significant visible defects',
      summary:
          'The uploaded Guso image shows visual characteristics associated '
          'with high-quality and fresh seaweed.',
    );
  }
}