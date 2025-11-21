import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    as fln;

class VersionComponent {
  Future<void> check(fln.FlutterLocalNotificationsPlugin local) async {
    final current = await _getCurrentVersion();
    final latestData = await _getLatestVersionFromServer();

    final latestVersion = latestData["version_number"].toString();
    final urlAndroid = latestData["url_android"];
    final urlIos = latestData["url_ios"];

    if (latestVersion != current) {
      const androidDetails = fln.AndroidNotificationDetails(
        'updates_channel',
        'Mises à jour',
        importance: fln.Importance.high,
        priority: fln.Priority.high,
      );
      const iosDetails = fln.DarwinNotificationDetails();
      const details = fln.NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await local.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        "New version available",
        "Upgrade to version $latestVersion to enjoy the new features.",
        details,
        payload: urlAndroid ?? urlIos ?? "open_update_page",
      );
    } else {
      debugPrint("Application update : $current");
    }
  }

  Future<String> _getCurrentVersion() async {
    final info = await PackageInfo.fromPlatform();
    debugPrint("VERSION CURRENT : ${info.version}");
    return info.version;
  }

  Future<Map<String, dynamic>> _getLatestVersionFromServer() async {
    try {
      final dio = Dio();
      final response = await dio.get("http://localhost/api/user/getAllVersion");

      if (response.statusCode == 200) {
        final data = response.data;
        final versionData = data["data"];
        return versionData;
      } else {
        throw Exception("Error server: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error network: $e");
    }
  }
}
