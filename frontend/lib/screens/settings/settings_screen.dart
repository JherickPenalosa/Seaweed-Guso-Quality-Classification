import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme.dart';
import '../../providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings =
        context.watch<SettingsProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          _buildHeader(),

          const SizedBox(height: 24),

          _buildDisplaySettings(
            context,
            settings,
          ),

          const SizedBox(height: 24),

          _buildClassificationSettings(
            context,
            settings,
          ),

          const SizedBox(height: 24),

          _buildPreferencesSection(
            context,
          ),

          const SizedBox(height: 24),

          _buildAboutSection(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
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
      child: const Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.settings_outlined,
            color: AppColors.primary,
            size: 32,
          ),

          SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Settings',
                  style: TextStyle(
                    color:
                        AppColors.textPrimary,
                    fontSize: 24,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                SizedBox(height: 8),

                Text(
                  'Manage how classification information '
                  'and system behavior are displayed.',
                  style: TextStyle(
                    color:
                        AppColors.textSecondary,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisplaySettings(
    BuildContext context,
    SettingsProvider settings,
  ) {
    return _SettingsSection(
      title: 'Result Display',
      children: [
        SwitchListTile(
          value: settings.showConfidence,
          onChanged: (value) {
            context
                .read<SettingsProvider>()
                .setShowConfidence(value);
          },
          activeThumbColor:
              AppColors.primary,
          title: const Text(
            'Show Confidence',
            style: TextStyle(
              color:
                  AppColors.textPrimary,
              fontWeight:
                  FontWeight.w600,
            ),
          ),
          subtitle: const Text(
            'Display the model confidence percentage '
            'in classification results.',
            style: TextStyle(
              color:
                  AppColors.textSecondary,
            ),
          ),
        ),

        const Divider(),

        SwitchListTile(
          value:
              settings.showImageQuality,
          onChanged: (value) {
            context
                .read<SettingsProvider>()
                .setShowImageQuality(value);
          },
          activeThumbColor:
              AppColors.primary,
          title: const Text(
            'Show Image Quality',
            style: TextStyle(
              color:
                  AppColors.textPrimary,
              fontWeight:
                  FontWeight.w600,
            ),
          ),
          subtitle: const Text(
            'Display whether the uploaded image is clear '
            'or may affect classification quality.',
            style: TextStyle(
              color:
                  AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildClassificationSettings(
    BuildContext context,
    SettingsProvider settings,
  ) {
    return _SettingsSection(
      title: 'Classification',
      children: [
        SwitchListTile(
          value:
              settings.confirmBeforeDiscard,
          onChanged: (value) {
            context
                .read<SettingsProvider>()
                .setConfirmBeforeDiscard(
                  value,
                );
          },
          activeThumbColor:
              AppColors.primary,
          title: const Text(
            'Confirm Before Discarding Results',
            style: TextStyle(
              color:
                  AppColors.textPrimary,
              fontWeight:
                  FontWeight.w600,
            ),
          ),
          subtitle: const Text(
            'Ask for confirmation before leaving an '
            'unsaved classification result.',
            style: TextStyle(
              color:
                  AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPreferencesSection(
    BuildContext context,
  ) {
    return _SettingsSection(
      title: 'Preferences',
      children: [
        const ListTile(
          leading: Icon(
            Icons.storage_outlined,
            color: AppColors.primary,
          ),
          title: Text(
            'Settings Storage',
            style: TextStyle(
              color:
                  AppColors.textPrimary,
              fontWeight:
                  FontWeight.w600,
            ),
          ),
          subtitle: Text(
            'These preferences currently apply during '
            'the active app session.',
            style: TextStyle(
              color:
                  AppColors.textSecondary,
            ),
          ),
        ),

        const Divider(),

        ListTile(
          leading: const Icon(
            Icons.restart_alt_rounded,
            color: AppColors.warning,
          ),
          title: const Text(
            'Reset Settings',
            style: TextStyle(
              color:
                  AppColors.textPrimary,
              fontWeight:
                  FontWeight.w600,
            ),
          ),
          subtitle: const Text(
            'Restore all display and classification '
            'preferences to their default values.',
            style: TextStyle(
              color:
                  AppColors.textSecondary,
            ),
          ),
          trailing: OutlinedButton(
            onPressed: () {
              _confirmResetSettings(
                context,
              );
            },
            style:
                OutlinedButton.styleFrom(
              foregroundColor:
                  AppColors.warning,
              side: const BorderSide(
                color:
                    AppColors.warning,
              ),
            ),
            child:
                const Text('RESET'),
          ),
        ),
      ],
    );
  }

  Future<void> _confirmResetSettings(
    BuildContext context,
  ) async {
    final settingsProvider =
        context.read<SettingsProvider>();

    final shouldReset =
        await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor:
              AppColors.surface,
          title: const Text(
            'Reset Settings',
            style: TextStyle(
              color:
                  AppColors.textPrimary,
            ),
          ),
          content: const Text(
            'Restore all settings to their default values?',
            style: TextStyle(
              color:
                  AppColors.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(false);
              },
              child:
                  const Text('CANCEL'),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(true);
              },
              child:
                  const Text('RESET'),
            ),
          ],
        );
      },
    );

    if (shouldReset != true) {
      return;
    }

    settingsProvider.resetToDefaults();

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content: Text(
          'Settings restored to default values.',
        ),
        duration:
            Duration(seconds: 2),
      ),
    );
  }

  Widget _buildAboutSection() {
    return _SettingsSection(
      title: 'About',
      children: [
        const ListTile(
          leading: Icon(
            Icons.eco_outlined,
            color: AppColors.primary,
          ),
          title: Text(
            'gUSo',
            style: TextStyle(
              color:
                  AppColors.textPrimary,
              fontWeight:
                  FontWeight.w600,
            ),
          ),
          subtitle: Text(
            'Seaweed-Guso Quality Classification '
            'Using Image Processing',
            style: TextStyle(
              color:
                  AppColors.textSecondary,
            ),
          ),
        ),

        const Divider(),

        ListTile(
          leading: const Icon(
            Icons.info_outline,
            color: AppColors.primary,
          ),
          title: const Text(
            'Frontend Status',
            style: TextStyle(
              color:
                  AppColors.textPrimary,
              fontWeight:
                  FontWeight.w600,
            ),
          ),
          subtitle: const Text(
            'Flutter Web frontend',
            style: TextStyle(
              color:
                  AppColors.textSecondary,
            ),
          ),
          trailing: Container(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 5,
            ),
            decoration: BoxDecoration(
              color:
                  AppColors.primaryDark,
              borderRadius:
                  BorderRadius.circular(
                20,
              ),
            ),
            child: const Text(
              'ACTIVE',
              style: TextStyle(
                color:
                    AppColors.primary,
                fontSize: 11,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SettingsSection
    extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(
          AppRadius.large,
        ),
        border: Border.all(
          color: AppColors.disabled,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                const EdgeInsets.fromLTRB(
              22,
              20,
              22,
              12,
            ),
            child: Text(
              title,
              style: const TextStyle(
                color:
                    AppColors.textPrimary,
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),

          ...children,
        ],
      ),
    );
  }
}