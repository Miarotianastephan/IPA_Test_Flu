import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/l10n/app_localizations.dart';
import 'package:live_app/provider/app_config_provider.dart';

import '/page/home_tab/forum_page.dart';
// 引入子页面
import '/page/home_tab/home_page.dart';
import '/page/home_tab/profile_page.dart';
import '/page/home_tab/video_page.dart';
import '/provider/theme_provider.dart';
import '../provider/conversation_list_provider.dart';
import '../provider/cureent_video_user_provider.dart';
import '../widgets/blur_widget.dart';
import '../widgets/empty_widget.dart';
import '../widgets/tiktok_scaffold.dart';
import 'home_tab/message_page.dart';
import 'user_detail_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _currentIndex = 0;
  TikTokScaffoldController tkController = TikTokScaffoldController();
  late List<Widget> _pages;
  late int trueCount;
  late int falseCount;
  @override
  void initState() {
    super.initState();

    final config = ref.read(appConfigProvider).data;

    _pages = [
      if (config?['enable_video'] == true)
        HomeTabPage(tkcontroller: tkController),
      if (config?['enable_video'] == true)
        VideoTabPage(tkcontroller: tkController),
      if (config?['enable_community'] == true)
        ForumTabPage(tkcontroller: tkController),
      if (config?['chat_enable'] == true) const MessageTabPage(),
      // const LiveTabPage(),
      // const LiveTabPage()jung
      const ProfileTabPage(),
    ];
    final flags = [
      config?['enable_video'] == true,
      config?['enable_community'] == true,
      config?['chat_enable'] == true,
    ];

    trueCount = flags.where((f) => f).length;
    falseCount = flags.where((f) => !f).length;
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(currentThemeProvider);
    final appConfigState = ref.watch(appConfigProvider);
    if (appConfigState.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (appConfigState.error != null) {
      return Center(child: Text("Erreur: ${appConfigState.error}"));
    }

    final config = appConfigState.data;
    return TikTokScaffold(
      controller: tkController,
      hasBottomPadding: false,
      tabBar: BlurWidget(
        child: _buildMenus(theme.toThemeData(), context, config),
      ),
      rightPage: Consumer(
        builder: (context, ref, _) {
          final user = ref.watch(currentVideoUserProvider);
          if (user != null) {
            return UserDetailPage(
              user: user,
              cover: user.cover,
              tkController: tkController,
            );
          } else {
            return const EmptyWidget();
          }
        },
      ),
      page: IndexedStack(index: _currentIndex, children: _pages),
    );
  }

  Widget _buildMenus(ThemeData theme, context, Map<String, dynamic>? config) {
    List<Map<String, dynamic>> navItems;
    if (falseCount == 3) {
      navItems = [];
    } else {
      // 配置菜单数据
      navItems = [
        if (config?['enable_video'] == true)
          {"icon": Icons.home, "label": AppLocalizations.of(context)!.home},
        if (config?['enable_video'] == true)
          {
            "icon": Icons.videocam,
            "label": AppLocalizations.of(context)!.video,
          },
        if (config?['enable_community'] == true)
          {
            "icon": Icons.groups,
            "label": AppLocalizations.of(context)!.community,
          },
        if (config?['chat_enable'] == true)
          {
            "icon": Icons.bubble_chart,
            "label": AppLocalizations.of(context)!.info,
            "key": "message",
          },
        {"icon": Icons.person, "label": AppLocalizations.of(context)!.profile},
      ];
    }

    final unread = ref.watch(totalUnreadCountProvider);

    return SafeArea(
      top: false,
      child: Row(
        children: List.generate(navItems.length, (index) {
          final item = navItems[index];
          final isSelected = index == _currentIndex;
          final isMessageTab = item["key"] == "message";

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: _buildItem(
                context,
                theme,
                item["icon"],
                item["label"],
                isSelected,
                onTap: () {
                  setState(() => _currentIndex = index);
                  tkController.enableGesture = (index == 0);
                },
                showBadge: isMessageTab && unread > 0,
                badgeCount: unread,
              ),
            ),
          );
        }),
      ),
    );
  }

  double? _getFontSize(BuildContext context, bool isSelected, theme) {
    final lang = Localizations.localeOf(context).languageCode;
    final baseSize = isSelected
        ? theme.bottomNavigationBarTheme.selectedLabelStyle?.fontSize
        : theme.bottomNavigationBarTheme.unselectedLabelStyle?.fontSize;

    if (lang == 'en' || lang == 'es') {
      return (baseSize ?? 12) - 2;
    }
    return baseSize;
  }

  Widget _buildItem(
    context,
    ThemeData theme,
    IconData icon,
    String label,
    bool isSelected, {
    Function()? onTap,
    bool showBadge = false,
    int badgeCount = 0,
  }) {
    final iconWidget = Icon(
      icon,
      size: 30,
      color: isSelected
          ? theme.bottomNavigationBarTheme.selectedItemColor
          : theme.bottomNavigationBarTheme.unselectedItemColor,
    );

    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 6),
          showBadge
              ? Badge.count(
                  count: badgeCount,
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                  alignment: Alignment.topRight,
                  offset: const Offset(10, -6),
                  child: iconWidget,
                )
              : iconWidget,
          Text(
            label,
            style: TextStyle(
              fontSize: _getFontSize(context, isSelected, theme),
              color: isSelected
                  ? theme.bottomNavigationBarTheme.selectedItemColor
                  : theme.bottomNavigationBarTheme.unselectedItemColor,
            ),
          ),
        ],
      ),
    );
  }
}
