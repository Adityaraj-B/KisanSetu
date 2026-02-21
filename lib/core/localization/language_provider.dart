import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');
  bool _hasSelectedLanguage = false;
  static const String _keyLanguage = 'language_code';
  static const String _keyHasSelectedLanguage = 'has_selected_language';

  Locale get locale => _locale;
  bool get hasSelectedLanguage => _hasSelectedLanguage;

  /// Load saved language from storage
  Future<void> loadSavedLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLanguage = prefs.getString(_keyLanguage);
      _hasSelectedLanguage = prefs.getBool(_keyHasSelectedLanguage) ?? false;
      if (savedLanguage != null) {
        _locale = Locale(savedLanguage);
      }
    } catch (e) {
      // If error, keep default English
      _locale = const Locale('en');
      _hasSelectedLanguage = false;
    }
    notifyListeners();
  }

  /// Set locale and save to storage
  Future<void> setLocale(String languageCode) async {
    if (languageCode == 'en' || languageCode == 'hi' || languageCode == 'mr') {
      _locale = Locale(languageCode);
      _hasSelectedLanguage = true;
      notifyListeners();

      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_keyLanguage, languageCode);
        await prefs.setBool(_keyHasSelectedLanguage, true);
      } catch (e) {
        // Silently fail if can't save
      }
    }
  }

  /// Reset language selection (for logout)
  Future<void> resetLanguageSelection() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyHasSelectedLanguage);
      _hasSelectedLanguage = false;
      notifyListeners();
    } catch (e) {
      // Silently fail
    }
  }

  void setEnglish() {
    setLocale('en');
  }

  void setHindi() {
    setLocale('hi');
  }

  void setMarathi() {
    setLocale('mr');
  }
}
