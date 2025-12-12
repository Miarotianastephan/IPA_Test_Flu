import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:media_kit/media_kit.dart';

class PlatformCheck {
  static Future<bool> initMediaKitIfHuawei() async {
    if (!Platform.isAndroid) return false;
    final info = await DeviceInfoPlugin().androidInfo;
    final isHuawei = info.manufacturer.toLowerCase() == "huawei";

    if (isHuawei) {
      MediaKit.ensureInitialized();
    }

    return isHuawei;
  }
}
