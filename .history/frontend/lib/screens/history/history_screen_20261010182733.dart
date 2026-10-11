import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme.dart';
import '../../models/classification_record.dart';
import '../../providers/classification_provider.dart';
import '../../widgets/classification/characteristics_panel.dart';
import '../../widgets/classification/classification_summary.dart';

import '../../widgets/common/empty_state.dart';
import '../../widgets/common/retry_state.dart';
import '../../widgets/common/skeleton_box.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  static const double _historyBreakpoint = 900;

  @override
  Widget build(BuildContext context) {
    final provider =
        context.watch<ClassificationProvider>();

    final records = provider.records;

    if (provider.isLoadingHistory) {
      return const _HistoryLoadingView();
    }

    if (provider.historyError != null) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 560,
            ),
            child: RetryState(
              title: 'Unable to Load History',
              message:
                  provider.historyError ??
                  'Saved classification records could not be loaded.',
              onRetry: () {
                context
                    .read<ClassificationProvider>()
                    .retryHistory();
              },
            ),
          ),
        ),
      );
    }

    if (records.isEmpty) {
      return const _EmptyHistoryView();
    }

    final selectedRecord =
        provider.selectedRecord ?? records.first;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide =
            constraints.maxWidth >= _historyBreakpoint;

        if (isWide) {
          return _buildWideLayout(
            records,
            selectedRecord,
          );
        }

        return _buildCompactLayout(
          records,
          selectedRecord,
        );
      },
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

        Container(
          width: 1,
          color: AppColors.disabled,
        ),

        Expanded(
          child: _HistoryDetails(
            record: selectedRecord,
          ),
        ),
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

          Container(
            height: 1,
            color: AppColors.disabled,
          ),

          _HistoryDetails(
            record: selectedRecord,
            useInternalScroll: false,
          ),
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
        final isWide =
            constraints.maxWidth >= _breakpoint;

        if (isWide) {
          return const Row(
            children: [
              SizedBox(
                width: 280,
                child: _HistoryListSkeleton(),
              ),

              VerticalDivider(
                width: 1,
                thickness: 1,
                color: AppColors.disabled,
              ),

              Expanded(
                child: _HistoryDetailsSkeleton(),
              ),
            ],
          );
        }

        return const SingleChildScrollView(
          child: Column(
            children: [
              _HistoryCompactSkeleton(),

              Divider(
                height: 1,
                thickness: 1,
                color: AppColors.disabled,
              ),

              _HistoryDetailsSkeleton(),
            ],
          ),
        );
      },
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
          SkeletonBox(
            width: 140,
            height: 20,
          ),

          SizedBox(height: 10),

          SkeletonBox(
            width: 110,
            height: 12,
          ),

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
        borderRadius: BorderRadius.circular(
          AppRadius.medium,
        ),
      ),
      child: const Row(
        children: [
          SkeletonBox(
            width: 52,
            height: 52,
            borderRadius: 8,
          ),

          SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(
                  width: 100,
                  height: 14,
                ),

                SizedBox(height: 8),

                SkeletonBox(
                  width: 75,
                  height: 10,
                ),

                SizedBox(height: 6),

                SkeletonBox(
                  width: 120,
                  height: 10,
                ),
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
              borderRadius: BorderRadius.circular(
                AppRadius.large,
              ),
              border: Border.all(
                color: AppColors.borderPrimary,
                width: 1.5,
              ),
            ),
            child: const Row(
              children: [
                SkeletonBox(
                  width: 48,
                  height: 48,
                  borderRadius: 12,
                ),

                SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      SkeletonBox(
                        width: 220,
                        height: 20,
                      ),

                      SizedBox(height: 10),

                      SkeletonBox(
                        width: 170,
                        height: 12,
                      ),

                      SizedBox(height: 7),

                      SkeletonBox(
                        width: 130,
                        height: 11,
                      ),
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
          padding: EdgeInsets.fromLTRB(
            20,
            22,
            20,
            8,
          ),
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
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
          ),
          child: Text(
            '${records.length} saved classification'
            '${records.length == 1 ? '' : 's'}',
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 12,
            ),
          ),
        ),

        const SizedBox(height: 16),

        if (compact)
          SizedBox(
            height: 130,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 4,
              ),
              itemCount: records.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final record = records[index];

                final isSelected =
                    record.id == selectedRecord.id;

                return SizedBox(
                  width: 220,
                  child: _HistoryListItem(
                    record: record,
                    isSelected: isSelected,
                    onTap: () {
                      context
                          .read<
                              ClassificationProvider
                          >()
                          .selectRecord(record);
                    },
                  ),
                );
              },
            ),
          )
        else
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 4,
              ),
              itemCount: records.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final record = records[index];

                final isSelected =
                    record.id == selectedRecord.id;

                return _HistoryListItem(
                  record: record,
                  isSelected: isSelected,
                  onTap: () {
                    context
                        .read<
                            ClassificationProvider
                        >()
                        .selectRecord(record);
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
          ? Padding(
              padding: const EdgeInsets.only(
                bottom: 12,
              ),
              child: content,
            )
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
      color: isSelected
          ? AppColors.primaryDark
          : AppColors.surfaceDark,
      borderRadius: BorderRadius.circular(
        AppRadius.medium,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(
          AppRadius.medium,
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(
                  AppRadius.small,
                ),
                child: SizedBox(
                  width: 52,
                  height: 52,
                  child: Image.memory(
                    record.imageBytes,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
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

  const _HistoryDetails({
    required this.record,
    this.useInternalScroll = true,
  });

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _RecordHeader(
            record: record,
          ),

          const SizedBox(height: 24),

          _ImagePreview(
            record: record,
          ),

          const SizedBox(height: 24),

          ClassificationSummary(
            result: record.result,
          ),

          const SizedBox(height: 24),

          CharacteristicsPanel(
            result: record.result,
          ),
        ],
      ),
    );

    if (useInternalScroll) {
      return SingleChildScrollView(
        child: content,
      );
    }

    return content;
  }
}

class _RecordHeader extends StatelessWidget {
  final ClassificationRecord record;

  const _RecordHeader({
    required this.record,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(
          AppRadius.large,
        ),
        border: Border.all(
          color: AppColors.borderPrimary,
          width: 1.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primaryDark,
              borderRadius: BorderRadius.circular(
                AppRadius.medium,
              ),
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
              crossAxisAlignment:
                  CrossAxisAlignment.start,
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
              _confirmDelete(
                context,
                record,
              );
            },
            icon: const Icon(
              Icons.delete_outline,
              color: AppColors.error,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    ClassificationRecord record,
  ) async {
    final shouldDelete =
        await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text(
            'Delete Record',
            style: TextStyle(
              color: AppColors.textPrimary,
            ),
          ),
          content: const Text(
            'Are you sure you want to delete this saved '
            'classification record?',
            style: TextStyle(
              color: AppColors.textSecondary,
            ),
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

    context
        .read<ClassificationProvider>()
        .removeRecord(record.id);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Classification record deleted.',
        ),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

class _ImagePreview extends StatelessWidget {
  final ClassificationRecord record;

  const _ImagePreview({
    required this.record,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final imageHeight =
            constraints.maxWidth < 600 ? 300.0 : 420.0;

        return Container(
          width: double.infinity,
          height: imageHeight,
          decoration: BoxDecoration(
            color: AppColors.surfaceDark,
            borderRadius: BorderRadius.circular(
              AppRadius.large,
            ),
            border: Border.all(
              color: AppColors.borderLight,
              width: 2,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(
              AppRadius.large - 2,
            ),
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
          constraints: const BoxConstraints(
            maxWidth: 520,
          ),
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