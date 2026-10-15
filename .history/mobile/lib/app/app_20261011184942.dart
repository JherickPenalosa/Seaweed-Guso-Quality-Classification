import 'package:flutter/material.dart';

import 'theme.dart';

class GusoMobileApp extends StatelessWidget {
  const GusoMobileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'gUSo Mobile',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const _MobilePlaceholderScreen(),
    );
  }
}

class _MobilePlaceholderScreen extends StatelessWidget {
  const _MobilePlaceholderScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Center(
          child: Text(
            'gUSo Mobile',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}