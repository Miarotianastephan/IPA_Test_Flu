import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    as fln;
import 'package:firebase_messaging/firebase_messaging.dart' as fcm;
import 'package:huawei_push/huawei_push.dart' as hms;
import 'package:pushy_flutter/pushy_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'version_component.dart';

class NotificationService {
  final fcm.FirebaseMessaging _messaging = fcm.FirebaseMessaging.instance;
  static final fln.FlutterLocalNotificationsPlugin localNotifications =
      fln.FlutterLocalNotificationsPlugin();

  final VersionComponent _version = VersionComponent();

  bool _usingFCM = false;
  String? _token;

  Future<void> init() async {
    const androidSettings = fln.AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    // const iosSettings = fln.DarwinInitializationSettings();
    const iosSettings = fln.DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = fln.InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse:
          (fln.NotificationResponse response) async {
            final payload = response.payload;
            if (payload != null && payload.isNotEmpty) {
              try {
                final uri = Uri.parse(payload);

                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                } else {
                  debugPrint("Unable to open URL: $payload");
                }
              } catch (e) {
                debugPrint("Error while opening payload: $e");
              }
            }
          },
    );
    debugPrint("Notification plugin initialized");

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
        try {
          String deviceToken = await Pushy.register();
          _token = deviceToken;
          debugPrint("Pushy actif — Token: $_token");

          Pushy.listen();

          Pushy.setNotificationListener((Map<String, dynamic> data) {
            final String? title = data['title'] ?? "Notification";
            final String? body = data['message'];

            debugPrint("Pushy message: $title - $body");

            showCustomLocalNotification(
              title ?? "Notification",
              body ?? "",
              "",
            );
          });
          _usingFCM = false;
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
    }
    if (Platform.isIOS) {
      try {
        final settings = await _messaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );

        debugPrint("iOS permission: ${settings.authorizationStatus}");

        _token = await _messaging.getAPNSToken();
        debugPrint("APNs token: $_token");

        String? tokenFCM = await _messaging.getToken();
        debugPrint("FCM token: $tokenFCM");

        _listenForegroundMessages();
        _listenOpenedAppMessages();
        _listenBackgroundMessages();

        _usingFCM = true;
      } catch (e) {
        try {
          String deviceToken = await Pushy.register();
          _token = deviceToken;
          debugPrint("Pushy actif — Token: $_token");

          Pushy.listen();

          Pushy.setNotificationListener((Map<String, dynamic> data) {
            final String? title = data['title'] ?? "Notification";
            final String? body = data['message'];

            debugPrint("Pushy message: $title - $body");

            showCustomLocalNotification(
              title ?? "Notification",
              body ?? "",
              "",
            );
          });
          _usingFCM = false;
        } catch (e) {
          debugPrint("Error Notif Ios : $e");
        }
      }
    }
    try {
      await _version.check(localNotifications);
    } catch (e) {
      debugPrint("Version check failed: $e");
    }
  }

  void _listenForegroundMessages() {
    fcm.FirebaseMessaging.onMessage.listen((fcm.RemoteMessage message) {
      debugPrint("FCM foreground: ${message.notification?.title}");
      _showLocalNotification(message);
    });
  }

  void _listenOpenedAppMessages() {
    fcm.FirebaseMessaging.onMessageOpenedApp.listen((
      fcm.RemoteMessage message,
    ) {
      debugPrint("App open in FCM: ${message.notification?.title}");
    });
  }

  void _listenBackgroundMessages() {
    fcm.FirebaseMessaging.onBackgroundMessage(
      _firebaseMessagingBackgroundHandler,
    );
  }

  Future<void> _showLocalNotification(fcm.RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    showCustomLocalNotification(
      notification.title ?? "Notification Firebase",
      notification.body ?? "",
      "",
    );
  }

  Future<void> showCustomLocalNotification(
    String title,
    String body,
    payload,
  ) async {
    const androidDetails = fln.AndroidNotificationDetails(
      'default_channel',
      'Notifications',
      importance: fln.Importance.high,
      priority: fln.Priority.high,
    );

    // const iosDetails = fln.DarwinNotificationDetails();
    const iosDetails = fln.DarwinNotificationDetails(
      presentAlert: true,
      presentSound: true,
      presentBadge: true,
    );

    const details = fln.NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    debugPrint("Showing local notification: $title - $body");
    await localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: payload,
    );
  }

  String get provider => _usingFCM ? "FCM" : "HMS";
}

Future<void> _firebaseMessagingBackgroundHandler(
  fcm.RemoteMessage message,
) async {
  debugPrint("FCM background: ${message.notification?.title}");
}
