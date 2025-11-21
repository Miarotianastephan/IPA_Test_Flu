import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../config/storage_config.dart';

class DeviceInfoHelper {
  static final DeviceInfoHelper _instance = DeviceInfoHelper._internal();
  static DeviceInfoHelper get instance => _instance;

  DeviceInfoHelper._internal();

  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  final Uuid _uuid = const Uuid();

  Future<String> getAppInstanceId() async {
    String? instanceId = StorageService.instance.getValue<String>(
      'app_instance_id',
    );

    if (instanceId == null || instanceId.isEmpty) {
      instanceId = _uuid.v4();
      await StorageService.instance.setValue('app_instance_id', instanceId);
    }

    return instanceId;
  }

  String getPlatform() {
    if (kIsWeb) return 'web';

    return switch (Platform.operatingSystem) {
      'android' => 'android',
      'ios' => 'ios',
      'windows' => 'windows',
      'macos' => 'macos',
      'linux' => 'linux',
      _ => 'unknown',
    };
  }

  Future<Object?> _getDeviceInfo() {
    return switch (Platform.operatingSystem) {
      'android' => _deviceInfo.androidInfo,
      'ios' => _deviceInfo.iosInfo,
      'windows' => _deviceInfo.windowsInfo,
      'macos' => _deviceInfo.macOsInfo,
      'linux' => _deviceInfo.linuxInfo,
      _ => Future.value(null),
    };
  }

  Future<String?> getDeviceName() async {
    final info = await _getDeviceInfo();
    return switch (info) {
      AndroidDeviceInfo i => '${i.manufacturer} ${i.model}',
      IosDeviceInfo i => i.model,
      WindowsDeviceInfo i => i.productName,
      MacOsDeviceInfo i => i.model,
      LinuxDeviceInfo i => i.prettyName,
      _ => null,
    };
  }

  Future<String?> getSystemVersion() async {
    try {
      if (kIsWeb) {
        final i = await _deviceInfo.webBrowserInfo;
        return i.userAgent;
      }
      final info = switch (Platform.operatingSystem) {
        'android' => await _deviceInfo.androidInfo,
        'ios' => await _deviceInfo.iosInfo,
        'windows' => await _deviceInfo.windowsInfo,
        'macos' => await _deviceInfo.macOsInfo,
        'linux' => await _deviceInfo.linuxInfo,
        _ => null,
      };
      return switch (info) {
        AndroidDeviceInfo i => 'Android ${i.version.release}',
        IosDeviceInfo i => 'iOS ${i.systemVersion}',
        WindowsDeviceInfo i => 'Windows ${i.displayVersion}',
        MacOsDeviceInfo i => 'macOS ${i.osRelease}',
        LinuxDeviceInfo i => i.version,
        _ => null,
      };
    } catch (e) {
      debugPrint('Error getting system version: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> getFirstOpenData() async {
    final appInstanceId = await getAppInstanceId();
    final platform = getPlatform();
    final deviceModel = await getDeviceName();
    final systemVersion = await getSystemVersion();

    return {
      'app_instance_id': appInstanceId,
      'platform': platform,
      'device_model': deviceModel,
      'system_version': systemVersion,
    };
  }
}
