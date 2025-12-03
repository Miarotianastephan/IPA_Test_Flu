import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:live_app/models/version.dart';
import 'package:live_app/models/version_response.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    as fln;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class VersionComponent {
  Future<void> check(fln.FlutterLocalNotificationsPlugin local) async {
    final current = await getCurrentVersion();
    final latestVersionObj = await fetchVersion();

    if (latestVersionObj == null) {
      debugPrint("Unable to retrieve the latest version");
      return;
    }

    final latestVersion = latestVersionObj.versionNumber;

    if (isUpdateAvailable(latestVersion, current)) {
      const androidDetails = fln.AndroidNotificationDetails(
        'default_channel',
        'Notifications',
        importance: fln.Importance.high,
        priority: fln.Priority.high,
      );

      const iosDetails = fln.DarwinNotificationDetails(
        presentAlert: true,
        presentSound: true,
        presentBadge: true,
      );

      const details = fln.NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await local.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        "New version available",
        "Upgrade to version $latestVersion to enjoy the new features.",
        details,
        payload: "https://landing.99sq20.fun/",
      );
    } else {
      debugPrint("Application is up to date: $current");
    }
  }

  static Future<String> getCurrentVersion() async {
    final info = await PackageInfo.fromPlatform();
    debugPrint("CURRENT VERSION: ${info.version}");
    return info.version;
  }

  static Future<Version?> fetchVersion() async {
    try {
      final dio = Dio();
      final baseUrl = dotenv.env['API_BASE_URL'];
      if (baseUrl == null || baseUrl.isEmpty) {
        return null;
      }

      final response = await dio.post("$baseUrl/api/user/getCurrentVersion");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final rawData = response.data;
        final decoded = rawData is String ? jsonDecode(rawData) : rawData;

        if (decoded is Map<String, dynamic>) {
          final versionResponse = VersionResponse.fromJson(decoded);
          debugPrint("Latest version: ${versionResponse.data}");
          return versionResponse.data;
        } else {
          debugPrint("Unexpected JSON format: $decoded");
          return null;
        }
      } else {
        return null;
      }
    } catch (e) {
      debugPrint("fetchVersion error: $e");
      return null;
    }
  }

  static bool isUpdateAvailable(String latest, String current) {
    final latestParts = latest
        .split('.')
        .map((e) => int.tryParse(e) ?? 0)
        .toList();
    final currentParts = current
        .split('.')
        .map((e) => int.tryParse(e) ?? 0)
        .toList();

    final maxLength = latestParts.length > currentParts.length
        ? latestParts.length
        : currentParts.length;

    for (int i = 0; i < maxLength; i++) {
      final latestPart = i < latestParts.length ? latestParts[i] : 0;
      final currentPart = i < currentParts.length ? currentParts[i] : 0;

      if (latestPart > currentPart) return true;
      if (latestPart < currentPart) return false;
    }
    return false;
  }
}
