import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_shell.dart';
import 'presentation/criterivox_theme.dart';
import 'presentation/language_mode.dart';

class CriterivoxApp extends StatefulWidget {
  const CriterivoxApp({super.key});
  @override
  State<CriterivoxApp> createState() => _CriterivoxAppState();
}

class _CriterivoxAppState extends State<CriterivoxApp> {
  static const _themeKey = 'criterivox.theme.dark';
  static const _languageKey = 'criterivox.language';
  final SharedPreferencesAsync _preferences = SharedPreferencesAsync();
  ThemeMode _themeMode = ThemeMode.dark;
  CriterivoxLanguage _language = CriterivoxLanguage.english;

  @override
  void initState() {
    super.initState();
    _restorePreferences();
  }

  Future<void> _restorePreferences() async {
    final dark = await _preferences.getBool(_themeKey);
    final language = await _preferences.getString(_languageKey);
    if (!mounted) return;
    setState(() {
      if (dark != null) _themeMode = dark ? ThemeMode.dark : ThemeMode.light;
      _language = CriterivoxLanguage.fromCode(language);
    });
  }

  Future<void> _toggleTheme() async {
    final dark = _themeMode != ThemeMode.dark;
    setState(() => _themeMode = dark ? ThemeMode.dark : ThemeMode.light);
    await _preferences.setBool(_themeKey, dark);
  }

  Future<void> _setLanguage(CriterivoxLanguage language) async {
    setState(() => _language = language);
    await _preferences.setString(_languageKey, language.code);
  }

  ThemeData _theme(Brightness brightness, CriterivoxTheme tokens) {
    final scheme = ColorScheme.fromSeed(
        seedColor: tokens.primary,
        brightness: brightness,
        surface: tokens.surface);
    return ThemeData(
      brightness: brightness,
      useMaterial3: true,
      scaffoldBackgroundColor: tokens.page,
      canvasColor: tokens.page,
      cardColor: tokens.surface,
      dividerColor: tokens.border,
      colorScheme: scheme,
      iconTheme: IconThemeData(color: tokens.text),
      appBarTheme: AppBarTheme(
          backgroundColor: tokens.page,
          foregroundColor: tokens.text,
          surfaceTintColor: Colors.transparent),
      navigationRailTheme: NavigationRailThemeData(
          backgroundColor: tokens.surface,
          indicatorColor: tokens.primary.withValues(alpha: .14),
          selectedIconTheme: IconThemeData(color: tokens.primary),
          selectedLabelTextStyle: TextStyle(color: tokens.text),
          unselectedIconTheme: IconThemeData(color: tokens.mutedText),
          unselectedLabelTextStyle: TextStyle(color: tokens.mutedText)),
      textTheme: ThemeData(brightness: brightness)
          .textTheme
          .apply(bodyColor: tokens.text, displayColor: tokens.text),
      extensions: <ThemeExtension<dynamic>>[tokens],
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: tokens.surfaceStrong,
        hintStyle: TextStyle(color: tokens.mutedText),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: tokens.border)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: tokens.border)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: tokens.primary, width: 1.4)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Criterivox',
        debugShowCheckedModeBanner: false,
        themeMode: _themeMode,
        theme: _theme(Brightness.light, CriterivoxTheme.light),
        darkTheme: _theme(Brightness.dark, CriterivoxTheme.dark),
        home: CriterivoxLanguageScope(
          language: _language,
          onChanged: _setLanguage,
          child: CriterivoxShell(
              isDarkMode: _themeMode == ThemeMode.dark,
              onToggleTheme: _toggleTheme),
        ),
      );
}

void main() => runApp(const CriterivoxApp());
