import 'package:flutter/material.dart';

import '../../app/theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _showConfidence = true;
  bool _showImageQuality = true;
  bool _confirmBeforeDiscard = true;

  void _resetSettings() {
    setState(() {
      _showConfidence = true;
      _showImageQuality = true;
      _confirmBeforeDiscard = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Settings restored to defaults.'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  Future<void> _showResetConfirmation() async {
    final shouldReset = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text(
            'Reset settings?',
            style: TextStyle(
              color: AppColors.textPrimary,
            ),
          ),
          content: const Text(
            'This will restore all mobile preferences to their default values.',
            style: TextStyle(
              color: AppColors.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text(
                'Reset',
                style: TextStyle(
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (shouldReset == true) {
      _resetSettings();
    }
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
              _buildPreferencesSection(context),
              const SizedBox(height: AppSpacing.lg),
              _buildStorageSection(context),
              const SizedBox(height: AppSpacing.lg),
              _buildResetSection(context),
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
            Icons.settings_outlined,
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
                'Settings',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Manage your mobile app preferences.',
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

  Widget _buildPreferencesSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(
          color: AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(
            context,
            icon: Icons.tune_outlined,
            title: 'Preferences',
          ),
          const SizedBox(height: AppSpacing.md),

          _buildSwitchTile(
            context,
            title: 'Show Confidence',
            subtitle:
                'Display the confidence score after classification.',
            value: _showConfidence,
            onChanged: (value) {
              setState(() {
                _showConfidence = value;
              });
            },
          ),

          const Divider(),

          _buildSwitchTile(
            context,
            title: 'Show Image Quality',
            subtitle:
                'Display image quality information when available.',
            value: _showImageQuality,
            onChanged: (value) {
              setState(() {
                _showImageQuality = value;
              });
            },
          ),

          const Divider(),

          _buildSwitchTile(
            context,
            title: 'Confirm Before Discard',
            subtitle:
                'Ask before leaving an unsaved classification result.',
            value: _confirmBeforeDiscard,
            onChanged: (value) {
              setState(() {
                _confirmBeforeDiscard = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStorageSection(BuildContext context) {
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
          _buildSectionTitle(
            context,
            icon: Icons.storage_outlined,
            title: 'Storage',
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Saved classifications are currently stored only while the app is running.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Permanent local storage will be added in a later step.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textMuted,
                  height: 1.5,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildResetSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(
          color: AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(
            context,
            icon: Icons.restart_alt_outlined,
            title: 'Reset Preferences',
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Restore all settings to their original default values.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _showResetConfirmation,
              icon: const Icon(
                Icons.restore_outlined,
              ),
              label: const Text(
                'Reset to Defaults',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(
    BuildContext context, {
    required IconData icon,
    required String title,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppColors.primary,
          size: 21,
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );
  }

  Widget _buildSwitchTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      activeThumbColor: AppColors.primary,
      activeTrackColor: AppColors.primaryDark,
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
              height: 1.4,
            ),
      ),
      value: value,
      onChanged: onChanged,
    );
  }
}