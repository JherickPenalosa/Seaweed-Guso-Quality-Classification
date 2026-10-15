import 'package:flutter/material.dart';
import '../../app/theme.dart';
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

  void _onDestinationSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
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
            icon: Icon(Icons.image_search_outlined),
            selectedIcon: Icon(Icons.image_search),
            label: 'Classify',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Guide',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}