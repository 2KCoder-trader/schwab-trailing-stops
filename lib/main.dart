import 'package:flutter/material.dart';
import 'screens/auth_gate.dart';

void main() {
  runApp(const TrailStopApp());
}

class TrailStopApp extends StatelessWidget {
  const TrailStopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Trail Stop',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0A1929),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0A1929),
          elevation: 0,
        ),
        cardColor: const Color(0xFF132F4C),
      ),
      home: const AuthGate(),
    );
  }
}
