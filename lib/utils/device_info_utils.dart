import 'package:flutter/foundation.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:uuid/uuid.dart';

class DeviceInfoUtils {
  static String? _cachedDeviceId;

  /// Récupère un ID unique pour l'appareil
  static Future<String?> getDeviceId() async {
    if (_cachedDeviceId != null) {
      return _cachedDeviceId;
    }

    try {
      if (kIsWeb) {
        // Pour le web, utiliser un UUID stocké dans localStorage
        _cachedDeviceId = const Uuid().v4();
      } else {
        final deviceInfo = DeviceInfoPlugin();
        
        if (defaultTargetPlatform == TargetPlatform.android) {
          final androidInfo = await deviceInfo.androidInfo;
          _cachedDeviceId = androidInfo.id; // Android ID
        } else if (defaultTargetPlatform == TargetPlatform.iOS) {
          final iosInfo = await deviceInfo.iosInfo;
          _cachedDeviceId = iosInfo.identifierForVendor ?? const Uuid().v4();
        } else {
          // Pour les autres plateformes, générer un UUID
          _cachedDeviceId = const Uuid().v4();
        }
      }
    } catch (e) {
      debugPrint('DeviceInfoUtils: Error getting device ID: $e');
      // En cas d'erreur, générer un UUID
      _cachedDeviceId = const Uuid().v4();
    }

    return _cachedDeviceId;
  }

  /// Récupère des informations sur l'appareil pour les logs
  static Future<Map<String, String>> getDeviceInfo() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      Map<String, String> info = {};

      if (kIsWeb) {
        info['platform'] = 'web';
      } else if (defaultTargetPlatform == TargetPlatform.android) {
        final androidInfo = await deviceInfo.androidInfo;
        info['platform'] = 'android';
        info['model'] = androidInfo.model;
        info['manufacturer'] = androidInfo.manufacturer;
        info['version'] = androidInfo.version.release;
        info['sdkInt'] = androidInfo.version.sdkInt.toString();
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        final iosInfo = await deviceInfo.iosInfo;
        info['platform'] = 'ios';
        info['model'] = iosInfo.model;
        info['systemVersion'] = iosInfo.systemVersion;
        info['name'] = iosInfo.name;
      } else {
        info['platform'] = defaultTargetPlatform.toString();
      }

      return info;
    } catch (e) {
      debugPrint('DeviceInfoUtils: Error getting device info: $e');
      return {'platform': defaultTargetPlatform.toString()};
    }
  }
}
