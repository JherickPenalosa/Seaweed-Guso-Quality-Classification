import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'theme.dart';

import '../providers/classification_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/seaweed_language_provider.dart';
import '../providers/connectivity_provider.dart';

import '../screens/home/home_screen.dart';
import '../screens/landin'

class GusoApp extends StatelessWidget {
  const GusoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ClassificationProvider(),
        ),

        ChangeNotifierProvider(
          create: (_) => SettingsProvider(),
        ),

        ChangeNotifierProvider(
          create: (_) => SeaweedLanguageProvider(),
        ),

        ChangeNotifierProvider(
          create: (_) => ConnectivityProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'gUSo',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const HomeScreen(),
      ),
    );
  }
}