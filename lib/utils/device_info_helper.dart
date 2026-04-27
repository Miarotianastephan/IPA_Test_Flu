import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../config/storage_config.dart';

class DeviceInfoHelper {
  static final DeviceInfoHelper _instance = DeviceInfoHelper._internal();
  static DeviceInfoHelper get instance => _instance;

  DeviceInfoHelper._internal();

  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  final Uuid _uuid = const Uuid();
  final Dio _dio = Dio();
  final Connectivity _connectivity = Connectivity();

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

  Future<String> getDeviceFingerprint() async {
    // Check if we already have a stored fingerprint
    String? storedFingerprint = StorageService.instance.getValue<String>(
      'device_fingerprint',
    );

    if (storedFingerprint != null && storedFingerprint.isNotEmpty) {
      return storedFingerprint;
    }

    // Generate new fingerprint with platform prefix + UUID
    final String prefix;
    if (kIsWeb) {
      prefix = 'web';
    } else if (Platform.isAndroid) {
      AndroidDeviceInfo info = await _deviceInfo.androidInfo;
      prefix = 'android_${info.id}';
    } else if (Platform.isIOS) {
      IosDeviceInfo info = await _deviceInfo.iosInfo;
      prefix = 'ios_${info.identifierForVendor}';
    } else {
      prefix = 'unknown';
    }

    storedFingerprint = '${prefix}_${_uuid.v4()}';
    await StorageService.instance.setValue(
      'device_fingerprint',
      storedFingerprint,
    );

    return storedFingerprint;
  }

  String getPlatform() {
    if (kIsWeb) return 'h5';

    return switch (Platform.operatingSystem) {
      'android' => 'android',
      'ios' => 'ios',
      'windows' => 'windows',
      'macos' => 'macos',
      'linux' => 'linux',
      _ => 'unknown',
    };
  }

  Future<bool> isIosWeb() async {
    if (!kIsWeb) return false;
    final info = await _deviceInfo.webBrowserInfo;
    final userAgent = info.userAgent;
    debugPrint('USER AGENT STUFF: $userAgent');
    if (userAgent == null) return false;
    return userAgent.contains('iPhone') ||
        userAgent.contains('iPad') ||
        userAgent.contains('iPod');
  }

  Future<Object?> _getDeviceInfo() {
    if (kIsWeb) {
      return _deviceInfo.webBrowserInfo;
    }
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
    if (Uri.base.queryParameters['deviceType'] == 'ios') {
      return 'ios';
    }

    final info = await _getDeviceInfo();
    return switch (info) {
      AndroidDeviceInfo i => '${i.manufacturer} ${i.model}',
      IosDeviceInfo i => i.model,
      WindowsDeviceInfo i => i.productName,
      MacOsDeviceInfo i => i.model,
      LinuxDeviceInfo i => i.prettyName,
      _ => 'h5',
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
        _ => 'h5',
      };
      return switch (info) {
        AndroidDeviceInfo i => 'Android ${i.version.release}',
        IosDeviceInfo i => 'iOS ${i.systemVersion}',
        WindowsDeviceInfo i => 'Windows ${i.displayVersion}',
        MacOsDeviceInfo i => 'macOS ${i.osRelease}',
        LinuxDeviceInfo i => i.version,
        _ => 'h5',
      };
    } catch (e) {
      debugPrint('Error getting system version: $e');
      return null;
    }
  }

  Future<String> getDeviceId() async {
    final plugin = DeviceInfoPlugin();

    if (kIsWeb) {
      final info = await plugin.webBrowserInfo;
      return info.userAgent ?? 'web';
    } else if (Platform.isAndroid) {
      final info = await plugin.androidInfo;
      return info.id; // Android unique ID
    } else if (Platform.isIOS) {
      final info = await plugin.iosInfo;
      return info.identifierForVendor ?? 'ios';
    }
    return 'unknown';
  }

  Future<bool> hasInternetConnectivity() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();

      if (connectivityResult.contains(ConnectivityResult.none)) {
        debugPrint('No network connectivity available');
        return false;
      }

      return true;
    } catch (e) {
      debugPrint('Error checking connectivity: $e');
      return false;
    }
  }

  Future<String?> getLocalIpAddress() async {
    if (kIsWeb) {
      return null;
    }

    try {
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
        includeLinkLocal: false,
      );

      for (var interface in interfaces) {
        for (var addr in interface.addresses) {
          if (!addr.isLoopback) {
            return addr.address;
          }
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error getting local IP address: $e');
      return null;
    }
  }

  Future<String?> getPublicIpAddress() async {
    try {
      final hasConnectivity = await hasInternetConnectivity();
      if (!hasConnectivity) {
        debugPrint('No internet connectivity - skipping public IP fetch');
        return null;
      }

      final response = await _dio.get(
        'https://api.ipify.org?format=json',
        options: Options(
          receiveTimeout: const Duration(seconds: 5),
          sendTimeout: const Duration(seconds: 5),
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        return response.data['ip'] as String?;
      }
      return null;
    } catch (e) {
      debugPrint('Error getting public IP address: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> getFirstOpenData() async {
    final appInstanceId = await getAppInstanceId();
    String finalDeviceType = getPlatform();
    if (kIsWeb) {
      if (await DeviceInfoHelper.instance.isIosWeb()) {
        finalDeviceType = 'ios';
      } else {
        finalDeviceType = 'h5';
      }
    }
    final deviceModel = await getDeviceName();
    final systemVersion = await getSystemVersion();
    final localIp = await getLocalIpAddress();
    final publicIp = await getPublicIpAddress();

    return {
      'app_instance_id': appInstanceId,
      'platform': finalDeviceType,
      'device_model': deviceModel,
      'system_version': systemVersion,
      'local_ip': localIp,
      'public_ip': publicIp,
    };
  }
}
