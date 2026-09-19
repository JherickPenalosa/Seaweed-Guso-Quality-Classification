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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),

          const SizedBox(height: 24),

          _buildDisplaySettings(),

          const SizedBox(height: 24),

          _buildClassificationSettings(),

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
        children: [
          Icon(
            Icons.settings_outlined,
            color: AppColors.primary,
            size: 30,
          ),

          SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Settings',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 6),

                Text(
                  'Manage how classification information is displayed.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisplaySettings() {
    return _SettingsSection(
      title: 'Result Display',
      children: [
        SwitchListTile(
          value: _showConfidence,
          onChanged: (value) {
            setState(() {
              _showConfidence = value;
            });
          },
          activeColor: AppColors.primary,
          title: const Text(
            'Show Confidence',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: const Text(
            'Display the model confidence percentage in classification results.',
            style: TextStyle(
              color: AppColors.textSecondary,
            ),
          ),
        ),

        const Divider(),

        SwitchListTile(
          value: _showImageQuality,
          onChanged: (value) {
            setState(() {
              _showImageQuality = value;
            });
          },
          activeThumbColor: AppColors.primary,
          title: const Text(
            'Show Image Quality',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: const Text(
            'Display whether the uploaded image is clear or may affect classification quality.',
            style: TextStyle(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildClassificationSettings() {
    return _SettingsSection(
      title: 'Classification',
      children: [
        SwitchListTile(
          value: _confirmBeforeDiscard,
          onChanged: (value) {
            setState(() {
              _confirmBeforeDiscard = value;
            });
          },
          activeThumbColor: AppColors.primary,
          title: const Text(
            'Confirm Before Discarding Results',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: const Text(
            'Ask for confirmation before leaving an unsaved classification result.',
            style: TextStyle(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
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
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            'Seaweed-Guso Quality Classification Using Image Processing',
            style: TextStyle(
              color: AppColors.textSecondary,
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
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: const Text(
            'Flutter Web frontend',
            style: TextStyle(
              color: AppColors.textSecondary,
            ),
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 5,
            ),
            decoration: BoxDecoration(
              color: AppColors.primaryDark,
              borderRadius: BorderRadius.circular(
                20,
              ),
            ),
            child: const Text(
              'ACTIVE',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SettingsSection extends StatelessWidget {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              22,
              20,
              22,
              12,
            ),
            child: Text(
              title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          ...children,
        ],
      ),
    );
  }
}