import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../config/storage_config.dart';

class AgentTracking {
  static const _agentCodeKey = 'agent_code';
  static const _trackingQueryParamsKey = 'tracking_query_params';

  static Future<void> captureTrackingParamsFromCurrentUri() async {
    if (!kIsWeb) return;
    await captureTrackingParamsFromUri(Uri.base);
  }

  static Future<void> captureTrackingParamsFromUri(Uri uri) async {
    final queryParameters = uri.queryParameters;
    if (queryParameters.isEmpty) return;

    await StorageService.instance.setValue<String>(
      _trackingQueryParamsKey,
      jsonEncode(queryParameters),
    );

    final code = queryParameters['code'];
    if (code != null && code.isNotEmpty) {
      await StorageService.instance.setValue<String>(_agentCodeKey, code);
    }
  }

  static Map<String, dynamic>? getStoredTrackingQueryParams() {
    final raw = StorageService.instance.getValue<String>(
      _trackingQueryParamsKey,
    );
    if (raw == null || raw.isEmpty) return null;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      if (decoded is Map) {
        return decoded.map((key, value) => MapEntry(key.toString(), value));
      }
    } catch (_) {
      return null;
    }

    return null;
  }

  static String? getStoredAgentCode() {
    final trackingParams = getStoredTrackingQueryParams();
    final code = trackingParams?['code'];
    if (code is String && code.isNotEmpty) {
      return code;
    }
    return StorageService.instance.getValue<String>(_agentCodeKey);
  }
}
