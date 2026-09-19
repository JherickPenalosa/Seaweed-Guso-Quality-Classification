import 'package:flutter/material.dart';

import '../../app/theme.dart';
import 'app_sidebar.dart';

class MainLayout extends StatefulWidget {
  final Widget child;

  const MainLayout({
    super.key,
    required this.child,
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

    // Navigation will be connected later.
    // For now, this only updates the selected sidebar item.
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
                child: widget.child,
              ),
            ),
          ),
        ],
      ),
    );
  }
}