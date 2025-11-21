import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart' as fln;
import 'package:firebase_messaging/firebase_messaging.dart' as fcm;
import 'package:huawei_push/huawei_push.dart' as hms;
import 'package:pushy_flutter/pushy_flutter.dart';
import 'version_component.dart';

class NotificationService {
  final fcm.FirebaseMessaging _messaging = fcm.FirebaseMessaging.instance;
  final fln.FlutterLocalNotificationsPlugin _localNotifications =
      fln.FlutterLocalNotificationsPlugin();

  final VersionComponent _version = VersionComponent();

  bool _usingFCM = false;
  String? _token;

  Future<void> init() async {
    const androidSettings = fln.AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = fln.DarwinInitializationSettings();
    const initSettings = fln.InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (fln.NotificationResponse response) {
        final payload = response.payload;
        debugPrint("Payload: $payload");
      },
    );

    try {
      String deviceToken = await Pushy.register();
      _token = deviceToken;
      debugPrint("Pushy actif — Token: $_token");

      Pushy.listen();

      Pushy.setNotificationListener((Map<String, dynamic> data) {
        final String? title = data['title'] ?? "Notification";
        final String? body = data['message'];

        debugPrint("Pushy message: $title - $body");

        _showCustomLocalNotification(title ?? "Notification", body ?? "");
      });
    } catch (e) {
      debugPrint("Error Pushy: $e");
    }

    if (Platform.isAndroid) {
      try {
        await _messaging.requestPermission();
        _usingFCM = true;

        _token = await _messaging.getToken();
        debugPrint("FCM actif — Token: $_token");

        _listenForegroundMessages();
        _listenOpenedAppMessages();
        _listenBackgroundMessages();
      } catch (e) {
        _usingFCM = false;
        debugPrint("No GMS, switch HMS");

        hms.Push.getTokenStream.listen((event) {
          _token = event;
          debugPrint("HMS actif — Token: $_token");
        });

        hms.Push.getToken("");
      }
    }
    await _version.check(_localNotifications);
  }

  void _listenForegroundMessages() {
    fcm.FirebaseMessaging.onMessage.listen((fcm.RemoteMessage message) {
      debugPrint("FCM foreground: ${message.notification?.title}");
      _showLocalNotification(message);
    });
  }

  void _listenOpenedAppMessages() {
    fcm.FirebaseMessaging.onMessageOpenedApp.listen((fcm.RemoteMessage message) {
      debugPrint("App open in FCM: ${message.notification?.title}");
    });
  }

  void _listenBackgroundMessages() {
    fcm.FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  Future<void> _showLocalNotification(fcm.RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    _showCustomLocalNotification(
      notification.title ?? "Notification",
      notification.body ?? "",
    );
  }

  Future<void> _showCustomLocalNotification(String title, String body) async {
    const androidDetails = fln.AndroidNotificationDetails(
      'default_channel',
      'Notifications',
      importance: fln.Importance.high,
      priority: fln.Priority.high,
    );

    const iosDetails = fln.DarwinNotificationDetails();

    const details = fln.NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: "open_home",
    );
  }

  String get provider => _usingFCM ? "FCM" : "HMS";
}

Future<void> _firebaseMessagingBackgroundHandler(fcm.RemoteMessage message) async {
  debugPrint("FCM background: ${message.notification?.title}");
}
