import 'package:firebase_core/firebase_core.dart';

import '../../firebase_options.dart';

class AppConfig {
  static const bool useFirebaseAuth = true;
  static const bool useFirestoreData = true;

  static FirebaseOptions get firebaseOptions =>
      DefaultFirebaseOptions.currentPlatform;
}
