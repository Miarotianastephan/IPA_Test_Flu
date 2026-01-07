import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/page/download_page.dart';
import 'package:live_app/page/group_chat_detail_page.dart';
import 'package:live_app/provider/i18n_provider.dart';
import 'package:live_app/widgets/video_screen.dart';

import '../models/userinfo.dart';
import '../page/chat_detail_page.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/ChatDetailPage': (context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map?;
    final userJson = args?['user'];
    if (userJson == null) {
      return Consumer(
        builder: (context, ref, _) {
          final i18n = ref.read(i18nNotifierProvider.notifier);
          return Scaffold(
            body: Center(child: Text(i18n.translate('userMissing'))),
          );
        },
      );
    }
    final user = UserInfo.fromJson(jsonDecode(userJson));
    return ChatDetailPage(user: user);
  },
  '/GroupChatDetailPage': (context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map?;
    final conversationIdValue = args?['conversationId'];

    int? conversationId;
    if (conversationIdValue is int) {
      conversationId = conversationIdValue;
    } else if (conversationIdValue is String) {
      conversationId = int.tryParse(conversationIdValue);
    }

    if (conversationId == null || conversationId == 0) {
      return Consumer(
        builder: (context, ref, _) {
          final i18n = ref.read(i18nNotifierProvider.notifier);
          return Scaffold(
            body: Center(child: Text(i18n.translate('conversationMissing'))),
          );
        },
      );
    }
    return GroupChatDetailPage(conversationId: conversationId);
  },
  '/DownloadsPage': (context) => const DownloadsPage(),
  '/video': (context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map?;
    final path = args?['path'] as String?;
    if (path == null) {
      return const Scaffold(body: Center(child: Text("Chemin vidéo manquant")));
    }
    return VideoScreen(localPath: path);
  },
};
