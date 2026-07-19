import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/utils/helpers.dart';

/// Reads/writes user & worker profiles, backed by Firestore with a
/// SharedPreferences cache/fallback for offline use.
class ProfileRepository {
  final _db = FirebaseFirestore.instance;

  static const _profileKey = 'profile';
  static const _profilesKey = 'profiles';

  Future<void> saveProfile(Map<String, dynamic> profile) async {
    final prefs = await SharedPreferences.getInstance();

    try {
      final cleanProfile = <String, dynamic>{};
      profile.forEach((key, value) {
        if (value is! FieldValue &&
            value is! Timestamp &&
            value is! DocumentReference) {
          cleanProfile[key] = value;
        }
      });

      await prefs.setString(_profileKey, jsonEncode(cleanProfile));

      final existing = prefs.getString(_profilesKey);
      List<Map<String, dynamic>> profiles = [];
      if (existing != null) {
        final list = jsonDecode(existing);
        if (list is List) {
          profiles = list.map((e) => Map<String, dynamic>.from(e)).toList();
        }
      }

      final id = cleanProfile['email'] ?? cleanProfile['name'];
      final index =
          profiles.indexWhere((p) => (p['email'] ?? p['name']) == id);
      if (index >= 0) {
        profiles[index] = cleanProfile;
      } else {
        profiles.add(cleanProfile);
      }
      await prefs.setString(_profilesKey, jsonEncode(profiles));

      if (id != null && id.toString().isNotEmpty) {
        final safeId = Helpers.toSafeDocId(id.toString());
        await _db.collection('profiles').doc(safeId).set(
          {
            ...cleanProfile,
            'createdAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
        print('✅ Profile saved to Firestore: $safeId');
      }
    } catch (e, st) {
      print('❌ saveProfile failed: $e\n$st');
    }
  }

  Future<Map<String, dynamic>?> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_profileKey);
    if (data != null) return jsonDecode(data) as Map<String, dynamic>;

    final snapshot = await _db.collection('profiles').limit(1).get();
    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.first.data();
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> loadAllProfiles() async {
    try {
      final snap = await _db.collection('profiles').get();
      return snap.docs.map((d) => d.data()).toList();
    } catch (e) {
      print('⚠️ Firestore loadAllProfiles failed: $e');
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString(_profilesKey);
      if (data == null) return [];
      final list = jsonDecode(data);
      if (list is List) {
        return list.map((e) => Map<String, dynamic>.from(e)).toList();
      }
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getAllWorkers() async {
    try {
      final snap = await _db
          .collection('profiles')
          .where('isWorker', isEqualTo: true)
          .get();
      return snap.docs.map((d) => d.data()).toList();
    } catch (e) {
      print('⚠️ Firestore getAllWorkers failed: $e');
      final all = await loadAllProfiles();
      return all.where((p) => p['isWorker'] == true).toList();
    }
  }

  /// Looks up a single profile by email. Returns null if none found.
  Future<Map<String, dynamic>?> findByEmail(String email) async {
    final snap = await _db
        .collection('profiles')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    return snap.docs.first.data();
  }
}
