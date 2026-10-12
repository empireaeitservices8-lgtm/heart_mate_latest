import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not configured for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAyW-ERp53HgWEQbaCpfUATO_Ch2whot6k',
    appId: '1:455143541589:android:d8b268d6ec164da5e4bddc',
    messagingSenderId: '455143541589',
    projectId: 'heartmate-ed4c7',
    storageBucket: 'heartmate-ed4c7.firebasestorage.app',
  );
}
