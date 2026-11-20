import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../../app/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/classification_provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/mobile_auth_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

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

              _buildSectionHeader(
                context,
                icon: Icons.visibility_outlined,
                title: 'Result Display',
                description:
                    'Choose what appears in your classification results.',
              ),

              const SizedBox(height: AppSpacing.md),

              _buildSettingsCard(
                children: [
                  _buildSwitchTile(
                    context,
                    icon: Icons.analytics_outlined,
                    title: 'Show Confidence',
                    subtitle: 'Display the AI confidence score.',
                    value: settings.showConfidence,
                    onChanged: settings.setShowConfidence,
                  ),

                  const Divider(color: AppColors.borderLight, height: 1),

                  _buildSwitchTile(
                    context,
                    icon: Icons.image_outlined,
                    title: 'Show Image Quality',
                    subtitle:
                        'Display image-quality information when available.',
                    value: settings.showImageQuality,
                    onChanged: settings.setShowImageQuality,
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.xl),

              _buildSectionHeader(
                context,
                icon: Icons.tune_outlined,
                title: 'Classification Behavior',
                description: 'Manage unfinished classification results.',
              ),

              const SizedBox(height: AppSpacing.md),

              _buildSettingsCard(
                children: [
                  _buildSwitchTile(
                    context,
                    icon: Icons.warning_amber_outlined,
                    title: 'Confirm Before Discard',
                    subtitle: 'Ask before leaving an unsaved classification.',
                    value: settings.confirmBeforeDiscard,
                    onChanged: settings.setConfirmBeforeDiscard,
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.xl),

              _buildSectionHeader(
                context,
                icon: Icons.manage_accounts_outlined,
                title: 'Account',
                description: 'Manage your account and sign-in session.',
              ),

              const SizedBox(height: AppSpacing.md),

              _buildSettingsCard(
                children: [
                  _buildAccountTile(
                    context,
                    icon: Icons.logout_outlined,
                    title: 'Logout',
                    subtitle: 'Sign out of your gUSo account.',
                    onTap: () => _showLogoutDialog(context),
                    isDanger: false,
                  ),

                  const Divider(color: AppColors.borderLight, height: 1),

                  _buildAccountTile(
                    context,
                    icon: Icons.delete_forever_outlined,
                    title: 'Delete Account',
                    subtitle: 'Permanently delete your account and saved data.',
                    onTap: () => _showDeleteAccountDialog(context),
                    isDanger: true,
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.xl),
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
            border: Border.all(color: AppColors.primary),
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
                'Manage your preferences and account.',
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primary, size: 21),

        const SizedBox(width: AppSpacing.sm),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: AppColors.textSecondary, height: 1.4),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsCard({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSwitchTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              borderRadius: BorderRadius.circular(AppRadius.medium),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Icon(icon, color: AppColors.primary, size: 21),
          ),

          const SizedBox(width: AppSpacing.md),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(color: AppColors.textSecondary, height: 1.4),
                ),
              ],
            ),
          ),

          const SizedBox(width: AppSpacing.sm),

          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }

  Widget _buildAccountTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isDanger,
  }) {
    final color = isDanger ? AppColors.error : AppColors.textPrimary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.large),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Icon(icon, color: color, size: 22),
              ),

              const SizedBox(width: AppSpacing.md),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall
                          ?.copyWith(color: color, fontWeight: FontWeight.w600),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: AppSpacing.sm),

              Icon(
                Icons.chevron_right_rounded,
                color: isDanger ? AppColors.error : AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text(
            'Logout?',
            style: TextStyle(color: AppColors.textPrimary),
          ),
          content: const Text(
            'You will return to the Login screen.',
            style: TextStyle(color: AppColors.textSecondary),
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
                'Logout',
                style: TextStyle(color: AppColors.error),
              ),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true || !context.mounted) {
      return;
    }

    context.read<AuthProvider>().logout();
  }

  Future<void> _showDeleteAccountDialog(BuildContext context) async {
    final passwordController = TextEditingController();

    bool isDeleting = false;
    bool hidePassword = true;
    String? errorMessage;

    try {
      final deleted = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (dialogContext, setDialogState) {
              Future<void> submitDeletion() async {
                if (isDeleting) return;

                final password = passwordController.text;

                if (password.isEmpty) {
                  setDialogState(() {
                    errorMessage = 'Enter your current password.';
                  });
                  return;
                }

                final token = MobileAuthService.accessToken;

                if (token == null || token.isEmpty) {
                  setDialogState(() {
                    errorMessage =
                        'Your session has expired. '
                        'Please log in again.';
                  });
                  return;
                }

                setDialogState(() {
                  isDeleting = true;
                  errorMessage = null;
                });

                bool deletionConfirmed = false;

                try {
                  final response = await http
                      .delete(
                        Uri.parse('${MobileAuthService.baseUrl}/auth/account'),
                        headers: {
                          'Authorization': 'Bearer $token',
                          'Content-Type': 'application/json',
                          'Accept': 'application/json',
                        },
                        body: jsonEncode({'password': password}),
                      )
                      .timeout(const Duration(seconds: 30));

                  if (!dialogContext.mounted) return;

                  bool succeeded = response.statusCode == 204;

                  Map<String, dynamic>? body;

                  if (response.body.isNotEmpty) {
                    try {
                      final decoded = jsonDecode(response.body);
                      if (decoded is Map) {
                        body = Map<String, dynamic>.from(decoded);
                      }
                    } catch (_) {
                      // An invalid response is not success.
                    }
                  }

                  if (response.statusCode == 200 && body?['deleted'] == true) {
                    succeeded = true;
                  }

                  if (succeeded) {
                    deletionConfirmed = true;
                    Navigator.of(dialogContext).pop(true);
                    return;
                  }

                  String message = 'Unable to delete your account.';

                  if (response.statusCode == 404 ||
                      response.statusCode == 405) {
                    message =
                        'Account deletion is not available '
                        'on this backend yet.';
                  } else if (response.statusCode == 401) {
                    message =
                        'Your session has expired or '
                        'your credentials were rejected.';
                  } else if (body?['detail'] is String) {
                    message = body!['detail'] as String;
                  }

                  setDialogState(() {
                    errorMessage = message;
                  });
                } on TimeoutException {
                  if (!dialogContext.mounted) return;

                  setDialogState(() {
                    errorMessage =
                        'The request timed out. Check '
                        'your connection before retrying.';
                  });
                } catch (_) {
                  if (!dialogContext.mounted) return;

                  setDialogState(() {
                    errorMessage =
                        'Could not reach FastAPI. '
                        'Your account has not been confirmed '
                        'as deleted.';
                  });
                } finally {
                  if (!deletionConfirmed && dialogContext.mounted) {
                    setDialogState(() {
                      isDeleting = false;
                    });
                  }
                }
              }

              return AlertDialog(
                backgroundColor: AppColors.surface,
                title: const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: AppColors.error),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Delete Account?',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'This action permanently deletes '
                        'your gUSo account and its saved '
                        'classification records and images. '
                        'It cannot be undone.',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 20),

                      const Text(
                        'Confirm your password',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 8),

                      TextField(
                        controller: passwordController,
                        enabled: !isDeleting,
                        obscureText: hidePassword,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) {
                          submitDeletion();
                        },
                        style: const TextStyle(color: AppColors.textPrimary),
                        decoration: InputDecoration(
                          hintText: 'Current password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            tooltip: hidePassword
                                ? 'Show password'
                                : 'Hide password',
                            onPressed: isDeleting
                                ? null
                                : () {
                                    setDialogState(() {
                                      hidePassword = !hidePassword;
                                    });
                                  },
                            icon: Icon(
                              hidePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                          ),
                        ),
                      ),

                      if (errorMessage != null) ...[
                        const SizedBox(height: 14),

                        Text(
                          errorMessage!,
                          style: const TextStyle(
                            color: AppColors.error,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: isDeleting
                        ? null
                        : () {
                            Navigator.of(dialogContext).pop(false);
                          },
                    child: const Text('Cancel'),
                  ),

                  TextButton(
                    onPressed: isDeleting ? null : submitDeletion,
                    child: isDeleting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(
                            'Delete Account',
                            style: TextStyle(
                              color: AppColors.error,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ],
              );
            },
          );
        },
      );

      if (deleted != true || !context.mounted) {
        return;
      }

      // Run only after the backend confirms deletion.
      context.read<ClassificationProvider>().clearHistory();
      context.read<AuthProvider>().logout();
    } finally {
      passwordController.dispose();
    }
  }
}
