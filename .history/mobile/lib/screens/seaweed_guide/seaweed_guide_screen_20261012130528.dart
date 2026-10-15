import 'package:flutter/material.dart';

import '../../app/theme.dart';

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
              _buildTemporaryGuideList(context),
            ],
          ),
        ),
      ),
    );
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

  Widget _buildTemporaryGuideList(BuildContext context) {
    final query = _searchController.text.trim().toLowerCase();

    final seaweeds = [
      'Caulerpa lentillifera',
      'Caulerpa sertularioides',
      'Kappaphycus spp.',
      'Padina australis',
      'Sargassum muticum',
      'Turbinaria spp.',
      'Ulva lactuca',
    ];

    final filtered = seaweeds.where((name) {
      return name.toLowerCase().contains(query);
    }).toList();

    if (filtered.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.large),
          border: Border.all(
            color: AppColors.borderLight,
          ),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.search_off_outlined,
              color: AppColors.textMuted,
              size: 48,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No seaweed found',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Try another search term.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: filtered.map((name) {
        return Padding(
          padding: const EdgeInsets.only(
            bottom: AppSpacing.md,
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.large),
              border: Border.all(
                color: AppColors.borderLight,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDark,
                    borderRadius: BorderRadius.circular(
                      AppRadius.medium,
                    ),
                    border: Border.all(
                      color: AppColors.primaryDark,
                    ),
                  ),
                  child: const Icon(
                    Icons.eco_outlined,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$_selectedLanguage guide information coming next.',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.textMuted,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}