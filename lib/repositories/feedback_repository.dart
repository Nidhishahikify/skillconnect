import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Reads/writes worker feedback, backed by Firestore with a
/// SharedPreferences cache/fallback for offline use.
class FeedbackRepository {
  final _db = FirebaseFirestore.instance;

  static String _feedbacksKey(String name) => 'feedbacks_$name';

  Future<void> addFeedback(
      String workerName, Map<String, dynamic> feedback) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _feedbacksKey(workerName);

    try {
      final cleanFeedback = <String, dynamic>{};
      feedback.forEach((k, v) {
        if (v != null &&
            v is! FieldValue &&
            v is! Timestamp &&
            v is! DocumentReference) {
          cleanFeedback[k] = v;
        }
      });

      List<String> feedbacks = prefs.getStringList(key) ?? [];
      feedbacks.add(jsonEncode(cleanFeedback));
      await prefs.setStringList(key, feedbacks);

      await _db.collection('feedbacks').add({
        'worker': workerName,
        ...cleanFeedback,
        'createdAt': FieldValue.serverTimestamp(),
      });

      print('✅ Feedback added for $workerName');
    } catch (e, st) {
      print('❌ Firestore addFeedback failed: $e\n$st');
    }
  }

  Future<List<Map<String, dynamic>>> loadFeedbacks(String workerName) async {
    try {
      final snap = await _db
          .collection('feedbacks')
          .where('worker', isEqualTo: workerName)
          .get();
      return snap.docs.map((d) => d.data()).toList();
    } catch (e) {
      print('⚠️ Firestore loadFeedbacks failed: $e');
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_feedbacksKey(workerName)) ?? [];
      return list.map((s) => jsonDecode(s) as Map<String, dynamic>).toList();
    }
  }

  /// Fetches raw feedback text for a worker (case-insensitive lookup via
  /// the `worker_lower` field), used as input to the AI summarizer.
  Future<List<String>> loadFeedbackTexts(String workerName) async {
    final snap = await _db
        .collection('feedbacks')
        .where('worker_lower', isEqualTo: workerName.toLowerCase())
        .get();
    return snap.docs
        .map((d) => (d.data()['text'] ?? '').toString())
        .where((t) => t.trim().isNotEmpty)
        .toList();
  }
}
