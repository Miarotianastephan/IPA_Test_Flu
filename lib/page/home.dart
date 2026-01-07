import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/page/base_home.dart';
import 'package:live_app/page/home_tab/forum_page.dart';
import 'package:live_app/page/home_tab/video_page.dart';
// 引入子页面
import '/page/home_tab/home_page.dart';
import '/page/home_tab/profile_page.dart';

import '../provider/cureent_video_user_provider.dart';

import '../widgets/empty_widget.dart';
import '../widgets/tiktok_scaffold.dart';
import 'home_tab/message_page.dart';
import 'user_detail_page.dart';

class HomePage extends StatelessWidget {
  final Map<String, dynamic>? config;
  const HomePage({super.key, this.config});

  @override
  Widget build(BuildContext context) {
    final tkController = TikTokScaffoldController();
    final pages = [
      if (config?['enable_video'] == true)
        HomeTabPage(tkcontroller: tkController),
      if (config?['enable_video'] == true)
        VideoTabPage(tkcontroller: tkController),
      if (config?['enable_community'] == true)
        ForumTabPage(tkcontroller: tkController),
      if (config?['chat_enable'] == true) MessageTabPage(appConfig: config),
      const ProfileTabPage(origin: ProfileOrigin.xo),
    ];
    final flags = [
      config?['enable_video'] == true,
      config?['enable_community'] == true,
      config?['chat_enable'] == true,
    ];

    final falseCount = flags.where((f) => !f).length;
    List<Map<String, dynamic>> navItems;
    if (falseCount == 3) {
      navItems = [];
    } else {
      navItems = [
        if (config?['enable_video'] == true)
          {"icon": Icons.home, "label": "Home"},
        if (config?['enable_video'] == true)
          {"icon": Icons.videocam, "label": "Video"},
        if (config?['enable_community'] == true)
          {"icon": Icons.groups, "label": "Community"},
        if (config?['chat_enable'] == true)
          {"icon": Icons.bubble_chart, "label": "Message", "key": "message"},
        {"icon": Icons.person, "label": "Profile"},
      ];
    }
    return BaseHome(
      pages: pages,
      navItems: navItems,
      controller: tkController,
      rightPage: Consumer(
        builder: (context, ref, _) {
          final user = ref.watch(currentVideoUserProvider);
          return user != null
              ? UserDetailPage(
                  user: user,
                  cover: user.cover,
                  tkController: tkController,
                )
              : const EmptyWidget();
        },
      ),
    );
  }
}
