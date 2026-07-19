import 'package:firebase_core/firebase_core.dart';
import '../../firebase/firebase_options.dart';

/// Small helper to guarantee Firebase is initialized exactly once, even if
/// called from multiple entry points (e.g. a screen opened via a deep link
/// before `main()`'s init has finished).
class FirebaseService {
  FirebaseService._();

  static Future<void> ensureInitialized() async {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  }
}
