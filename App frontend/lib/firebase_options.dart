// firebase_options.dart
// Generated from google-services.json — project: asha-portal-30695

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
      case TargetPlatform.windows:
        return web; // use web config for Windows desktop runner
      default:
        return web;
    }
  }

  // Web config — uses project-level API key & auth domain
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCCQ2cXTkMRRbIvW6Xfr1uqD_v36hiJMJE',
    appId: '1:794000208212:android:c9f45ed08c9c390736d8c1',
    messagingSenderId: '794000208212',
    projectId: 'asha-portal-30695',
    authDomain: 'asha-portal-30695.firebaseapp.com',
    storageBucket: 'asha-portal-30695.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCCQ2cXTkMRRbIvW6Xfr1uqD_v36hiJMJE',
    appId: '1:794000208212:android:c9f45ed08c9c390736d8c1',
    messagingSenderId: '794000208212',
    projectId: 'asha-portal-30695',
    storageBucket: 'asha-portal-30695.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCCQ2cXTkMRRbIvW6Xfr1uqD_v36hiJMJE',
    appId: '1:794000208212:android:c9f45ed08c9c390736d8c1',
    messagingSenderId: '794000208212',
    projectId: 'asha-portal-30695',
    storageBucket: 'asha-portal-30695.firebasestorage.app',
    iosClientId:
        '794000208212-2jalo63v81dde6gkcosg66j4gr7ealhh.apps.googleusercontent.com',
    iosBundleId: 'com.example.asha_setu',
  );
}
