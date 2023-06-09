// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyDQ9EqJhLLJ8v85MLxRWeCNQpNNuzrPezY',
    appId: '1:306065074302:web:c13294cdff40d4d8e2902f',
    messagingSenderId: '306065074302',
    projectId: 'othiaapp',
    authDomain: 'othiaapp.firebaseapp.com',
    databaseURL:
        'https://othiaapp-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'othiaapp.appspot.com',
    measurementId: 'G-3EZQMH40H8',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBzYQxM2bGpi8PJYCX-qA0MINguQMsS5hU',
    appId: '1:306065074302:android:d6899deaefbafb7be2902f',
    messagingSenderId: '306065074302',
    projectId: 'othiaapp',
    databaseURL:
        'https://othiaapp-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'othiaapp.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBDhVayheoZEGp2R4AUQEbTTL9wnX_jWK4',
    appId: '1:306065074302:ios:5a0d7bae01be158be2902f',
    messagingSenderId: '306065074302',
    projectId: 'othiaapp',
    databaseURL:
        'https://othiaapp-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'othiaapp.appspot.com',
    iosClientId:
        '306065074302-a0aejlvko3d7k7mio7mb8belsn9qobf0.apps.googleusercontent.com',
    iosBundleId: 'de.othia.othia',
  );
}
