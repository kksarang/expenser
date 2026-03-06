import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  static const _hapticKey = 'haptic_enabled';
  bool _hapticEnabled = true;

  bool get hapticEnabled => _hapticEnabled;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _hapticEnabled = prefs.getBool(_hapticKey) ?? true;
    notifyListeners();
  }

  Future<void> toggleHaptic(bool enabled) async {
    _hapticEnabled = enabled;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hapticKey, enabled);
  }
}
