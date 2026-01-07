import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show NetworkAssetBundle;
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    as fln;
import 'package:firebase_messaging/firebase_messaging.dart' as fcm;
import 'package:huawei_push/huawei_push.dart' as hms;
import 'package:path_provider/path_provider.dart';
import 'package:pushy_flutter/pushy_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../main.dart';
import 'version_component.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final fcm.FirebaseMessaging _messaging = fcm.FirebaseMessaging.instance;
  static final fln.FlutterLocalNotificationsPlugin localNotifications =
      fln.FlutterLocalNotificationsPlugin();

  final VersionComponent _version = VersionComponent();

  bool _usingFCM = false;
  String? _token;

  final Map<int, int> _notifIds = {};
  final Map<int, String> _notifBodies = {};

  // ----------------------------
  // INIT
  // ----------------------------
  Future<void> init() async {
    const androidSettings = fln.AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
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
      onDidReceiveNotificationResponse: _onNotificationClick,
    );

    await _initPushServices();

    try {
      await _version.check(localNotifications);
    } catch (e) {
      debugPrint("Version check failed: $e");
    }
  }

  // ----------------------------
  // HANDLE NOTIFICATION CLICK
  // ----------------------------
  Future<void> _onNotificationClick(fln.NotificationResponse response) async {
    final payload = response.payload;
    if (payload == null || payload.isEmpty) return;

    try {
      final uri = Uri.parse(payload);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return;
      }

      if (payload.startsWith("route:")) {
        final clean = payload.replaceFirst("route:", "");
        final uri = Uri.parse(clean);
        final route = uri.path;
        final params = uri.queryParameters;

        final convIdStr = params['conversationId'];
        if (convIdStr != null) {
          final convId = int.tryParse(convIdStr);
          if (convId != null) {
            _notifBodies.remove(convId);
            _notifIds.remove(convId);
          }
        }

        navigatorKey.currentState?.pushNamed(route, arguments: params);
        return;
      }
    } catch (e) {
      debugPrint("Error while opening payload: $e");
    }
  }

  // ----------------------------
  // PUSH SERVICES INIT
  // ----------------------------
  Future<void> _initPushServices() async {
    if (Platform.isAndroid) {
      try {
        await _messaging.requestPermission();
        _usingFCM = true;
        _token = await _messaging.getToken();
        _listenFCMMessages();
      } catch (_) {
        await _initPushyOrHMS();
      }
    } else if (Platform.isIOS) {
      try {
        await _messaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );
        _token = await _messaging.getAPNSToken();
        await _messaging.getToken();
        _listenFCMMessages();
        _usingFCM = true;
      } catch (_) {
        await _initPushyOrHMS();
      }
    }
  }

  Future<void> _initPushyOrHMS() async {
    try {
      String deviceToken = await Pushy.register();
      _token = deviceToken;
      Pushy.listen();
      Pushy.setNotificationListener((Map<String, dynamic> data) {
        final title = data['title'] ?? "Notification";
        final body = data['message'] ?? "";
        showCustomLocalNotification(title, body, "");
      });
      _usingFCM = false;
    } catch (_) {
      _usingFCM = false;
      hms.Push.getTokenStream.listen((event) {
        _token = event;
      });
      hms.Push.getToken("");
    }
  }

  void _listenFCMMessages() {
    fcm.FirebaseMessaging.onMessage.listen(_showFCMNotification);
    fcm.FirebaseMessaging.onMessageOpenedApp.listen((msg) {
      debugPrint("FCM open: ${msg.notification?.title}");
    });
    fcm.FirebaseMessaging.onBackgroundMessage(
      _firebaseMessagingBackgroundHandler,
    );
  }

  Future<void> _showFCMNotification(fcm.RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;
    showCustomLocalNotification(
      notification.title ?? "Notification Firebase",
      notification.body ?? "",
      "",
    );
  }

  Future<fln.FilePathAndroidBitmap?> loadAvatarFromUrl(String url) async {
    try {
      final bytes = (await NetworkAssetBundle(
        Uri.parse(url),
      ).load(url)).buffer.asUint8List();
      final dir = await getTemporaryDirectory();
      final file = File(
        '${dir.path}/avatar_${DateTime.now().microsecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(bytes);
      return fln.FilePathAndroidBitmap(file.path);
    } catch (e) {
      debugPrint("Failed to load avatar from URL: $e");
      return null;
    }
  }

  // ----------------------------
  // SHOW / UPDATE CHAT NOTIFICATION
  // ----------------------------
  Future<void> showOrUpdateChatNotification({
    required int conversationId,
    required String title,
    required String message,
    required String payload,
    String? imageUrl,
  }) async {
    final service = NotificationService.instance;

    final notifId =
        service._notifIds[conversationId] ??
        DateTime.now().millisecondsSinceEpoch ~/ 1000;

    final oldBody = service._notifBodies[conversationId];
    final newBody = oldBody == null ? message : "$oldBody\n$message";

    service._notifBodies[conversationId] = newBody;
    service._notifIds[conversationId] = notifId;

    fln.FilePathAndroidBitmap? avatar;
    if (imageUrl != null && imageUrl.isNotEmpty) {
      avatar = await loadAvatarFromUrl(imageUrl);
    }

    final person = fln.Person(name: title, key: 'user_$conversationId');

    final messages = newBody
        .split('\n')
        .map((text) => fln.Message(text, DateTime.now(), person))
        .toList();

    final android = fln.AndroidNotificationDetails(
      'chat_channel',
      'Chat Messages',
      importance: fln.Importance.high,
      priority: fln.Priority.high,
      autoCancel: true,
      enableVibration: true,
      playSound: true,
      category: fln.AndroidNotificationCategory.message,
      largeIcon: avatar,
      styleInformation: fln.MessagingStyleInformation(
        person,
        groupConversation: false,
        conversationTitle: title,
        messages: messages,
      ),
    );

    const ios = fln.DarwinNotificationDetails(
      presentAlert: true,
      presentSound: true,
      presentBadge: true,
    );

    final details = fln.NotificationDetails(android: android, iOS: ios);

    await localNotifications.show(
      notifId,
      title,
      message,
      details,
      payload: payload,
    );
  }

  // ----------------------------
  // SHOW SIMPLE NOTIFICATION
  // ----------------------------
  static Future<void> showCustomLocalNotification(
    String title,
    String body,
    String payload,
  ) async {
    const android = fln.AndroidNotificationDetails(
      'default_channel',
      'Notifications',
      importance: fln.Importance.high,
      priority: fln.Priority.high,
    );

    const ios = fln.DarwinNotificationDetails(
      presentAlert: true,
      presentSound: true,
      presentBadge: true,
    );

    const details = fln.NotificationDetails(android: android, iOS: ios);

    await localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: payload,
    );
  }

  // ----------------------------
  // SHOW PROGRESS NOTIFICATION
  // ----------------------------
  static Future<void> showDownloadProgressNotification({
    required int notifId,
    required String title,
    required String body,
    required String payload,
  }) async {
    final safeId = notifId % 2147483647;

    final android = fln.AndroidNotificationDetails(
      'download_channel',
      'Téléchargements',
      channelDescription: 'Progression des téléchargements',
      importance: fln.Importance.high,
      priority: fln.Priority.high,
      onlyAlertOnce: true,
      ongoing: true,
      autoCancel: false,
    );

    final details = fln.NotificationDetails(android: android);

    await localNotifications.show(
      safeId,
      title,
      body,
      details,
      payload: payload,
    );
  }

  String get provider => _usingFCM ? "FCM" : "HMS";

  // ----------------------------
  // GROUP INVITATION NOTIFICATIONS
  // ----------------------------

  /// Show notification for group invitation (direct invitation from owner/admin)
  static Future<void> showGroupInvitationNotification({
    required String inviterName,
    required String groupName,
    required int conversationId,
  }) async {
    await showCustomLocalNotification(
      "Group Invitation",
      "$inviterName invites you to join \"$groupName\"",
      "group_invitation:$conversationId",
    );
  }

  /// Show notification for invitation approval request (from regular member)
  static Future<void> showInvitationApprovalNotification({
    required String inviterName,
    required String inviteeName,
    required String groupName,
    required int conversationId,
    required int inviteeId,
  }) async {
    await showCustomLocalNotification(
      "Invitation Approval",
      "$inviterName wants to invite $inviteeName to \"$groupName\"",
      "invitation_approval:$conversationId:$inviteeId",
    );
  }
}

// ----------------------------
// BACKGROUND HANDLER
// ----------------------------
Future<void> _firebaseMessagingBackgroundHandler(
  fcm.RemoteMessage message,
) async {
  debugPrint("FCM background: ${message.notification?.title}");
}
