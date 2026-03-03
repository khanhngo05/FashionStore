// File Ä‘Æ°á»£c táº¡o tá»± Ä‘á»™ng bá»Ÿi FlutterFire CLI.
// KhÃ´ng chá»‰nh sá»­a thá»§ cÃ´ng file nÃ y.
// ignore_for_file: type=lint

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Cáº¥u hÃ¬nh Firebase cho á»©ng dá»¥ng FashionStore
/// Project ID: fashionstore-1b406
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
          'DefaultFirebaseOptions chÆ°a cáº¥u hÃ¬nh cho Linux.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions khÃ´ng há»— trá»£ platform nÃ y.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyB3zvxQLm5MmF1wHgDR4wJOkz_tSC1hLc8',
    appId: '1:202026031113:web:1f1c25c17f436ac12d40d8',
    messagingSenderId: '202026031113',
    projectId: 'fashionstore-1b406',
    authDomain: 'fashionstore-1b406.firebaseapp.com',
    storageBucket: 'fashionstore-1b406.firebasestorage.app',
    measurementId: 'G-1FKFVZ18N4',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBzC3ghccTSbk_XB_JQzSh0yrVskk3jFZM',
    appId: '1:202026031113:android:0e325a07aba4ab212d40d8',
    messagingSenderId: '202026031113',
    projectId: 'fashionstore-1b406',
    storageBucket: 'fashionstore-1b406.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAGrQYJg98WyxINZCpRYCDCrql-sK7KdSI',
    appId: '1:202026031113:ios:00579f875a2130212d40d8',
    messagingSenderId: '202026031113',
    projectId: 'fashionstore-1b406',
    storageBucket: 'fashionstore-1b406.firebasestorage.app',
    iosBundleId: 'com.example.fashionStore',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAGrQYJg98WyxINZCpRYCDCrql-sK7KdSI',
    appId: '1:202026031113:ios:00579f875a2130212d40d8',
    messagingSenderId: '202026031113',
    projectId: 'fashionstore-1b406',
    storageBucket: 'fashionstore-1b406.firebasestorage.app',
    iosBundleId: 'com.example.fashionStore',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyB3zvxQLm5MmF1wHgDR4wJOkz_tSC1hLc8',
    appId: '1:202026031113:web:5e5e1e2f348a6beb2d40d8',
    messagingSenderId: '202026031113',
    projectId: 'fashionstore-1b406',
    authDomain: 'fashionstore-1b406.firebaseapp.com',
    storageBucket: 'fashionstore-1b406.firebasestorage.app',
    measurementId: 'G-CRL4ZL3ELB',
  );


}
