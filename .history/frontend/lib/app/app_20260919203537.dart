import 'package:flutter/material.dart';

import 'theme.dart';

class GusoApp extends StatelessWidget {
  const GusoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'gUSo',

      debugShowCheckedModeBanner: false,

      theme: AppTheme.darkTheme,

      home: const Scaffold(
        body: Center(
          child: Text(
            'gUSo',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}