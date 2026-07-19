import 'package:flutter/material.dart';
import '../features/authentication/login_screen.dart';
import '../features/worker/worker_registration_screen.dart';
import '../features/feedback/feedback_screen.dart';
import '../features/booking/booking_screen.dart';
import '../features/summaries/summary_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const String login = '/login';
  static const String workerForm = '/workerForm';
  static const String feedback = '/feedback';
  static const String booking = '/booking';
  static const String summaries = '/summaries';

  static Map<String, WidgetBuilder> get routes => {
        login: (context) => const LoginScreen(),
        workerForm: (context) => const WorkerRegistrationScreen(),
        feedback: (context) => const FeedbackScreen(),
        booking: (context) {
          final args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>?;
          return BookingScreen(
            workerName: args?['workerName'] ?? '',
            workerEmail: args?['workerEmail'] ?? '',
          );
        },
        summaries: (context) => const SummariesScreen(),
      };
}
