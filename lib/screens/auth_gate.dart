import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../navigation/main_navigation.dart';
import 'login_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _loading = true;
  bool _authenticated = false;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    // 1. Check if we're returning from Schwab with an auth code
    final code = AuthService.getAuthCodeFromUrl();
    if (code != null) {
      final success = await AuthService.exchangeCodeForTokens(code);
      if (success) {
        setState(() {
          _authenticated = true;
          _loading = false;
        });
        return;
      }
    }

    // 2. Check if we already have a valid refresh token
    if (AuthService.hasValidRefreshToken) {
      setState(() {
        _authenticated = true;
        _loading = false;
      });
      return;
    }

    // 3. No valid token — need to login
    setState(() {
      _authenticated = false;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0A1929),
        body: Center(
          child: CircularProgressIndicator(color: Colors.tealAccent),
        ),
      );
    }

    if (!_authenticated) {
      return const LoginScreen();
    }

    return const MainNavigation();
  }
}
