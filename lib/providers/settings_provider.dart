import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  static const String _primaryColorKey = "primary_color";
  static const String _firstTimeKey = "is_first_time";
  static const String _languageKey = "language_code";
  static const String _biometricsKey = "biometrics_enabled";
  static const String _needsPercentKey = "needs_percent";
  static const String _wantsPercentKey = "wants_percent";
  static const String _savingsPercentKey = "savings_percent";

  final ThemeMode _themeMode = ThemeMode.dark;
  Color _primaryColor = const Color(0xFF6366F1);
  bool _isFirstTime = true;
  String _languageCode = 'es';
  bool _biometricsEnabled = false;
  
  double _needsPercent = 0.50;
  double _wantsPercent = 0.30;
  double _savingsPercent = 0.20;

  ThemeMode get themeMode => _themeMode;
  Color get primaryColor => _primaryColor;
  bool get isFirstTime => _isFirstTime;
  String get languageCode => _languageCode;
  bool get biometricsEnabled => _biometricsEnabled;
  double get needsPercent => _needsPercent;
  double get wantsPercent => _wantsPercent;
  double get savingsPercent => _savingsPercent;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    final colorValue = prefs.getInt(_primaryColorKey) ?? 0xFF6366F1;
    _primaryColor = Color(colorValue);

    _isFirstTime = prefs.getBool(_firstTimeKey) ?? true;
    _languageCode = prefs.getString(_languageKey) ?? 'es';
    _biometricsEnabled = prefs.getBool(_biometricsKey) ?? false;
    _needsPercent = prefs.getDouble(_needsPercentKey) ?? 0.50;
    _wantsPercent = prefs.getDouble(_wantsPercentKey) ?? 0.30;
    _savingsPercent = prefs.getDouble(_savingsPercentKey) ?? 0.20;
    
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

  Future<void> setLanguage(String code) async {
    _languageCode = code;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, code);
    notifyListeners();
  }

  Future<void> setBiometrics(bool value) async {
    _biometricsEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_biometricsKey, value);
    notifyListeners();
  }

  Future<void> setFinancialRule(double needs, double wants, double savings) async {
    _needsPercent = needs;
    _wantsPercent = wants;
    _savingsPercent = savings;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_needsPercentKey, needs);
    await prefs.setDouble(_wantsPercentKey, wants);
    await prefs.setDouble(_savingsPercentKey, savings);
    notifyListeners();
  }
}
