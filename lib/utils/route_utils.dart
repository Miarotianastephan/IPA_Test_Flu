import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:live_app/l10n/app_localizations.dart';
import '../models/userinfo.dart';
import '../page/chat_detail_page.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/ChatDetailPage': (context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map?;
    debugPrint("args : $args");

    final userEncoded = args?['user'];

    if (userEncoded == null) {
      return Scaffold(
        body: Center(child: Text(AppLocalizations.of(context)!.userMissing)),
      );
    }

    final userJson = Uri.decodeComponent(userEncoded);
    final user = UserInfo.fromJson(jsonDecode(userJson));

    return ChatDetailPage(user: user);
  },
};
