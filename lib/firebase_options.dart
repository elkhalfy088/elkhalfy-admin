import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      default:
        return android;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCveqPkBHOTFQLg9MDF3RK1EIN66xqBWrM',
    authDomain: 'elkhalfy-324b9.firebaseapp.com',
    databaseURL: 'https://elkhalfy-324b9-default-rtdb.firebaseio.com',
    projectId: 'elkhalfy-324b9',
    storageBucket: 'elkhalfy-324b9.firebasestorage.app',
    messagingSenderId: '1040857118437',
    appId: '1:1040857118437:web:97c7108303b157f70d860c',
    measurementId: 'G-31HHZM3VJ5',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCveqPkBHOTFQLg9MDF3RK1EIN66xqBWrM',
    appId: '1:1040857118437:android:97c7108303b157f70d860c',
    messagingSenderId: '1040857118437',
    projectId: 'elkhalfy-324b9',
    databaseURL: 'https://elkhalfy-324b9-default-rtdb.firebaseio.com',
    storageBucket: 'elkhalfy-324b9.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCveqPkBHOTFQLg9MDF3RK1EIN66xqBWrM',
    appId: '1:1040857118437:ios:97c7108303b157f70d860c',
    messagingSenderId: '1040857118437',
    projectId: 'elkhalfy-324b9',
    databaseURL: 'https://elkhalfy-324b9-default-rtdb.firebaseio.com',
    storageBucket: 'elkhalfy-324b9.firebasestorage.app',
    iosClientId: '1040857118437-ios.apps.googleusercontent.com',
    iosBundleId: 'com.elkhalfy.admin',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCveqPkBHOTFQLg9MDF3RK1EIN66xqBWrM',
    appId: '1:1040857118437:ios:97c7108303b157f70d860c',
    messagingSenderId: '1040857118437',
    projectId: 'elkhalfy-324b9',
    databaseURL: 'https://elkhalfy-324b9-default-rtdb.firebaseio.com',
    storageBucket: 'elkhalfy-324b9.firebasestorage.app',
    iosClientId: '1040857118437-ios.apps.googleusercontent.com',
    iosBundleId: 'com.elkhalfy.admin',
  );
}
