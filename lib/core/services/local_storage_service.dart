import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    // Add other local storage clearing logic here if needed (e.g. Hive, SQLite)
  }
}
