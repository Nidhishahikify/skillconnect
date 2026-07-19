import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_keys.dart';

/// Wraps all outbound transactional emails sent via EmailJS
/// (https://www.emailjs.com/). Credentials come from [ApiKeys] — never
/// hardcode them here.
class EmailService {
  EmailService._();

  static final Uri _endpoint =
      Uri.parse('https://api.emailjs.com/api/v1.0/email/send');

  static bool get _isConfigured =>
      ApiKeys.emailJsServiceId.isNotEmpty &&
      ApiKeys.emailJsPublicKey.isNotEmpty &&
      ApiKeys.emailJsTemplateId.isNotEmpty;

  /// 1️⃣ Send booking notification → to Worker
  static Future<void> sendBookingEmail({
    required String workerEmail,
    required String workerName,
    required String userName,
    required String bookingDate,
    String? customerEmail,
  }) async {
    if (!_isConfigured) {
      print('⚠️ EmailService not configured — skipping booking email.');
      return;
    }

    final response = await http.post(
      _endpoint,
      headers: {
        'origin': 'http://localhost',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'service_id': ApiKeys.emailJsServiceId,
        'template_id': ApiKeys.emailJsTemplateId,
        'user_id': ApiKeys.emailJsPublicKey,
        'template_params': {
          'email_title': '📢 New Booking Received!',
          'email_message': 'You have received a booking from $userName.',
          'title_color': '#000000',
          'customer_name': userName,
          'worker_name': workerName,
          'customer_email': customerEmail ?? '',
          'booking_time': bookingDate,
          'to_email': workerEmail,
          'date': '',
          'time': '',
        },
      }),
    );

    if (response.statusCode == 200) {
      print('📧 Booking email sent to worker');
    } else {
      print('❌ Booking email failed: ${response.body}');
    }
  }

  /// 2️⃣ Send password recovery email (separate template)
  static Future<void> sendPasswordRecoveryEmail({
    required String toEmail,
    required String userName,
    required String password,
  }) async {
    if (!_isConfigured || ApiKeys.emailJsPasswordTemplateId.isEmpty) {
      print('⚠️ EmailService not configured — skipping recovery email.');
      return;
    }

    final response = await http.post(
      _endpoint,
      headers: {
        'origin': 'http://localhost',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'service_id': ApiKeys.emailJsServiceId,
        'template_id': ApiKeys.emailJsPasswordTemplateId,
        'user_id': ApiKeys.emailJsPublicKey,
        'template_params': {
          'to_email': toEmail,
          'to_name': userName,
          'user_password': password,
        },
      }),
    );

    if (response.statusCode == 200) {
      print('📧 Password email sent');
    } else {
      print('❌ Password email failed: ${response.body}');
    }
  }

  /// 3️⃣ Send booking status update → to User (accepted / rejected)
  static Future<void> sendStatusEmail({
    required String customerEmail,
    required String customerName,
    required String workerName,
    required String date,
    required String time,
    required String status, // accepted / rejected
  }) async {
    if (!_isConfigured) {
      print('⚠️ EmailService not configured — skipping status email.');
      return;
    }

    String title = '';
    String message = '';
    String color = '';

    if (status == 'accepted') {
      title = '✔ Booking Accepted';
      message = 'Your booking has been accepted by $workerName.';
      color = 'green';
    } else if (status == 'rejected') {
      title = '✖ Booking Rejected';
      message = 'Your booking request was declined by $workerName.';
      color = 'red';
    }

    final response = await http.post(
      _endpoint,
      headers: {
        'origin': 'http://localhost',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'service_id': ApiKeys.emailJsServiceId,
        'template_id': ApiKeys.emailJsTemplateId,
        'user_id': ApiKeys.emailJsPublicKey,
        'template_params': {
          'email_title': title,
          'email_message': message,
          'title_color': color,
          'customer_name': customerName,
          'worker_name': workerName,
          'customer_email': customerEmail,
          'booking_time': '',
          'date': date,
          'time': time,
          'to_email': customerEmail,
        },
      }),
    );

    if (response.statusCode == 200) {
      print('📧 Status email sent ($status)');
    } else {
      print('❌ Status email failed: ${response.body}');
    }
  }
}
