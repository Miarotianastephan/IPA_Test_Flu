import 'dart:io';
import 'platform_check_web.dart'
    if (dart.library.io) 'platform_check_io.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:media_kit/media_kit.dart';

class PlatformCheck {
  static AndroidDeviceInfo? _cachedAndroidInfo;

  static Future<bool> initMediaKitIfHuawei() async {
    if (!Platform.isAndroid) return false;
    final info = await getAndroidInfo();
    final isHuawei = info.manufacturer.toLowerCase() == "huawei";

    if (isHuawei) {
      MediaKit.ensureInitialized();
    }

    return isHuawei;
  }

  static Future<AndroidDeviceInfo> getAndroidInfo() async {
    _cachedAndroidInfo ??= await DeviceInfoPlugin().androidInfo;
    return _cachedAndroidInfo!;
  }

  static Future<bool> isHarmonyOS() async {
    if (!Platform.isAndroid) return false;
    final info = await getAndroidInfo();
    final manufacturer = info.manufacturer.toLowerCase();
    final brand = info.brand.toLowerCase();
    final display = info.display.toLowerCase();

    final isHuaweiDevice = manufacturer == 'huawei' || brand == 'huawei' || brand == 'honor';
    final hasHarmonyIndicator = display.contains('harmonyos') ||
        info.version.incremental.toLowerCase().contains('harmonyos');

    return isHuaweiDevice || hasHarmonyIndicator;
  }

  static Future<bool> isHuaweiDevice() async {
    if (!Platform.isAndroid) return false;
    final info = await getAndroidInfo();
    final manufacturer = info.manufacturer.toLowerCase();
    final brand = info.brand.toLowerCase();
    return manufacturer == 'huawei' || brand == 'huawei' || brand == 'honor';
  }


  static bool get isWebIOS => isWebIOSImpl();
}
