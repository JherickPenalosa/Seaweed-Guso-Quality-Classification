import 'dart:io';

import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../models/classification_record.dart';

import 'package:provider/provider.dart';

import '../../providers/settings_provider.dart';

class HistoryDetailScreen extends StatelessWidget {
  final ClassificationRecord record;

  const HistoryDetailScreen({
    super.key,
    required this.record,
  });

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceDark,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        title: const Text(
          'Classification Details',
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImage(),
              const SizedBox(height: AppSpacing.lg),
              _buildResultCard(
                context, 
                showConfidence: settingsProvider.showConfidence,
                showImageQuality: settingsProvider.showImageQuality,
              ),
              const SizedBox(height: AppSpacing.lg),
              _buildSavedInfoCard(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.large),
      child: AspectRatio(
        aspectRatio: 1,
        child: Image.file(
          File(record.imagePath),
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (
            context,
            error,
            stackTrace,
          ) {
            return Container(
              color: AppColors.surfaceDark,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.broken_image_outlined,
                      color: AppColors.textMuted,
                      size: 52,
                    ),
                    SizedBox(height: AppSpacing.sm),
                    Text(
                      'Image unavailable',
                      style: TextStyle(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildResultCard(BuildContext context, {
  required bool showConfidence, required bool showImageQuality,}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(
          color: AppColors.primary,
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.eco_outlined,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Classification Result',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          Text(
            'Species',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textMuted,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            record.species,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
          ),

          if (showConfidence) ...[
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Confidence',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textMuted,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              record.formattedConfidence,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],

          if (record.modelName != null &&
              record.modelName!.trim().isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Model',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textMuted,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              record.modelName!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSavedInfoCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(
          color: AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.history_outlined,
                color: AppColors.primary,
                size: 22,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Saved Record',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          _buildInfoRow(
            context,
            label: 'Record ID',
            value: record.id.toString(),
          ),

          const SizedBox(height: AppSpacing.md),

          _buildInfoRow(
            context,
            label: 'Saved Date',
            value: _formatDate(record.createdAt),
          ),

          const SizedBox(height: AppSpacing.md),

          _buildInfoRow(
            context,
            label: 'Image Location',
            value: record.imagePath,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textMuted,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          value.trim().isEmpty ? 'Not available' : value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '${date.year}-$month-$day  $hour:$minute';
  }
}