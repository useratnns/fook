import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  bool _isDarkMode = false;
  bool _notificationsEnabled = true;

  // Help & Onboarding Flags
  bool _onboardingSeen = false;
  bool _dashboardGuideSeen = false;
  bool _tasksGuideSeen = false;
  bool _calendarGuideSeen = false;
  bool _notesGuideSeen = false;
  bool _focusGuideSeen = false;
  bool _settingsGuideSeen = false;

  bool get isDarkMode => _isDarkMode;
  bool get notificationsEnabled => _notificationsEnabled;

  bool get onboardingSeen => _onboardingSeen;
  bool get dashboardGuideSeen => _dashboardGuideSeen;
  bool get tasksGuideSeen => _tasksGuideSeen;
  bool get calendarGuideSeen => _calendarGuideSeen;
  bool get notesGuideSeen => _notesGuideSeen;
  bool get focusGuideSeen => _focusGuideSeen;
  bool get settingsGuideSeen => _settingsGuideSeen;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
    
    // Load help flags
    _onboardingSeen = prefs.getBool('onboardingSeen') ?? false;
    _dashboardGuideSeen = prefs.getBool('dashboardGuideSeen') ?? false;
    _tasksGuideSeen = prefs.getBool('tasksGuideSeen') ?? false;
    _calendarGuideSeen = prefs.getBool('calendarGuideSeen') ?? false;
    _notesGuideSeen = prefs.getBool('notesGuideSeen') ?? false;
    _focusGuideSeen = prefs.getBool('focusGuideSeen') ?? false;
    _settingsGuideSeen = prefs.getBool('settingsGuideSeen') ?? false;
    
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
    notifyListeners();
  }

  Future<void> toggleNotifications() async {
    _notificationsEnabled = !_notificationsEnabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', _notificationsEnabled);
    notifyListeners();
  }

  // Help Flag Setters
  Future<void> setOnboardingSeen() async {
    _onboardingSeen = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboardingSeen', true);
    notifyListeners();
  }

  Future<void> setGuideSeen(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, true);
    
    // Update local state
    switch (key) {
      case 'dashboardGuideSeen': _dashboardGuideSeen = true; break;
      case 'tasksGuideSeen': _tasksGuideSeen = true; break;
      case 'calendarGuideSeen': _calendarGuideSeen = true; break;
      case 'notesGuideSeen': _notesGuideSeen = true; break;
      case 'focusGuideSeen': _focusGuideSeen = true; break;
      case 'settingsGuideSeen': _settingsGuideSeen = true; break;
    }
    notifyListeners();
  }

  Future<void> resetHelp() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboardingSeen', false);
    await prefs.setBool('dashboardGuideSeen', false);
    await prefs.setBool('tasksGuideSeen', false);
    await prefs.setBool('calendarGuideSeen', false);
    await prefs.setBool('notesGuideSeen', false);
    await prefs.setBool('focusGuideSeen', false);
    await prefs.setBool('settingsGuideSeen', false);

    _onboardingSeen = false;
    _dashboardGuideSeen = false;
    _tasksGuideSeen = false;
    _calendarGuideSeen = false;
    _notesGuideSeen = false;
    _focusGuideSeen = false;
    _settingsGuideSeen = false;
    
    notifyListeners();
  }

  Future<void> resetData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _isDarkMode = false;
    _notificationsEnabled = true;
    await _loadSettings(); // Reload to reset all fields
    notifyListeners();
  }
}
