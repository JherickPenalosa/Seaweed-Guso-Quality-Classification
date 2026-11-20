import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'theme.dart';

import '../providers/classification_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/seaweed_language_provider.dart';
import '../providers/connectivity_provider.dart';

import '../screens/home/home_screen.dart';

import '../screens/landing/landing_screen.dart';
import '../services/auth_service.dart';

class GusoApp extends StatelessWidget {
  const GusoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ClassificationProvider()),

        ChangeNotifierProvider(create: (_) => SettingsProvider()),

        ChangeNotifierProvider(create: (_) => SeaweedLanguageProvider()),

        ChangeNotifierProvider(create: (_) => ConnectivityProvider()),
      ],
      child: MaterialApp(
        title: 'gUSo',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const _SessionGate(),
      ),
    );
  }
}


/// Direct users to the landing page unless a restored JWT is accepted by
/// FastAPI. The token's presence alone is never sufficient.
class _SessionGate extends StatefulWidget {
  const _SessionGate();

  @override
  State<_SessionGate> createState() => _SessionGateState();
}

class _SessionGateState extends State<_SessionGate> {
  late final Future<bool> _sessionCheck = _restoreAndValidate();

  Future<bool> _restoreAndValidate() async {
    try {
      final hasStoredSession = await AuthService.restoreSession();
      if (!hasStoredSession) return false;
      return await const AuthService().validateSession();
    } catch (error) {
      // Fail closed when the server is unavailable. AuthService keeps the
      // token on transient errors, so it can be checked on a later refresh.
      debugPrint('Unable to validate saved login session: $error');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _sessionCheck,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return snapshot.data == true
            ? const HomeScreen()
            : const LandingScreen();
      },
    );
  }
}
