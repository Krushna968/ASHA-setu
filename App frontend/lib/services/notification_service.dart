import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'dart:developer';
import 'api_service.dart';
import 'auth_service.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  log("Handling a background message: ${message.messageId}");
}

class NotificationService {
  static FirebaseMessaging get _firebaseMessaging => FirebaseMessaging.instance;

  static Future<void> initialize() async {
    if (kIsWeb) {
      log('NotificationService: Skipping initialization on Web');
      return;
    }

    // Request permission
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      log('User granted permission');
    } else {
      log('User declined or has not accepted permission');
    }

    // Get token
    try {
      String? token = await _firebaseMessaging.getToken();
      if (token != null) {
        log("FirebaseMessaging token: $token");
        await _sendTokenToBackend(token);
      }
    } catch (e) {
      log('Failed to fetch FCM token: $e');
    }

    _firebaseMessaging.onTokenRefresh.listen((String newToken) {
      log("FirebaseMessaging token refreshed: $newToken");
      _sendTokenToBackend(newToken);
    });

    // Foreground notifications
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log('Got a message whilst in the foreground!');
      log('Message data: ${message.data}');

      if (message.notification != null) {
        log('Message also contained a notification: ${message.notification}');
      }
    });

    // Background notifications
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  static Future<void> _sendTokenToBackend(String token) async {
    try {
      // Check if logged in first before sending
      final isLoggedIn = await AuthService.isLoggedIn();
      if (isLoggedIn) {
        await ApiService.post('/worker/fcm-token', {'fcmToken': token});
        log('Successfully sent FCM token to backend');
      } else {
        log('User not logged in, skipping FCM token send');
      }
    } catch (e) {
      log('Failed to send FCM token to backend: $e');
    }
  }

  static Future<void> sendCurrentToken() async {
    if (kIsWeb) return;
    try {
      String? token = await _firebaseMessaging.getToken();
      if (token != null) {
        await _sendTokenToBackend(token);
      }
    } catch (e) {
      log('Failed to send current FCM token: $e');
    }
  }
}
