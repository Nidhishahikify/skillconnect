import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Reads/writes bookings, backed by Firestore with a SharedPreferences
/// cache/fallback for offline use.
class BookingRepository {
  final _db = FirebaseFirestore.instance;

  static String _bookingsKey(String name) => 'bookings_$name';

  Future<void> addBooking(
      String workerName, Map<String, dynamic> booking) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _bookingsKey(workerName);

    try {
      final cleanBooking = <String, dynamic>{};
      booking.forEach((k, v) {
        if (v != null &&
            v is! FieldValue &&
            v is! Timestamp &&
            v is! DocumentReference) {
          cleanBooking[k] = v;
        }
      });

      List<String> bookings = prefs.getStringList(key) ?? [];
      bookings.add(jsonEncode(cleanBooking));
      await prefs.setStringList(key, bookings);

      await _db.collection('bookings').add({
        'worker': workerName,
        ...cleanBooking,
        'createdAt': FieldValue.serverTimestamp(),
      });

      print('✅ Booking added successfully for $workerName');
    } catch (e, st) {
      print('❌ Firestore addBooking failed: $e\n$st');
    }
  }

  Future<List<Map<String, dynamic>>> loadBookings(String workerName) async {
    try {
      final snap = await _db
          .collection('bookings')
          .where('worker', isEqualTo: workerName)
          .get();
      return snap.docs.map((d) => d.data()).toList();
    } catch (e) {
      print('⚠️ Firestore loadBookings failed: $e');
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_bookingsKey(workerName)) ?? [];
      return list.map((s) => jsonDecode(s) as Map<String, dynamic>).toList();
    }
  }

  /// Updates the status ('accepted' / 'rejected') of a matching booking.
  Future<void> setBookingStatus({
    required String workerName,
    required String userEmail,
    required String timestamp,
    required String status,
  }) async {
    final snap = await _db
        .collection('bookings')
        .where('worker', isEqualTo: workerName)
        .where('userEmail', isEqualTo: userEmail)
        .where('timestamp', isEqualTo: timestamp)
        .get();

    if (snap.docs.isEmpty) return;

    await _db
        .collection('bookings')
        .doc(snap.docs.first.id)
        .update({'status': status});
  }
}
