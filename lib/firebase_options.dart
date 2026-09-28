import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
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
      default:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCn6icXEbBE0KnuMr5Z_cPQNd2BKvhktag',
    appId: '1:834179717761:web:2089813cce2c71b2270b80',
    messagingSenderId: '834179717761',
    projectId: 'luckymam-app-dv',
    authDomain: 'luckymam-app-dv.firebaseapp.com',
    storageBucket: 'luckymam-app-dv.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCn6icXEbBE0KnuMr5Z_cPQNd2BKvhktag',
    appId: '1:834179717761:android:2089813cce2c71b2270b80',
    messagingSenderId: '834179717761',
    projectId: 'luckymam-app-dv',
    storageBucket: 'luckymam-app-dv.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCn6icXEbBE0KnuMr5Z_cPQNd2BKvhktag',
    appId: '1:834179717761:ios:2089813cce2c71b2270b80',
    messagingSenderId: '834179717761',
    projectId: 'luckymam-app-dv',
    storageBucket: 'luckymam-app-dv.firebasestorage.app',
    iosBundleId: 'com.luckmam.luckmam_mvp',
  );
}
