import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

enum DeviceType { android, ios, h5 }

DeviceType getCurrentDeviceType() {
  if (kIsWeb) {
    return DeviceType.h5;
  } else if (Platform.isAndroid) {
    return DeviceType.android;
  } else if (Platform.isIOS) {
    return DeviceType.ios;
  }
  return DeviceType.h5;
}
