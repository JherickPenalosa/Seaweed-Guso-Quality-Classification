import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../models/classification_result.dart';

/// Displays photographic measurements separately from the AI quality grade.
/// These measurements cover the whole image, not segmented seaweed tissue.
class CharacteristicsPanel extends StatelessWidget {
  final ClassificationResult result;

  const CharacteristicsPanel({super.key, required this.result});

  static bool _hasMeasurement(String value) {
    final normalized = value.trim().toLowerCase();
    return normalized.isNotEmpty &&
        normalized != 'not analyzed' &&
        normalized != 'not separately analyzed' &&
        normalized != 'not available' &&
        normalized != 'unknown' &&
        normalized != 'n/a';
  }

  @override
  Widget build(BuildContext context) {
    final hasColor = _hasMeasurement(result.color);
    final hasTexture = _hasMeasurement(result.visualTexture);
    final hasPhotoQuality = _hasMeasurement(result.imageQuality);

    // Only show these additional fields when the backend has genuinely
    // supplied an observation. Never invent a surface or defect assessment.
    final hasSurface = _hasMeasurement(result.surfaceCondition);
    final hasDefects = _hasMeasurement(result.visibleDefects);

    final hasMeasurements =
        hasColor || hasTexture || hasPhotoQuality || hasSurface || hasDefects;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(color: AppColors.borderLight, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.tune_outlined, color: AppColors.primary, size: 25),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Image Characteristics',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Measurements from the uploaded photograph. These are different '
            'from the AI quality grade (Fresh, Regular, or Poor).',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 22),

          if (hasMeasurements)
            LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final columns = width >= 810
                    ? 3
                    : width >= 520
                    ? 2
                    : 1;

                const spacing = 14.0;
                final itemWidth = (width - spacing * (columns - 1)) / columns;

                final items = <Widget>[
                  _CharacteristicItem(
                    icon: Icons.palette_outlined,
                    title: 'Dominant Color',
                    value: hasColor ? result.color : 'Not analyzed',
                    description:
                        'Most prominent color in the photograph, including '
                        'the background.',
                  ),
                  _CharacteristicItem(
                    icon: Icons.texture_outlined,
                    title: 'Visual Texture',
                    value: hasTexture ? result.visualTexture : 'Not analyzed',
                    description:
                        'Visible edge and texture detail; not a direct '
                        'measurement of seaweed health.',
                  ),
                  _CharacteristicItem(
                    icon: Icons.image_outlined,
                    title: 'Photo Quality',
                    value: hasPhotoQuality
                        ? result.imageQuality
                        : 'Not analyzed',
                    description:
                        'Photographic assessment, not the Fresh, Regular, '
                        'or Poor quality prediction.',
                  ),
                  if (hasSurface)
                    _CharacteristicItem(
                      icon: Icons.visibility_outlined,
                      title: 'Surface Condition',
                      value: result.surfaceCondition,
                      description: 'An observation provided by the backend.',
                    ),
                  if (hasDefects)
                    _CharacteristicItem(
                      icon: Icons.warning_amber_rounded,
                      title: 'Visible Defects',
                      value: result.visibleDefects,
                      description: 'An observation provided by the backend.',
                    ),
                ];

                return Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: [
                    for (final item in items)
                      SizedBox(width: itemWidth, child: item),
                  ],
                );
              },
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(AppRadius.medium),
                border: Border.all(color: AppColors.disabled),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.primary),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'No image measurements are available for this upload.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 18),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              borderRadius: BorderRadius.circular(AppRadius.medium),
              border: Border.all(color: AppColors.disabled),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: AppColors.primary, size: 20),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Measurements include the image background. They do not '
                    'independently verify species, freshness, surface '
                    'condition, or physical defects.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CharacteristicItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String description;

  const _CharacteristicItem({
    required this.icon,
    required this.title,
    required this.value,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(color: AppColors.disabled),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primaryDark,
              borderRadius: BorderRadius.circular(AppRadius.small),
            ),
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
          const SizedBox(height: 14),

          Text(
            title,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            description,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
