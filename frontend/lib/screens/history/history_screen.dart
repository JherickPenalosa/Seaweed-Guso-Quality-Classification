import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme.dart';
import '../../models/classification_record.dart';
import '../../providers/classification_provider.dart';
import '../../services/history_service.dart';
import '../../widgets/classification/characteristics_panel.dart';
import '../../widgets/classification/classification_summary.dart';

import '../../widgets/common/empty_state.dart';
import '../../widgets/common/retry_state.dart';
import '../../widgets/common/skeleton_box.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  static const double _historyBreakpoint = 900;

  Widget _buildGradientBackground({required Widget child}) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.fromARGB(255, 3, 78, 3),
            Color(0xFF0B2D0D), 
            Color(0xFF001000)
          ],
          stops: [0.0, 0.48, 1.0],
        ),
      ),
      child: child,
    );
  }

  @override
  void initState() {
    super.initState();
    // The in-memory provider is empty after a browser refresh.
    // Reload persisted records from the authenticated FastAPI History API.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ClassificationProvider>().loadSavedHistory();
      }
    });
  }

  Widget _buildGradientBackground({required Widget child}) {
    return Container(
      width: double.infinity,
      height: double.infinity,
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
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ClassificationProvider>();

    final records = provider.records;
    final savedSummaries = provider.savedSummaries;

    if (provider.isLoadingHistory &&
        records.isEmpty &&
        savedSummaries.isEmpty) {
      return _buildGradientBackground(child: const _HistoryLoadingView());
    }

    if (provider.historyError != null &&
        records.isEmpty &&
        savedSummaries.isEmpty) {
      return _buildGradientBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: RetryState(
                title: 'Unable to Load History',
                message:
                    provider.historyError ??
                    'Saved classification records could not be loaded.',
                onRetry: () {
                  context.read<ClassificationProvider>().retryHistory();
                },
              ),
            ),
          ),
        ),
      );
    }

    if (savedSummaries.isNotEmpty) {
      // Server-confirmed, saved classifications, including after refresh.
      // Their images are downloaded through authenticated /history/{id}/image.
      return _buildGradientBackground(
        child: _SavedRecordsBrowser(summaries: savedSummaries),
      );
    }

    if (records.isEmpty) {
      return _buildGradientBackground(child: const _EmptyHistoryView());
    }

    final selectedRecord = provider.selectedRecord ?? records.first;

    return _buildGradientBackground(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= _historyBreakpoint;

          if (isWide) {
            return _buildWideLayout(records, selectedRecord);
          }
          return _buildCompactLayout(records, selectedRecord);
        },
      ),
    );
  }

  Widget _buildWideLayout(
    List<ClassificationRecord> records,
    ClassificationRecord selectedRecord,
  ) {
    return Row(
      children: [
        SizedBox(
          width: 280,
          child: _HistoryList(
            records: records,
            selectedRecord: selectedRecord,
            compact: false,
          ),
        ),

        Container(width: 1, color: AppColors.disabled),

        Expanded(child: _HistoryDetails(record: selectedRecord)),
      ],
    );
  }

  Widget _buildCompactLayout(
    List<ClassificationRecord> records,
    ClassificationRecord selectedRecord,
  ) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _HistoryList(
            records: records,
            selectedRecord: selectedRecord,
            compact: true,
          ),

          Container(height: 1, color: AppColors.disabled),

          _HistoryDetails(record: selectedRecord, useInternalScroll: false),
        ],
      ),
    );
  }
}

class _HistoryLoadingView extends StatelessWidget {
  const _HistoryLoadingView();

  static const double _breakpoint = 900;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= _breakpoint;

        if (isWide) {
          return const Row(
            children: [
              SizedBox(width: 280, child: _HistoryListSkeleton()),

              VerticalDivider(
                width: 1,
                thickness: 1,
                color: AppColors.disabled,
              ),

              Expanded(
                child: SingleChildScrollView(child: _HistoryDetailsSkeleton()),
              ),
            ],
          );
        }

        return const SingleChildScrollView(
          child: Column(
            children: [
              _HistoryCompactSkeleton(),

              Divider(height: 1, thickness: 1, color: AppColors.disabled),

              _HistoryDetailsSkeleton(),
            ],
          ),
        );
      },
    );
  }
}

class _HistoryCompactSkeleton extends StatelessWidget {
  const _HistoryCompactSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.sidebar,
      padding: const EdgeInsets.all(20),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBox(width: 140, height: 20),

          SizedBox(height: 10),

          SkeletonBox(width: 110, height: 12),

          SizedBox(height: 20),

          Row(
            children: [
              Expanded(child: _HistoryRecordSkeleton()),

              SizedBox(width: 10),

              Expanded(child: _HistoryRecordSkeleton()),
            ],
          ),
        ],
      ),
    );
  }
}

class _HistoryListSkeleton extends StatelessWidget {
  const _HistoryListSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.sidebar,
      padding: const EdgeInsets.all(20),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBox(width: 140, height: 20),

          SizedBox(height: 10),

          SkeletonBox(width: 110, height: 12),

          SizedBox(height: 24),

          _HistoryRecordSkeleton(),

          SizedBox(height: 10),

          _HistoryRecordSkeleton(),

          SizedBox(height: 10),

          _HistoryRecordSkeleton(),
        ],
      ),
    );
  }
}

class _HistoryRecordSkeleton extends StatelessWidget {
  const _HistoryRecordSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(AppRadius.medium),
      ),
      child: const Row(
        children: [
          SkeletonBox(width: 52, height: 52, borderRadius: 8),

          SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: 100, height: 14),

                SizedBox(height: 8),

                SkeletonBox(width: 75, height: 10),

                SizedBox(height: 6),

                SkeletonBox(width: 120, height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryDetailsSkeleton extends StatelessWidget {
  const _HistoryDetailsSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
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
            child: const Row(
              children: [
                SkeletonBox(width: 48, height: 48, borderRadius: 12),

                SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonBox(width: 220, height: 20),

                      SizedBox(height: 10),

                      SkeletonBox(width: 170, height: 12),

                      SizedBox(height: 7),

                      SkeletonBox(width: 130, height: 11),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          const SkeletonBox(
            width: double.infinity,
            height: 320,
            borderRadius: 18,
          ),

          const SizedBox(height: 24),

          const SkeletonBox(
            width: double.infinity,
            height: 180,
            borderRadius: 18,
          ),
        ],
      ),
    );
  }
}

class _HistoryList extends StatelessWidget {
  final List<ClassificationRecord> records;
  final ClassificationRecord selectedRecord;
  final bool compact;

  const _HistoryList({
    required this.records,
    required this.selectedRecord,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 22, 20, 8),
          child: Text(
            'Saved Records',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            '${records.length} saved classification'
            '${records.length == 1 ? '' : 's'}',
            style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
        ),

        const SizedBox(height: 16),

        if (compact)
          SizedBox(
            height: 130,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              itemCount: records.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final record = records[index];

                final isSelected = record.id == selectedRecord.id;

                return SizedBox(
                  width: 220,
                  child: _HistoryListItem(
                    record: record,
                    isSelected: isSelected,
                    onTap: () {
                      context.read<ClassificationProvider>().selectRecord(
                        record,
                      );
                    },
                  ),
                );
              },
            ),
          )
        else
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              itemCount: records.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final record = records[index];

                final isSelected = record.id == selectedRecord.id;

                return _HistoryListItem(
                  record: record,
                  isSelected: isSelected,
                  onTap: () {
                    context.read<ClassificationProvider>().selectRecord(record);
                  },
                );
              },
            ),
          ),
      ],
    );

    return Container(
      width: double.infinity,
      color: AppColors.sidebar,
      child: compact
          ? Padding(padding: const EdgeInsets.only(bottom: 12), child: content)
          : content,
    );
  }
}

class _HistoryListItem extends StatelessWidget {
  final ClassificationRecord record;
  final bool isSelected;
  final VoidCallback onTap;

  const _HistoryListItem({
    required this.record,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? AppColors.primaryDark : AppColors.surfaceDark,
      borderRadius: BorderRadius.circular(AppRadius.medium),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.small),
                child: SizedBox(
                  width: 52,
                  height: 52,
                  child: Image.memory(record.imageBytes, fit: BoxFit.cover),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.result.qualityClass,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      record.displayDate,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                      ),
                    ),

                    const SizedBox(height: 2),

                    Text(
                      record.fileName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HistoryDetails extends StatelessWidget {
  final ClassificationRecord record;
  final bool useInternalScroll;

  const _HistoryDetails({required this.record, this.useInternalScroll = true});

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _RecordHeader(record: record),

          const SizedBox(height: 24),

          _ImagePreview(record: record),

          const SizedBox(height: 24),

          ClassificationSummary(result: record.result),

          const SizedBox(height: 24),

          CharacteristicsPanel(result: record.result),
        ],
      ),
    );

    if (useInternalScroll) {
      return SingleChildScrollView(child: content);
    }

    return content;
  }
}

class _RecordHeader extends StatelessWidget {
  final ClassificationRecord record;

  const _RecordHeader({required this.record});

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primaryDark,
              borderRadius: BorderRadius.circular(AppRadius.medium),
            ),
            child: const Icon(
              Icons.history,
              color: AppColors.primary,
              size: 26,
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Saved Classification Record',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  '${record.displayDate} · ${record.displayTitle}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  record.fileName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          IconButton(
            tooltip: 'Delete record',
            onPressed: () {
              _confirmDelete(context, record);
            },
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    ClassificationRecord record,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text(
            'Delete Record',
            style: TextStyle(color: AppColors.textPrimary),
          ),
          content: const Text(
            'Are you sure you want to delete this saved '
            'classification record?',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('CANCEL'),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
              ),
              child: const Text('DELETE'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true || !context.mounted) {
      return;
    }

    context.read<ClassificationProvider>().removeRecord(record.id);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Classification record deleted.'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

class _ImagePreview extends StatelessWidget {
  final ClassificationRecord record;

  const _ImagePreview({required this.record});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final imageHeight = constraints.maxWidth < 600 ? 300.0 : 420.0;

        return Container(
          width: double.infinity,
          height: imageHeight,
          decoration: BoxDecoration(
            color: AppColors.surfaceDark,
            borderRadius: BorderRadius.circular(AppRadius.large),
            border: Border.all(color: AppColors.borderLight, width: 2),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.large - 2),
            child: Image.memory(
              record.imageBytes,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
            ),
          ),
        );
      },
    );
  }
}

class _EmptyHistoryView extends StatelessWidget {
  const _EmptyHistoryView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: const EmptyState(
            icon: Icons.history_outlined,
            title: 'No Saved Records',
            message:
                'Saved classification results will appear here. '
                'Classify a Guso image and press Save to create a record.',
          ),
        ),
      ),
    );
  }
}

/// PostgreSQL-backed records. This supplements the partner's existing
/// current-session History widgets without replacing their layout or styling.
class _SavedRecordsBrowser extends StatefulWidget {
  const _SavedRecordsBrowser({required this.summaries});

  final List<SavedClassificationSummary> summaries;

  @override
  State<_SavedRecordsBrowser> createState() => _SavedRecordsBrowserState();
}

class _SavedRecordsBrowserState extends State<_SavedRecordsBrowser> {
  int? _selectedId;

  @override
  Widget build(BuildContext context) {
    final summaries = widget.summaries;
    if (summaries.isEmpty) return const _EmptyHistoryView();

    final selectedId = summaries.any((s) => s.id == _selectedId)
        ? _selectedId!
        : summaries.first.id;
    final selected = summaries.firstWhere((s) => s.id == selectedId);

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 900;
        final list = _SavedRecordList(
          records: summaries,
          selectedId: selectedId,
          compact: !wide,
          onTap: (id) => setState(() => _selectedId = id),
        );
        final details = _SavedRecordDetails(
          key: ValueKey(selectedId),
          summary: selected,
          internalScroll: wide,
          onDelete: () => _deleteRecord(selected),
        );
        if (wide) {
          return Row(
            children: [
              SizedBox(width: 280, child: list),
              Container(width: 1, color: AppColors.disabled),
              Expanded(child: details),
            ],
          );
        }
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              list,
              Container(height: 1, color: AppColors.disabled),
              details,
            ],
          ),
        );
      },
    );
  }

  Future<void> _deleteRecord(SavedClassificationSummary summary) async {
    final provider = context.read<ClassificationProvider>();
    if (provider.isDeletingClassification(summary.id)) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Delete saved classification?'),
        content: Text(
          'Delete record #${summary.id} and its original image permanently? '
          'This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;
    try {
      await provider.deleteSavedClassification(summary.id);
      if (!mounted) return;
      setState(() => _selectedId = null);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saved classification deleted.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Delete failed: $error')));
    }
  }
}

class _SavedRecordList extends StatelessWidget {
  const _SavedRecordList({
    required this.records,
    required this.selectedId,
    required this.compact,
    required this.onTap,
  });

  final List<SavedClassificationSummary> records;
  final int selectedId;
  final bool compact;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final tiles = ListView.separated(
      scrollDirection: compact ? Axis.horizontal : Axis.vertical,
      itemCount: records.length,
      padding: const EdgeInsets.all(12),
      separatorBuilder: (_, _) =>
          SizedBox(width: compact ? 10 : 0, height: compact ? 0 : 10),
      itemBuilder: (context, index) {
        final record = records[index];
        final selected = record.id == selectedId;
        return SizedBox(
          width: compact ? 235 : null,
          child: Material(
            color: selected ? AppColors.primaryDark : AppColors.surfaceDark,
            borderRadius: BorderRadius.circular(AppRadius.medium),
            child: InkWell(
              borderRadius: BorderRadius.circular(AppRadius.medium),
              onTap: () => onTap(record.id),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(Icons.image_outlined, color: AppColors.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            record.qualityGrade,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            record.displayDate,
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 11,
                            ),
                          ),
                          Text(
                            '#${record.id} · ${record.fileName ?? 'Image'}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
    return Container(
      color: AppColors.sidebar,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: compact ? MainAxisSize.min : MainAxisSize.max,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 22, 20, 5),
            child: Text(
              'Saved Records',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              '${records.length} saved classification${records.length == 1 ? '' : 's'}',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
          ),
          if (compact)
            SizedBox(height: 140, child: tiles)
          else
            Expanded(child: tiles),
        ],
      ),
    );
  }
}

class _SavedRecordDetails extends StatelessWidget {
  const _SavedRecordDetails({
    super.key,
    required this.summary,
    required this.internalScroll,
    required this.onDelete,
  });

  final SavedClassificationSummary summary;
  final bool internalScroll;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ClassificationProvider>();
    final deleting = provider.isDeletingClassification(summary.id);
    final fields = <Widget>[
      _SavedDetailField(label: 'Quality Grade', value: summary.qualityGrade),
      _SavedDetailField(
        label: 'Quality Confidence',
        value: '${summary.confidencePercentage.toStringAsFixed(2)}%',
      ),
      _SavedDetailField(label: 'Model', value: summary.modelName),
      _SavedDetailField(label: 'Classified', value: summary.displayDate),
      if (summary.reportedColor != null)
        _SavedDetailField(label: 'Image Color', value: summary.reportedColor!),
      if (summary.reportedImageQuality != null)
        _SavedDetailField(
          label: 'Photographic Quality',
          value: summary.reportedImageQuality!,
        ),
      if (summary.reportedVisualTexture != null)
        _SavedDetailField(
          label: 'Image Texture',
          value: summary.reportedVisualTexture!,
        ),
      if (!summary.hasFullReport)
        const Padding(
          padding: EdgeInsets.only(top: 10),
          child: Text(
            'Detailed image measurements were not stored with this older record.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
    ];

    final body = Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border.all(color: AppColors.borderPrimary),
              borderRadius: BorderRadius.circular(AppRadius.large),
            ),
            child: Row(
              children: [
                const Icon(Icons.history, color: AppColors.primary, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Saved Classification #${summary.id}',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 21,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Refresh saved history',
                  onPressed: provider.isLoadingHistory
                      ? null
                      : () => context
                            .read<ClassificationProvider>()
                            .loadSavedHistory(),
                  icon: const Icon(Icons.refresh),
                  color: AppColors.primary,
                ),
                IconButton(
                  tooltip: 'Delete saved classification',
                  onPressed: deleting ? null : onDelete,
                  icon: deleting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.delete_outline),
                  color: AppColors.error,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          if (summary.hasImage)
            _SavedOriginalImage(classificationId: summary.id)
          else
            const SizedBox(
              height: 220,
              child: Center(child: Text('No stored image is available.')),
            ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border.all(color: AppColors.borderPrimary),
              borderRadius: BorderRadius.circular(AppRadius.large),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Stored Classification Results',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),
                ...fields,
                // Recover the measurements saved with this classification.
                // Older records without image_features remain readable.
                if (summary.reportedImageFeatures != null) ...[
                  const SizedBox(height: 14),
                  _SavedImageMeasurements(
                    features: summary.reportedImageFeatures!,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
    return internalScroll ? SingleChildScrollView(child: body) : body;
  }
}

/// Display the *stored* image measurements from FastAPI/PostgreSQL.
/// All percentages describe image pixels, including the background;
/// they are not estimated seaweed freshness or biological quality.
class _SavedImageMeasurements extends StatelessWidget {
  const _SavedImageMeasurements({required this.features});

  final Map<String, dynamic> features;

  Map<String, dynamic>? _section(String name) {
    final value = features[name];
    return value is Map ? Map<String, dynamic>.from(value) : null;
  }

  @override
  Widget build(BuildContext context) {
    final colorInfo = _section('color');
    final photoInfo = _section('image_quality');
    final textureInfo = _section('texture');

    final shares = <MapEntry<String, double>>[];
    final distribution = colorInfo?['color_distribution'];
    if (distribution is Map) {
      for (final item in distribution.entries) {
        final amount = item.value;
        if (amount is num && amount.isFinite) {
          shares.add(
            MapEntry(
              item.key.toString(),
              amount.toDouble().clamp(0.0, 100.0).toDouble(),
            ),
          );
        }
      }
      shares.sort((a, b) => b.value.compareTo(a.value));
    }

    final measurements = <Widget>[];
    final width = photoInfo?['width'];
    final height = photoInfo?['height'];
    if (width is num && height is num) {
      measurements.add(
        _SavedMetric(
          title: 'Image resolution',
          value: '${width.toInt()} × ${height.toInt()} pixels',
        ),
      );
    }
    for (final entry in [
      ('Brightness (0–255)', photoInfo?['brightness']),
      ('Contrast', photoInfo?['contrast']),
      ('Sharpness score', photoInfo?['sharpness_score']),
      ('Texture variation', textureInfo?['texture_variation']),
      ('Visible edge pixels', textureInfo?['edge_density_percentage']),
    ]) {
      final value = entry.$2;
      if (value is num && value.isFinite) {
        final suffix = entry.$1 == 'Visible edge pixels' ? '%' : '';
        measurements.add(
          _SavedMetric(
            title: entry.$1,
            value: '${value.toStringAsFixed(2)}$suffix',
          ),
        );
      }
    }

    final analyzedPixelPercentage = colorInfo?['analyzed_pixel_percentage'];
    final issues = photoInfo?['issues'];
    final validIssues = issues is List
        ? issues.whereType<String>().where((s) => s.trim().isNotEmpty).toList()
        : <String>[];

    if (shares.isEmpty && measurements.isEmpty && validIssues.isEmpty) {
      return const SizedBox.shrink();
    }

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
          const Row(
            children: [
              Icon(Icons.bar_chart_rounded, color: AppColors.primary, size: 23),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Saved Image Measurements',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          if (shares.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Text(
              'Image Color Distribution',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 14),
            for (final share in shares) ...[
              _SavedColorShareBar(label: share.key, percentage: share.value),
              const SizedBox(height: 12),
            ],
            if (analyzedPixelPercentage is num &&
                analyzedPixelPercentage.isFinite) ...[
              const SizedBox(height: 3),
              Text(
                '${analyzedPixelPercentage.toStringAsFixed(2)}% of photo pixels '
                'were included in color analysis.',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
            const SizedBox(height: 8),
            const Text(
              'Bars show the share of detected colors among analyzed '
              'colored pixels in the whole photo, including its background. '
              'They do not measure seaweed health or freshness.',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 12,
                height: 1.45,
              ),
            ),
          ],
          if (measurements.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Divider(color: AppColors.disabled),
            const SizedBox(height: 12),
            const Text(
              'Photo and Texture Statistics',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(spacing: 12, runSpacing: 12, children: measurements),
          ],
          if (validIssues.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Text(
              'Photo-quality checks',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            for (final issue in validIssues)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '• $issue',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _SavedColorShareBar extends StatelessWidget {
  const _SavedColorShareBar({required this.label, required this.percentage});

  final String label;
  final double percentage;

  Color get _barColor {
    switch (label.trim().toLowerCase()) {
      case 'green':
        return const Color(0xFF78D647);
      case 'brown':
        return const Color(0xFFA8774F);
      case 'red':
        return const Color(0xFFE56767);
      case 'orange':
        return const Color(0xFFF2A35A);
      case 'yellow':
        return const Color(0xFFE5CB56);
      case 'blue':
        return const Color(0xFF66A9E8);
      case 'purple':
        return const Color(0xFFAF8ADD);
      case 'pink':
        return const Color(0xFFE897B8);
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ),
            Text(
              '${percentage.toStringAsFixed(2)}%',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(7),
          child: LinearProgressIndicator(
            value: percentage / 100,
            minHeight: 13,
            backgroundColor: AppColors.disabled,
            color: _barColor,
          ),
        ),
      ],
    );
  }
}

class _SavedMetric extends StatelessWidget {
  const _SavedMetric({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 165),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.small),
        border: Border.all(color: AppColors.disabled),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _SavedDetailField extends StatelessWidget {
  const _SavedDetailField({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
          ),
        ],
      ),
    );
  }
}

// Loading is tied to this widget's lifetime, avoiding re-downloading the
// image every time Provider notifies listeners.
class _SavedOriginalImage extends StatefulWidget {
  const _SavedOriginalImage({required this.classificationId});
  final int classificationId;

  @override
  State<_SavedOriginalImage> createState() => _SavedOriginalImageState();
}

class _SavedOriginalImageState extends State<_SavedOriginalImage> {
  late Future<Uint8List> _imageFuture;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant _SavedOriginalImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.classificationId != widget.classificationId) _load();
  }

  void _load() {
    _imageFuture = const HistoryService().fetchSavedImage(
      widget.classificationId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List>(
      future: _imageFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const SizedBox(
            height: 350,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return SizedBox(
            height: 220,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Unable to load the saved image.'),
                  const SizedBox(height: 10),
                  OutlinedButton(
                    onPressed: () => setState(_load),
                    child: const Text('Retry image'),
                  ),
                ],
              ),
            ),
          );
        }
        return Container(
          width: double.infinity,
          height: 370,
          decoration: BoxDecoration(
            color: AppColors.surfaceDark,
            borderRadius: BorderRadius.circular(AppRadius.large),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.large),
            child: Image.memory(snapshot.data!, fit: BoxFit.contain),
          ),
        );
      },
    );
  }
}
