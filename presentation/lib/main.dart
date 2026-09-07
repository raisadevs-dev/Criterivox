import 'package:flutter/material.dart';
import 'app_shell.dart';

class CriterivoxApp extends StatefulWidget {
  const CriterivoxApp({super.key});

  @override
  State<CriterivoxApp> createState() => _CriterivoxAppState();
}

class _CriterivoxAppState extends State<CriterivoxApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.dark
          ? ThemeMode.light
          : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Criterivox',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        colorSchemeSeed: const Color(0xFF6F5AEF),
        scaffoldBackgroundColor: const Color(0xFFF5F6FA),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorSchemeSeed: const Color(0xFF8D78FF),
        scaffoldBackgroundColor: const Color(0xFF050712),
        useMaterial3: true,
      ),
      home: CriterivoxShell(
        isDarkMode: _themeMode == ThemeMode.dark,
        onToggleTheme: _toggleTheme,
      ),
    );
  }
}

void main() => runApp(const CriterivoxApp());
