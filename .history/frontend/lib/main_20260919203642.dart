import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const GusoApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Seaweed Guso Quality Classification',
      theme: ThemeData(primarySwatch: Colors.teal),
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

  @override
  void initState() {
    super.initState();
    _checkBackendStatus();
  }

  Future<void> _checkBackendStatus() async {
    try {
      final response = await http.get(Uri.parse('http://127.0.0.1:8080/api/status'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _serverStatus = "Status: ${data['status']}\nProject: ${data['project']}";
        });
      }
    } catch (e) {
      setState(() {
        _serverStatus = "Failed to connect to backend: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seaweed Guso Quality Classification'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.water, size: 64, color: Colors.teal),
              const SizedBox(height: 20),
              Text(
                _serverStatus,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _checkBackendStatus,
                child: const Text('Refresh Backend Connection'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}