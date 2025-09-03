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
    apiKey: 'AIzaSyApCdUJZ-7SLxiyU7wZv-X9blC3b7xUaFk',
    appId: '1:302937873031:web:27e830bc62c4252f933622',
    messagingSenderId: '302937873031',
    projectId: 'easesih2025',
    authDomain: 'easesih2025.firebaseapp.com',
    storageBucket: 'easesih2025.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyApCdUJZ-7SLxiyU7wZv-X9blC3b7xUaFk',
    appId: '1:302937873031:android:27e830bc62c4252f933622',
    messagingSenderId: '302937873031',
    projectId: 'easesih2025',
    authDomain: 'easesih2025.firebaseapp.com',
    storageBucket: 'easesih2025.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyApCdUJZ-7SLxiyU7wZv-X9blC3b7xUaFk',
    appId: '1:302937873031:ios:27e830bc62c4252f933622',
    messagingSenderId: '302937873031',
    projectId: 'easesih2025',
    authDomain: 'easesih2025.firebaseapp.com',
    storageBucket: 'easesih2025.firebasestorage.app',
    iosBundleId: 'com.example.sih2025',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyApCdUJZ-7SLxiyU7wZv-X9blC3b7xUaFk',
    appId: '1:302937873031:macos:27e830bc62c4252f933622',
    messagingSenderId: '302937873031',
    projectId: 'easesih2025',
    authDomain: 'easesih2025.firebaseapp.com',
    storageBucket: 'easesih2025.firebasestorage.app',
    iosBundleId: 'com.example.sih2025',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyApCdUJZ-7SLxiyU7wZv-X9blC3b7xUaFk',
    appId: '1:302937873031:windows:27e830bc62c4252f933622',
    messagingSenderId: '302937873031',
    projectId: 'easesih2025',
    authDomain: 'easesih2025.firebaseapp.com',
    storageBucket: 'easesih2025.firebasestorage.app',
  );
}