import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/provider/my_user_provider.dart';
import 'package:live_app/widgets/vip_card_list.dart';

import '../provider/i18n_provider.dart';
import '../models/agent.dart';
import '../models/userinfo.dart';
import '../models/vip.dart';
import '../page/user_detail_page.dart';

enum Permission {
  downloadResources('can_download_resources'),
  accessLongFree('can_access_long_free'),
  accessShortFree('can_access_short_free'),
  accessPostsFree('can_access_posts_free'),
  accessImFree('can_access_im_free'),
  accessAudioFree('can_access_audio_free'),
  accessMangaFree('can_access_manga_free'),
  accessNovelFree('can_access_novel_free');

  final String code;
  const Permission(this.code);
}

void toUserDetailPage({
  required BuildContext context,
  required WidgetRef ref,
  String? userId,
  String? url,
  String? nickname,
  Vip? vip,
}) {
  // 否则，从参数构建一个基础的 UserInfo
  if (userId == null) {
    debugPrint("头像被点击: $url");
    return;
  }

  final i18n = ref.read(i18nNotifierProvider.notifier);
  final basicUserInfo = UserInfo(
    id: userId,
    displayId: userId,
    username: null,
    credential: '',
    isVisitor: false,
    isBindPass: false,
    agentId: 0,
    agent: Agent(
      id: 0,
      displayId: 0,
      username: '',
      role: '',
      code: '',
      parentId: 0,
      createdAt: DateTime.now(),
    ),
    inviteCode: '',
    level: 0,
    nextExp: 0,
    levelName: '',
    avatar: url,
    nickname: nickname ?? i18n.translate('user'),
    vip: vip,
  );

  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => UserDetailPage(user: basicUserInfo)),
  );
}

String _getDefaultMessage(
  String Function(String) translate,
  Permission permission,
) {
  return switch (permission) {
    Permission.downloadResources => translate('downloadResourcesDenied'),
    Permission.accessLongFree => translate('watchLongVideosFreeDenied'),
    Permission.accessShortFree => translate('watchShortVideosUnlimitedDenied'),
    Permission.accessPostsFree => translate('viewPostsFreeDenied'),
    Permission.accessImFree => translate('useIMFreeDenied'),
    Permission.accessAudioFree => translate('accessAudioFreeDenied'),
    Permission.accessMangaFree => translate('accessMangaFreeDenied'),
    Permission.accessNovelFree => translate('accessNovelFreeDenied'),
  };
}

extension PermissionExtension on WidgetRef {
  bool hasPermission(Permission permission) {
    final myUser = read(userProvider).user;
    final permissions = myUser?.vip?.rights.map((e) => e.code).toList();
    return permissions?.contains(permission.code) ?? false;
  }

  void checkPermission(
    BuildContext context,
    Permission permission,
    VoidCallback action, [
    String? message,
  ]) {
    final i18n = read(i18nNotifierProvider.notifier);
    String translate(String key) => i18n.translate(key);

    if (hasPermission(permission)) {
      action();
    } else {
      showPermissionDeniedDialog(
        context,
        this,
        permission,
        message ?? _getDefaultMessage(translate, permission),
      );
    }
  }
}

void showPermissionDeniedDialog(
  BuildContext context,
  WidgetRef ref,
  Permission? permission, [
  String? message,
]) {
  final theme = Theme.of(context);
  final i18n = ref.read(i18nNotifierProvider.notifier);
  String translate(String key) => i18n.translate(key);

  showDialog(
    context: context,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      backgroundColor: theme.cardColor,
      elevation: 10,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.onPrimary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.lock_outline,
                size: 40,
                color: theme.colorScheme.onPrimary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              i18n.translate('permissionDenied'),
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message ??
                  (permission != null
                      ? _getDefaultMessage(translate, permission)
                      : i18n.translate('upgradeToAccess')),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodySmall?.color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            VipCardList(maxHeight: 250, dialogContext: context),
          ],
        ),
      ),
    ),
  );
}

int getDeviceId() {
  if (kIsWeb) return 4; // PWA
  if (Platform.isAndroid) return 1;
  if (Platform.isIOS) return 2;
  return 3; // UNKNOWN
}
