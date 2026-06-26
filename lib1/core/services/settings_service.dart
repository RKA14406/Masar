import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService extends ChangeNotifier {
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal() {
    _loadSettings();
  }

  static const String _themeKey = 'theme_mode';
  static const String _languageKey = 'language_code';

  ThemeMode _themeMode = ThemeMode.dark;
  Locale _locale = const Locale('ar');

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    final themeIndex = prefs.getInt(_themeKey);
    if (themeIndex != null) {
      _themeMode = ThemeMode.values[themeIndex];
    }

    final langCode = prefs.getString(_languageKey);
    if (langCode != null) {
      _locale = Locale(langCode);
    }
    
    notifyListeners();
  }

  Future<void> updateThemeMode(ThemeMode? newThemeMode) async {
    if (newThemeMode == null || newThemeMode == _themeMode) return;

    _themeMode = newThemeMode;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, newThemeMode.index);
  }

  Future<void> updateLocale(Locale newLocale) async {
    if (newLocale == _locale) return;

    _locale = newLocale;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, newLocale.languageCode);
  }
}
