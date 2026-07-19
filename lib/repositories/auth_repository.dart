import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Handles the locally-stored "active session" (this app authenticates
/// against Firestore profile documents directly rather than using
/// Firebase Auth — see [ProfileRepository]).
class AuthRepository {
  static const _activeRoleKey = 'active_role';
  static const _activeProfileKey = 'active_profile';

  Future<void> saveActiveProfile({
    required String role, // 'user' or 'worker'
    required Map<String, dynamic> profile,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_activeRoleKey, role);
    await prefs.setString(_activeProfileKey, jsonEncode(profile));
  }

  Future<Map<String, dynamic>?> loadActiveProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_activeProfileKey);
    if (data == null) return null;
    return Map<String, dynamic>.from(jsonDecode(data));
  }

  Future<String?> getActiveRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_activeRoleKey);
  }

  Future<void> clearActiveSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_activeRoleKey);
    await prefs.remove(_activeProfileKey);
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    print('🧹 Cleared all local data');
  }
}
