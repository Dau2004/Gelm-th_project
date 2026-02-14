import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'services/database_service.dart';
import 'services/zscore_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseService.instance.database;
  await ZScoreService.loadLMSData();
  runApp(const GelmathApp());
}

class GelmathApp extends StatelessWidget {
  const GelmathApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gelmath - Protect the Child',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF2D5F3F),
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2D5F3F),
          primary: const Color(0xFF2D5F3F),
          secondary: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2D5F3F),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2D5F3F),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF2D5F3F), width: 2),
          ),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}
