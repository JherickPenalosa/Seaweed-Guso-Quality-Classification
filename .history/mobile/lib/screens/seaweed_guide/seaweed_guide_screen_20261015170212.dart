import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../data/seaweed_data.dart';
import '../../models/seaweed_info.dart';
import '../../widgets/seaweed_guide/seaweed_card.dart';
import '../../widgets/common/empty_state.dart';
import 'seaweed_detail_screen.dart';

class SeaweedGuideScreen extends StatefulWidget {
  const SeaweedGuideScreen({super.key});

  @override
  State<SeaweedGuideScreen> createState() => _SeaweedGuideScreenState();
}

class _SeaweedGuideScreenState extends State<SeaweedGuideScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _selectedLanguage = 'English';

  final List<String> _languages = const [
    'English',
    'Filipino',
    'Bisaya',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredSeaweeds = _getFilteredSeaweeds();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              _buildHeader(context),
              const SizedBox(height: AppSpacing.xl),
              _buildSearchField(),
              const SizedBox(height: AppSpacing.md),
              _buildLanguageSelector(),
              const SizedBox(height: AppSpacing.xl),
              _buildIntroCard(context),
              const SizedBox(height: AppSpacing.lg),

              if (filteredSeaweeds.isEmpty)
                _buildEmptyState(context)
              else
                _buildSeaweedList(
                  context,
                  filteredSeaweeds,
                ),
            ],
          ),
        ),
      ),
    );
  }

  List<SeaweedInfo> _getFilteredSeaweeds() {
    final query = _searchController.text;

    return SeaweedData.seaweeds.where((seaweed) {
      return seaweed.matchesSearch(
        query,
        _selectedLanguage,
      );
    }).toList();
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: AppColors.primaryDark,
            borderRadius: BorderRadius.circular(AppRadius.medium),
            border: Border.all(
              color: AppColors.primary,
            ),
          ),
          child: const Icon(
            Icons.menu_book_outlined,
            color: AppColors.primary,
            size: 25,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Seaweed Guide',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Explore supported seaweed species and learn their basic characteristics.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      onChanged: (_) {
        setState(() {});
      },
      style: const TextStyle(
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: 'Search seaweed...',
        prefixIcon: const Icon(
          Icons.search,
          color: AppColors.textMuted,
        ),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                onPressed: () {
                  _searchController.clear();
                  setState(() {});
                },
                icon: const Icon(
                  Icons.close,
                  color: AppColors.textMuted,
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildLanguageSelector() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(
          color: AppColors.borderLight,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedLanguage,
          isExpanded: true,
          dropdownColor: AppColors.surface,
          iconEnabledColor: AppColors.primary,
          style: const TextStyle(
            color: AppColors.textPrimary,
          ),
          items: _languages.map((language) {
            return DropdownMenuItem<String>(
              value: language,
              child: Row(
                children: [
                  const Icon(
                    Icons.language_outlined,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(language),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value == null) return;

            setState(() {
              _selectedLanguage = value;
            });
          },
        ),
      ),
    );
  }

  Widget _buildIntroCard(BuildContext context) {
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.eco_outlined,
            color: AppColors.primary,
            size: 24,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              'Browse the seaweed species supported by gUSo. '
              'You can search by name and switch the guide language.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeaweedList(
    BuildContext context,
    List<SeaweedInfo> seaweeds,
  ) {
    return Column(
      children: seaweeds.map((seaweed) {
        return Padding(
          padding: const EdgeInsets.only(
            bottom: AppSpacing.md,
          ),
          child: SeaweedCard(
            seaweed: seaweed,
            language: _selectedLanguage,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => SeaweedDetailScreen(
                    seaweed: seaweed,
                    language: _selectedLanguage,
                  ),
                ),
              );
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return EmptyState(
      icon: Icons.search_off_outlined,
      title: 'No seaweed found',
      message: 'Try another search term.',
      actionLabel: 'Clear Search',
      actionIcon: Icons.clear,
      onAction: () {
        _searchController.clear();

        setState(() {});
      },
    );
  }
}