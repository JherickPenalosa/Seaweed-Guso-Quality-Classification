import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const SeaweedApp());
}

class SeaweedApp extends StatelessWidget {
  const SeaweedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Seaweed Guso Quality Classification',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.teal,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _serverStatus = "Connecting to backend...";
  String _projectName = "";
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchBackendStatus();
  }

  Future<void> _fetchBackendStatus() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      // Connect to the /api/status endpoint created in server.dart
      final response = await http.get(Uri.parse('http://localhost:8080/api/status'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _serverStatus = data['status'] ?? 'Unknown';
          _projectName = data['project'] ?? '';
          _isLoading = false;
        });
      } else {
        setState(() {
          _serverStatus = 'Server error: ${response.statusCode}';
          _isLoading = false;
          _hasError = true;
        });
      }
    } catch (e) {
      setState(() {
        _serverStatus = 'Failed to connect to backend.\nEnsure server.dart is running on port 8080.';
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seaweed Guso Quality Classification'),
        centerTitle: true,
        backgroundColor: Colors.teal.shade700,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(24.0),
          child: Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _hasError
                        ? Icons.error_outline
                        : Icons.check_circle_outline,
                    size: 64,
                    color: _hasError ? Colors.red : Colors.teal,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Backend Connection',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  if (_isLoading)
                    const CircularProgressIndicator()
                  else ...[
                    Text(
                      'Status: $_serverStatus',
                      style: TextStyle(
                        fontSize: 16,
                        color: _hasError ? Colors.red : Colors.green.shade800,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (_projectName.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Project: $_projectName',
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _fetchBackendStatus,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Test Connection'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}