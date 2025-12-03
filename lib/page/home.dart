import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/l10n/app_localizations.dart';

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

  late final List<Widget> _pages = [
    HomeTabPage(tkcontroller: tkController),
    VideoTabPage(tkcontroller: tkController),
    ForumTabPage(tkcontroller: tkController),
    const MessageTabPage(),
    // const LiveTabPage(),
    // const LiveTabPage()jung
    const ProfileTabPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(currentThemeProvider);

    return TikTokScaffold(
      controller: tkController,
      hasBottomPadding: false,
      tabBar: BlurWidget(child: _buildMenus(theme.toThemeData(), context)),
      rightPage: Consumer(
        builder: (context, ref, _) {
          final user = ref.watch(currentVideoUserProvider);
          if (user != null) {
            return UserDetailPage(user: user, tkController: tkController);
          } else {
            return const EmptyWidget();
          }
        },
      ),
      page: IndexedStack(index: _currentIndex, children: _pages),
    );
  }

  Widget _buildMenus(ThemeData theme, context) {
    // 配置菜单数据
    final List<Map<String, dynamic>> navItems = [
      {"icon": Icons.home, "label": AppLocalizations.of(context)!.home},
      {"icon": Icons.videocam, "label": AppLocalizations.of(context)!.video},
      {"icon": Icons.groups, "label": AppLocalizations.of(context)!.community},
      {
        "icon": Icons.bubble_chart,
        "label": AppLocalizations.of(context)!.info,
        "key": "message",
      },
      {"icon": Icons.person, "label": AppLocalizations.of(context)!.profile},
    ];

    return SafeArea(
      top: false,
      child: Row(
        children: List.generate(navItems.length, (index) {
          final item = navItems[index];
          final isSelected = index == _currentIndex;

          final unread = ref.watch(totalUnreadCountProvider);

          final isMessageTab = item["key"] == "message";

          return Expanded(
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