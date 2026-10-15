import 'package:flutter/material.dart';
import '../widgets/layout/main_layout.dart';
import 'theme.dart';

class GusoMobileApp extends StatelessWidget {
  const GusoMobileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'gUSo Mobile',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const MainLayout(),
    );
  }
}