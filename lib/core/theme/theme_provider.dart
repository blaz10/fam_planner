import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages the app's theme and language state
class ThemeProvider with ChangeNotifier {
  bool _isDarkMode;
  String _languageCode;
  
  static const String _themePrefKey = 'isDarkMode';
  static const String _languagePrefKey = 'language';
  static const String _defaultLanguage = 'en';

  ThemeProvider({
    required bool isDarkMode,
    String? languageCode,
  })  : _isDarkMode = isDarkMode,
        _languageCode = languageCode ?? _defaultLanguage {
    _loadPreferences();
  }

  bool get isDarkMode => _isDarkMode;
  String get languageCode => _languageCode;
  Locale get locale => Locale(_languageCode);
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isDarkMode = prefs.getBool(_themePrefKey) ?? false;
      _languageCode = prefs.getString(_languagePrefKey) ?? _defaultLanguage;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading preferences: $e');
    }
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_themePrefKey, _isDarkMode);
    } catch (e) {
      debugPrint('Error saving theme preference: $e');
    }
  }

  Future<void> setLanguage(String languageCode) async {
    if (_languageCode != languageCode) {
      _languageCode = languageCode;
      notifyListeners();
      
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_languagePrefKey, languageCode);
      } catch (e) {
        debugPrint('Error saving language preference: $e');
      }
    }
  }
}
