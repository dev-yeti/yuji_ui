import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static Future<void> saveUserSession(String userId, int id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('yujiUserId', userId);
    await prefs.setInt('yujiId', id);
  }

  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('yujiUserId');
  }

  static Future<int?> getId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('yujiId');
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('yujiUserId');
    await prefs.remove('yujiId');
  }
}