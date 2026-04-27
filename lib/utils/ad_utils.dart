import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/models/ad.dart';
import 'package:live_app/models/ad_video.dart' as ad_video;
import 'package:live_app/provider/current_tab_provider.dart';
import 'package:live_app/utils/text_util.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> onAdRedirection(Ad ad, WidgetRef ref) async {
  String targetUrl = ad.targetUrl!;
  if (targetUrl.isEmpty) {
    return;
  }

  if (ad.targetType == AdTargetType.app) {
    if (targetUrl == 'game') {
      final gameIndex = ref.read(gameTabIndexProvider);
      if (gameIndex >= 0) {
        ref.read(switchTabRequestProvider.notifier).state = gameIndex;
      }
    }
  } else {
    targetUrl = targetUrl.trim();

    if (!targetUrl.startsWith(RegExp(r'https?://'))) {
      targetUrl = "https://$targetUrl";
    }

    final uri = Uri.tryParse(targetUrl);

    if (uri != null && uri.hasScheme && uri.host.isNotEmpty) {
      try {
        final success = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );

        if (!success) {}
      } catch (_) {}
    }
  }
}

Future<void> handleAdVideoRedirection({
  required WidgetRef ref,
  required ad_video.AdTargetType? targetType,
  required String? url,
  BuildContext? context,
  bool popToRoot = false,
}) async {
  if (url == null || url.isEmpty) {
    return;
  }

  if (targetType == ad_video.AdTargetType.app) {
    final gameIndex = ref.read(gameTabIndexProvider);
    final validUrl = isValidUrl(url) ? url : null;

    if (context != null && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (validUrl != null) {
        ref.read(pendingGameUrlProvider.notifier).state = validUrl;
      }
      if (gameIndex >= 0) {
        ref.read(switchTabRequestProvider.notifier).state = gameIndex;
      }
    });
  } else {
    // External redirection for deeplink or other types
    var targetUrl = url.trim();

    if (!targetUrl.startsWith(RegExp(r'https?://'))) {
      targetUrl = "https://$targetUrl";
    }

    final uri = Uri.tryParse(targetUrl);

    if (uri != null && uri.hasScheme && uri.host.isNotEmpty) {
      try {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (_) {}
    }
  }
}
