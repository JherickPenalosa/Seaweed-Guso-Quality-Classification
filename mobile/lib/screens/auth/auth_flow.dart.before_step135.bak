import 'package:flutter/material.dart';

import '../../widgets/layout/main_layout.dart';
import 'forgot_password_screen.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import 'welcome_screen.dart';

import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';

enum AuthPage {
  welcome,
  login,
  register,
  forgotPassword,
}

class AuthFlow extends StatefulWidget {
  const AuthFlow({super.key});

  @override
  State<AuthFlow> createState() => _AuthFlowState();
}

class _AuthFlowState extends State<AuthFlow> {
  AuthPage _currentPage = AuthPage.welcome;

  void _goToWelcome() {
    setState(() {
      _currentPage = AuthPage.welcome;
    });
  }

  void _goToLogin() {
    setState(() {
      _currentPage = AuthPage.login;
    });
  }

  void _goToRegister() {
    setState(() {
      _currentPage = AuthPage.register;
    });
  }

  void _goToForgotPassword() {
    setState(() {
      _currentPage = AuthPage.forgotPassword;
    });
  }

  void _loginSuccess() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final authProvider =
      context.watch<AuthProvider>();

    if (authProvider.isAuthenticated) {
      return const MainLayout();
    }

    switch (_currentPage) {
      case AuthPage.welcome:
        return WelcomeScreen(
          onLogin: _goToLogin,
          onRegister: _goToRegister,
        );

      case AuthPage.login:
        return LoginScreen(
          onLoginSuccess: _loginSuccess,
          onRegister: _goToRegister,
          onForgotPassword: _goToForgotPassword,
          onBack: _goToWelcome,
        );

      case AuthPage.register:
        return RegisterScreen(
          onRegistrationSuccess: _goToLogin,
          onBack: _goToLogin,
        );

      case AuthPage.forgotPassword:
        return ForgotPasswordScreen(
          onBackToLogin: _goToLogin,
        );
    }
  }
}