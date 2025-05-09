import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Configurações padrão do Firebase para o aplicativo Calma AI
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
          'DefaultFirebaseOptions não tem configuração para macOS.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions não tem configuração para Windows.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions não tem configuração para Linux.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions não tem configuração para $defaultTargetPlatform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAhiUR4P4OMODXhXvx4QYYLQIdMBukTNIU',
    appId: '1:123456789012:web:abc123def456',
    messagingSenderId: '123456789012',
    projectId: 'calmaai-64e94',
    authDomain: 'calmaai-64e94.firebaseapp.com',
    storageBucket: 'calmaai-64e94.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAhiUR4P4OMODXhXvx4QYYLQIdMBukTNIU',
    appId: '1:123456789012:android:abc123def456',
    messagingSenderId: '123456789012',
    projectId: 'calmaai-64e94',
    storageBucket: 'calmaai-64e94.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAhiUR4P4OMODXhXvx4QYYLQIdMBukTNIU',
    appId: '1:123456789012:ios:abc123def456',
    messagingSenderId: '123456789012',
    projectId: 'calmaai-64e94',
    storageBucket: 'calmaai-64e94.appspot.com',
    iosClientId: 'ios-client-id-here',
    iosBundleId: 'com.example.calmaAiFlutter',
  );
}
