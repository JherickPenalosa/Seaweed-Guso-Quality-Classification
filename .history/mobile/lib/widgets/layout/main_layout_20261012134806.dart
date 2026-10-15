import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme.dart';
import '../../providers/classification_provider.dart';
import '../../providers/settings_provider.dart';
import '../../screens/classification/classification_screen.dart';
import '../../screens/history/history_screen.dart';
import '../../screens/seaweed_guide/seaweed_guide_screen.dart';
import '../../screens/settings/settings_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    ClassificationScreen(),
    SeaweedGuideScreen(),
    HistoryScreen(),
    SettingsScreen(),
  ];

  Future<void> _onDestinationSelected(int index) async {
    if (index == _selectedIndex) {
      return;
    }

    final classificationProvider =
        context.read<ClassificationProvider>();

    final settingsProvider =
        context.read<SettingsProvider>();

    final isLeavingClassify =
        _selectedIndex == 0 && index != 0;

    final shouldConfirm =
        isLeavingClassify &&
        classificationProvider.hasUnsavedResult &&
        settingsProvider.confirmBeforeDiscard;

    if (shouldConfirm) {
      final discard = await _showDiscardConfirmation();

      if (!mounted || discard != true) {
        return;
      }

      classificationProvider.setUnsavedResult(false);
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  Future<bool?> _showDiscardConfirmation() {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text(
            'Discard result?',
            style: TextStyle(
              color: AppColors.textPrimary,
            ),
          ),
          content: const Text(
            'You have an unsaved classification result. '
            'If you leave this screen, the result will not be saved to history.',
            style: TextStyle(
              color: AppColors.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text(
                'Stay',
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text(
                'Discard',
                style: TextStyle(
                  color: AppColors.error,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onDestinationSelected,
        backgroundColor: AppColors.surfaceDark,
        indicatorColor: AppColors.primaryDark,
        destinations: const [
          NavigationDestination(
            icon: Icon(
              Icons.image_search_outlined,
            ),
            selectedIcon: Icon(
              Icons.image_search,
            ),
            label: 'Classify',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.menu_book_outlined,
            ),
            selectedIcon: Icon(
              Icons.menu_book,
            ),
            label: 'Guide',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.history_outlined,
            ),
            selectedIcon: Icon(
              Icons.history,
            ),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.settings_outlined,
            ),
            selectedIcon: Icon(
              Icons.settings,
            ),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}