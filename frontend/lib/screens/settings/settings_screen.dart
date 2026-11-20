import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../../app/theme.dart';
import '../../providers/classification_provider.dart';
import '../../providers/settings_provider.dart';
import '../../screens/landing/landing_screen.dart';
import '../../services/auth_service.dart';

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
          _buildDisplaySettings(context, settings),
          const SizedBox(height: 24),
          _buildClassificationSettings(context, settings),
          const SizedBox(height: 24),
          _buildAccountSettings(context),
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
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(color: AppColors.borderPrimary, width: 1.5),
      ),
      child: const Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(Icons.settings_outlined, color: AppColors.primary, size: 30),
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
                SizedBox(height: 6),
                Text(
                  'Manage your account and how classification information is displayed.',
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
            context.read<SettingsProvider>().setShowConfidence(value);
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
            'Display the model confidence percentage in classification results.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
        const Divider(),
        SwitchListTile(
          value:
              settings.showImageQuality,
          onChanged: (value) {
            context.read<SettingsProvider>().setShowImageQuality(value);
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
            'Display whether the uploaded image is clear or may affect classification quality.',
            style: TextStyle(color: AppColors.textSecondary),
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
            context.read<SettingsProvider>().setConfirmBeforeDiscard(value);
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
            'Ask for confirmation before leaving an unsaved classification result.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }

  Widget _buildAccountSettings(BuildContext context) {
    return _SettingsSection(
      title: 'Account',
      children: [
        ListTile(
          leading: const Icon(Icons.logout_rounded, color: AppColors.primary),
          title: const Text(
            'Log Out',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: const Text(
            'Sign out of this browser and return to the login page.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          trailing: const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textSecondary,
          ),
          onTap: () => _confirmLogout(context),
        ),
        const Divider(color: AppColors.disabled),
        const _DeleteAccountTile(),
      ],
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Log out of gUSo?',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          'You will return to the login page. Saved classification records '
          'will remain in your account.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Log Out'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.black,
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    // Preserve PostgreSQL records while removing all browser session data.
    try {
      await const AuthService().logout();
      if (!context.mounted) return;
      context.read<ClassificationProvider>().clearHistory();

      // Remove the authenticated page from the back stack: the Back button
      // must not reopen the dashboard after logging out.
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => const LandingScreen()),
        (route) => false,
      );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not complete logout. Please try again.'),
        ),
      );
    }
  }

  Widget _buildAboutSection() {
    return _SettingsSection(
      title: 'About',
      children: [
        const ListTile(
          leading: Icon(Icons.eco_outlined, color: AppColors.primary),
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
            'Seaweed-Guso Quality Classification Using Image Processing',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.info_outline, color: AppColors.primary),
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
            style: TextStyle(color: AppColors.textSecondary),
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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

/// Permanently deletes the authenticated account only after the server
/// validates the session, password, and explicit DELETE confirmation.
/// No account or saved history is removed locally unless FastAPI confirms.
class _DeleteAccountTile extends StatefulWidget {
  const _DeleteAccountTile();

  @override
  State<_DeleteAccountTile> createState() => _DeleteAccountTileState();
}

class _DeleteAccountTileState extends State<_DeleteAccountTile> {
  static const String _apiBaseUrl = String.fromEnvironment(
    'GUSO_API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000',
  );

  bool _isDeleting = false;

  Future<void> _onDeletePressed() async {
    if (_isDeleting) return;

    final password = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _DeleteAccountConfirmationDialog(),
    );

    if (!mounted || password == null) return;
    setState(() => _isDeleting = true);

    bool serverConfirmedDeletion = false;
    try {
      final response = await http
          .delete(
            Uri.parse('$_apiBaseUrl/auth/me'),
            headers: {
              ...AuthService.authorizationHeaders,
              'Content-Type': 'application/json',
            },
            body: jsonEncode({'password': password, 'confirmation': 'DELETE'}),
          )
          .timeout(const Duration(seconds: 30));

      dynamic responseData;
      try {
        responseData = jsonDecode(response.body);
      } on FormatException {
        throw Exception(
          'Unexpected server response (HTTP ${response.statusCode}).',
        );
      }

      if (response.statusCode != 200) {
        var message = 'Account deletion failed (HTTP ${response.statusCode}).';
        if (responseData is Map && responseData['detail'] is String) {
          message = responseData['detail'] as String;
        }
        throw Exception(message);
      }

      if (responseData is! Map || responseData['deleted'] != true) {
        throw Exception('The server did not confirm account deletion.');
      }

      serverConfirmedDeletion = true;

      // The backend transaction has completed. Now clear all local state.
      await AuthService.clearSession();
      if (!mounted) return;
      context.read<ClassificationProvider>().clearHistory();

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => const LandingScreen()),
        (route) => false,
      );
    } on TimeoutException {
      _notify(
        'The request timed out. Check whether the account still exists '
        'before trying to delete it again.',
      );
    } on http.ClientException {
      _notify('Cannot reach the gUSo backend. Check your connection.');
    } catch (error) {
      if (serverConfirmedDeletion) {
        _notify(
          'Your account was deleted on the server, but browser sign-out '
          "did not finish. Clear this site's stored data before reuse.",
        );
      } else {
        _notify(error.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  void _notify(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      enabled: !_isDeleting,
      leading: _isDeleting
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.delete_forever_outlined, color: AppColors.error),
      title: Text(
        _isDeleting ? 'Deleting Account...' : 'Delete Account',
        style: const TextStyle(
          color: AppColors.error,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: const Text(
        'Permanently remove your account, saved classifications, and images.',
        style: TextStyle(color: AppColors.textSecondary),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: AppColors.textSecondary,
      ),
      onTap: _isDeleting ? null : _onDeletePressed,
    );
  }
}

/// A separate stateful dialog owns and disposes its text controllers.
/// Only the password is passed to the caller, and only after the user
/// types DELETE exactly. No credentials are written to browser storage.
class _DeleteAccountConfirmationDialog extends StatefulWidget {
  const _DeleteAccountConfirmationDialog();

  @override
  State<_DeleteAccountConfirmationDialog> createState() =>
      _DeleteAccountConfirmationDialogState();
}

class _DeleteAccountConfirmationDialogState
    extends State<_DeleteAccountConfirmationDialog> {
  final _passwordController = TextEditingController();
  final _confirmationController = TextEditingController();

  bool get _canConfirm =>
      _passwordController.text.isNotEmpty &&
      _confirmationController.text == 'DELETE';

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      title: const Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: AppColors.error),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Delete your gUSo account?',
              style: TextStyle(color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'This action cannot be undone. Your account, all saved '
                'classification results, and stored photos will be '
                'permanently removed from the active database.',
                style: TextStyle(color: AppColors.textSecondary, height: 1.5),
              ),
              const SizedBox(height: 20),
              const Text(
                'Current password',
                style: TextStyle(color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: true,
                enableSuggestions: false,
                autocorrect: false,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  hintText: 'Enter your current password',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Type DELETE to confirm',
                style: TextStyle(color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _confirmationController,
                autocorrect: false,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  hintText: 'DELETE',
                  prefixIcon: Icon(Icons.edit_outlined),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          onPressed: _canConfirm
              ? () => Navigator.of(context).pop(_passwordController.text)
              : null,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
          ),
          icon: const Icon(Icons.delete_forever_outlined),
          label: const Text('Delete Permanently'),
        ),
      ],
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.large),
        side: const BorderSide(color: AppColors.disabled),
      ),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 12),
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
      ),
    );
  }
}
