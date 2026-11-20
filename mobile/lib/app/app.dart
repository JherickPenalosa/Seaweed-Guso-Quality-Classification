import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/classification_provider.dart';
import '../providers/settings_provider.dart';
import '../screens/auth/auth_flow.dart';
import '../providers/auth_provider.dart';
import 'theme.dart';

class GusoMobileApp extends StatelessWidget {
  const GusoMobileApp({super.key});

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
          create: (_) => AuthProvider(),
        )
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'gUSo',
        theme: AppTheme.darkTheme,
        home: const AuthFlow(),
      ),
    );
  }
}