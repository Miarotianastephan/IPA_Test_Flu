import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/api_client.dart';
import '../api/user_api.dart';
import '../models/api_response.dart';
import '../models/installation_stats.dart';
import '../utils/app_package_info.dart';
import '../utils/device_info_helper.dart';

class InstallationTrackingService {
  static const String _installationTrackedKey = 'installation_tracked';
  final ApiClient _apiClient;

  InstallationTrackingService(this._apiClient);

  Future<void> trackInstallationIfNeeded({String? userId}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasTracked = prefs.getBool(_installationTrackedKey) ?? false;

      if (hasTracked) {
        return;
      }

      if (kIsWeb) {
        final isIosWeb = await DeviceInfoHelper.instance.isIosWeb();
        if (!isIosWeb) {
          return;
        }
      }

      final hasConnectivity =
          await DeviceInfoHelper.instance.hasInternetConnectivity();

      if (!hasConnectivity) {
        return;
      }

      final deviceFingerprint =
          await DeviceInfoHelper.instance.getDeviceFingerprint();

      final platform = DeviceInfoHelper.instance.getPlatform();
      final deviceType = _mapPlatformToDeviceType(platform);

      var finalDeviceType = deviceType;
      if (kIsWeb) {
        if (await DeviceInfoHelper.instance.isIosWeb()) {
          finalDeviceType = 'ios';
        } else {
          finalDeviceType = 'h5';
        }
      }

      final appVersion = await AppPackageInfoUtil.getCurrentVersion();

      await _trackInstallation(
        deviceType: finalDeviceType,
        appVersion: appVersion,
        userId: userId,
        deviceFingerprint: deviceFingerprint,
      );

      await prefs.setBool(_installationTrackedKey, true);
    } catch (e, stack) {
      debugPrint('Error tracking installation: $e');
      debugPrint('Stack trace: $stack');
    }
  }

  String _mapPlatformToDeviceType(String platform) {
    return switch (platform) {
      'h5' => 'h5',
      'android' => 'android',
      'ios' => 'ios',
      _ => 'unknown',
    };
  }

  Future<InstallationStats?> _trackInstallation({
    required String deviceType,
    required String appVersion,
    required String deviceFingerprint,
    String? userId,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      UserApi.trackInstallation,
      data: {
        'deviceType': deviceType,
        'appVersion': appVersion,
        'deviceFingerprint': deviceFingerprint,
        if (userId != null) 'userId': userId,
      },
    );

    final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
      response,
      (json) => json as Map<String, dynamic>,
    );

    if (apiResponse.code != 1) {
      throw Exception('Failed to track installation: ${apiResponse.msg}');
    }

    if (apiResponse.data != null) {
      return InstallationStats.fromJson(apiResponse.data!);
    }

    return null;
  }

  Future<void> resetTracking() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_installationTrackedKey);
  }
}
