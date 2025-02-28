// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyC1sPNQkiN72JDCsrdEdEC6Ke_aQmo40Tg',
    appId: '1:147695118015:web:90135a8128887ac78f880a',
    messagingSenderId: '147695118015',
    projectId: 'togoo-a70f2',
    authDomain: 'togoo-a70f2.firebaseapp.com',
    databaseURL: 'https://togoo-a70f2-default-rtdb.firebaseio.com',
    storageBucket: 'togoo-a70f2.firebasestorage.app',
    measurementId: 'G-B0W0BBZ3GD',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAzATiOskWK3dn0AtYV2n38ByLu9VdUJ-c',
    appId: '1:147695118015:android:3c0d2516919ad2f28f880a',
    messagingSenderId: '147695118015',
    projectId: 'togoo-a70f2',
    databaseURL: 'https://togoo-a70f2-default-rtdb.firebaseio.com',
    storageBucket: 'togoo-a70f2.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAveeVUkQ7clPogyF1mjetwVBjte1Tq0FQ',
    appId: '1:147695118015:ios:832d9851ff07f0a18f880a',
    messagingSenderId: '147695118015',
    projectId: 'togoo-a70f2',
    databaseURL: 'https://togoo-a70f2-default-rtdb.firebaseio.com',
    storageBucket: 'togoo-a70f2.firebasestorage.app',
    iosBundleId: 'com.example.togoo',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAveeVUkQ7clPogyF1mjetwVBjte1Tq0FQ',
    appId: '1:147695118015:ios:832d9851ff07f0a18f880a',
    messagingSenderId: '147695118015',
    projectId: 'togoo-a70f2',
    databaseURL: 'https://togoo-a70f2-default-rtdb.firebaseio.com',
    storageBucket: 'togoo-a70f2.firebasestorage.app',
    iosBundleId: 'com.example.togoo',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyC1sPNQkiN72JDCsrdEdEC6Ke_aQmo40Tg',
    appId: '1:147695118015:web:2aa5756fe73e66108f880a',
    messagingSenderId: '147695118015',
    projectId: 'togoo-a70f2',
    authDomain: 'togoo-a70f2.firebaseapp.com',
    databaseURL: 'https://togoo-a70f2-default-rtdb.firebaseio.com',
    storageBucket: 'togoo-a70f2.firebasestorage.app',
    measurementId: 'G-7X3E0V2Q0Q',
  );
}
