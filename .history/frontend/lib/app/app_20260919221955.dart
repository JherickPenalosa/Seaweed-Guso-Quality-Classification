import 'package:flutter/material.dart';

import '../screens/home/home_screen.dart';
import 'theme.dart';

import 'package:provider/provider.dart';
import '../providers/classification_provider.dart';

class GusoApp extends StatelessWidget {
  const GusoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'gUSo',
      debugShowCheckedModeBanner: false,

      theme: AppTheme.darkTheme,

      home: const HomeScreen(),
    );
  }
}