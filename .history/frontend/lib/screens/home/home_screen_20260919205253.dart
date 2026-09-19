import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
  return MainLayout(
    child: Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.water,
              size: 64,
              color: AppColors.primary,
            ),
            const SizedBox(height: 20),

            Text(
              _serverStatus,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: _checkBackendStatus,
              child: const Text(
                'Refresh Backend Connection',
              ),
            ),
          ],
        ),
      ),
    ),
  );
}