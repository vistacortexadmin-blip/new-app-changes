// File generated for VistaCortex Firebase Configuration
// Based on android/app/google-services.json
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return ios;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDfJA20-qzoqEfJVB3dfpd3pgKeLSwnLOI',
    appId: '1:365026733234:web:29f8e38e4e67d115cf6dab',
    messagingSenderId: '365026733234',
    projectId: 'vista-cortex',
    authDomain: 'vista-cortex.firebaseapp.com',
    storageBucket: 'vista-cortex.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDfJA20-qzoqEfJVB3dfpd3pgKeLSwnLOI',
    appId: '1:365026733234:android:29f8e38e4e67d115cf6dab',
    messagingSenderId: '365026733234',
    projectId: 'vista-cortex',
    storageBucket: 'vista-cortex.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDfJA20-qzoqEfJVB3dfpd3pgKeLSwnLOI',
    appId: '1:365026733234:ios:29f8e38e4e67d115cf6dab',
    messagingSenderId: '365026733234',
    projectId: 'vista-cortex',
    storageBucket: 'vista-cortex.firebasestorage.app',
    iosBundleId: 'com.example.vistacortex_mobile',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDfJA20-qzoqEfJVB3dfpd3pgKeLSwnLOI',
    appId: '1:365026733234:web:29f8e38e4e67d115cf6dab',
    messagingSenderId: '365026733234',
    projectId: 'vista-cortex',
    authDomain: 'vista-cortex.firebaseapp.com',
    storageBucket: 'vista-cortex.firebasestorage.app',
  );
}
