import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return FirebaseOptions(
        apiKey: 'YOUR_WEB_API_KEY',
        authDomain: 'YOUR_PROJECT_ID.firebaseapp.com',
        projectId: 'YOUR_PROJECT_ID',
        storageBucket: 'YOUR_PROJECT_ID.appspot.com',
        messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
        appId: 'YOUR_WEB_APP_ID',
      );
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      return FirebaseOptions(
        apiKey: 'YOUR_ANDROID_API_KEY',
        appId: 'YOUR_ANDROID_APP_ID',
        messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
        projectId: 'YOUR_PROJECT_ID',
        storageBucket: 'YOUR_PROJECT_ID.appspot.com',
      );
    }

    if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      return FirebaseOptions(
        apiKey: 'YOUR_IOS_API_KEY',
        appId: 'YOUR_IOS_APP_ID',
        messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
        projectId: 'YOUR_PROJECT_ID',
        storageBucket: 'YOUR_PROJECT_ID.appspot.com',
        iosBundleId: 'YOUR_IOS_BUNDLE_ID',
        iosClientId: 'YOUR_IOS_CLIENT_ID',
        androidClientId: 'YOUR_ANDROID_CLIENT_ID',
      );
    }

    throw UnsupportedError(
      'DefaultFirebaseOptions are not configured for this platform.',
    );
  }
}
