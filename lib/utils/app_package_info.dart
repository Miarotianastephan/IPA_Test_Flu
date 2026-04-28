import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'app_lang_version_utils.dart';

class AppPackageInfo {
  final String appName;
  final String packageName;
  final String version;
  final String buildNumber;

  const AppPackageInfo({
    required this.appName,
    required this.packageName,
    required this.version,
    required this.buildNumber,
  });
}

class AppPackageInfoUtil {
  static const String webVersion = String.fromEnvironment(
    'APP_VERSION',
    defaultValue: '1.3.3',
  );
  static const String webBuildNumber = String.fromEnvironment(
    'APP_BUILD_NUMBER',
    defaultValue: '',
  );

  static Future<AppPackageInfo> getInfo() async {
    if (kIsWeb) {
      return AppPackageInfo(
        appName: AppLangVersionUtils.getAppName(),
        packageName: AppLangVersionUtils.getAppId(),
        version: webVersion,
        buildNumber: webBuildNumber,
      );
    }

    final info = await PackageInfo.fromPlatform();
    return AppPackageInfo(
      appName: info.appName,
      packageName: info.packageName,
      version: info.version,
      buildNumber: info.buildNumber,
    );
  }

  static Future<String> getCurrentVersion() async {
    final info = await getInfo();
    return info.version;
  }
}
