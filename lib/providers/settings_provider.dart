import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  static const String _primaryColorKey = "primary_color";
  static const String _firstTimeKey = "is_first_time";

  final ThemeMode _themeMode = ThemeMode.dark;
  Color _primaryColor = const Color(0xFF6366F1);
  bool _isFirstTime = true;

  ThemeMode get themeMode => _themeMode;
  Color get primaryColor => _primaryColor;
  bool get isFirstTime => _isFirstTime;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    final colorValue = prefs.getInt(_primaryColorKey) ?? 0xFF6366F1;
    _primaryColor = Color(colorValue);

    _isFirstTime = prefs.getBool(_firstTimeKey) ?? true;
    
    notifyListeners();
  }

  Future<void> setPrimaryColor(Color color) async {
    _primaryColor = color;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_primaryColorKey, color.value);
    notifyListeners();
  }

  Future<void> setFirstTime(bool value) async {
    _isFirstTime = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_firstTimeKey, value);
    notifyListeners();
  }
}
