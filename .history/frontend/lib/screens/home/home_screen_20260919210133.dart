import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../app/theme.dart';
import '../../widgets/layout/main_layout.dart';

import '../classification/classification_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _serverStatus = 'Connecting to backend...';

  @override
  void initState() {
    super.initState();
    _checkBackendStatus();
  }

  Future<void> _checkBackendStatus() async {
    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8080/api/status'),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          _serverStatus =
              'Status: ${data['status']}\n'
              'Project: ${data['project']}';
        });
      } else {
        setState(() {
          _serverStatus =
              'Backend returned status code ${response.statusCode}.';
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _serverStatus = 'Failed to connect to backend:\n$e';
      });
    }
  }

  @override
Widget build(BuildContext context) {
  return const MainLayout(
    child: ClassificationScreen(),
  );
}
}