import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../provider/i18n_provider.dart';
import '../models/agent.dart';
import '../models/userinfo.dart';
import '../page/user_detail_page.dart';

void toUserDetailPage({
  required BuildContext context,
  required WidgetRef ref,
  int? userId,
  String? url,
  String? nickname,
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
  );

  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => UserDetailPage(user: basicUserInfo)),
  );
}
