import 'package:flutter/material.dart';
import '../services/preferences_service.dart'; // 1. Import the service

class ThemeProvider with ChangeNotifier {
  final PreferencesService _prefsService = PreferencesService();
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  ThemeProvider() {
    _loadTheme(); // 2. Load the theme when the provider is created
  }

  // Load theme from shared_preferences
  void _loadTheme() async {
    final isDark = await _prefsService.getThemePreference();
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  // Toggle and save the theme
  void toggleTheme() {
    _themeMode = isDarkMode ? ThemeMode.light : ThemeMode.dark;
    _prefsService.saveThemePreference(isDarkMode); // 3. Save the new preference
    notifyListeners();
  }
}