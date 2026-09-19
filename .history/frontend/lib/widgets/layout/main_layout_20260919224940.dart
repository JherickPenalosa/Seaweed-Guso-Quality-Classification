import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../screens/classification/classification_screen.dart';
import '../../screens/history/history_screen.dart';
import 'app_sidebar.dart';

import '../../screens/settings/settings_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({
    super.key,
  });

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  void _handleMenuSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildCurrentPage() {
    switch (_selectedIndex) {
      case 1:
        return const HistoryScreen();

      case 2:
        return const SettingsScreen();

      case 0:
      default:
        return const ClassificationScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          AppSidebar(
            selectedIndex: _selectedIndex,
            onMenuSelected: _handleMenuSelected,
          ),

          Expanded(
            child: Container(
              color: AppColors.background,
              child: SafeArea(
                child: _buildCurrentPage(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Settings will be added later.',
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 18,
        ),
      ),
    );
  }
}