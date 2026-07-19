import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'app/app.dart';
import 'firebase/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('🟣 STEP 1: Flutter initialized');

  // ✅ Initialize Firebase safely (avoid [core/duplicate-app])
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      debugPrint('🟢 Firebase initialized');
    } else {
      debugPrint('⚠️ Firebase already initialized');
    }
  } catch (e, st) {
    debugPrint('❌ Firebase initialization failed: $e');
    debugPrint(st.toString());
  }

  debugPrint('🟣 STEP 2: Running app…');
  runApp(const SkillConnectApp());
}
