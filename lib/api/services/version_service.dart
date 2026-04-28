import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    as fln;

import '../../models/version.dart';
import '../../utils/app_package_info.dart';
import '../version_api.dart';
import './base_service.dart';

class ForceUpdateResult {
  final bool hasUpdate;
  final bool forceInstall;
  final Version? version;
  final String currentVersion;

  const ForceUpdateResult({
    required this.hasUpdate,
    required this.forceInstall,
    this.version,
    required this.currentVersion,
  });
}

class VersionService extends BaseService {
  VersionService(super.client);

  Future<ForceUpdateResult> checkForForceUpdate() async {
    final current = await getCurrentVersion();
    final latestVersionObj = await fetchVersion();

    if (latestVersionObj == null) {
      return ForceUpdateResult(
        hasUpdate: false,
        forceInstall: false,
        currentVersion: current,
      );
    }

    final hasUpdate = isUpdateAvailable(
      latestVersionObj.versionNumber,
      current,
    );

    return ForceUpdateResult(
      hasUpdate: hasUpdate,
      forceInstall: hasUpdate && latestVersionObj.forceInstall,
      version: latestVersionObj,
      currentVersion: current,
    );
  }

  Future<void> check(fln.FlutterLocalNotificationsPlugin local) async {
    final current = await getCurrentVersion();
    final latestVersionObj = await fetchVersion();

    if (latestVersionObj == null) {
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
    }
  }

  static Future<String> getCurrentVersion() async {
    return AppPackageInfoUtil.getCurrentVersion();
  }

  Future<Version?> fetchVersion() async {
    if (kIsWeb) {
      debugPrint('Skip getCurrentVersion API on web');
      return null;
    }

    try {
      final response = await post<Version>(
        VersionApi.getCurrentVersion,
        fromJson: (json) => Version.fromJson(json as Map<String, dynamic>),
      );
      return response.data;
    } catch (e) {
      debugPrint("fetchVersion error: $e");
      return null;
    }
  }

  static bool isUpdateAvailable(String latest, String current) {
    final latestParts =
        latest.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final currentParts =
        current.split('.').map((e) => int.tryParse(e) ?? 0).toList();

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
