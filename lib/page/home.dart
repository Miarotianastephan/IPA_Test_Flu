import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/l10n/app_localizations.dart';
import '../provider/cureent_video_user_provider.dart';
import '../widgets/blur_widget.dart';
import '../widgets/empty_widget.dart';
import '../widgets/tiktok_scaffold.dart';
import '/provider/theme_provider.dart';

// 引入子页面
import '/page/home_tab/home_page.dart';
import '/page/home_tab/video_page.dart';
import '/page/home_tab/forum_page.dart';
import '/page/home_tab/profile_page.dart';
import 'home_tab/message_page.dart';
import 'user_detail_page.dart';

extension ColorX on Color {
  Color faded(double alpha) => withValues(alpha: alpha);
}

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
          final user = ref.watch(currentUserProvider);
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
      {"icon": Icons.bubble_chart, "label": AppLocalizations.of(context)!.info},
      // {"icon": Icons.live_tv, "label": "直播"},
      // {"icon": Icons.airplane_ticket_outlined, "label": "空降"},
      {"icon": Icons.person, "label": AppLocalizations.of(context)!.profile},
    ];

    return SafeArea(
      top: false, // 只处理底部
      child: Row(
        children: List.generate(navItems.length, (index) {
          final item = navItems[index];
          final isSelected = index == _currentIndex;
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
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        spacing: 0,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 5), // 间距
          Icon(
            icon,
            size: 30,
            color: isSelected
                ? theme.bottomNavigationBarTheme.selectedItemColor
                : theme.bottomNavigationBarTheme.unselectedItemColor,
          ),
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

//    final isLandscape =
//         MediaQuery.of(context).orientation == Orientation.landscape;
//
//     if (isLandscape) {
//       // 横屏布局（桌面/Web 大屏时也会触发）
//       return Scaffold(
//         body: Row(
//           children: [
//             // 左侧侧边栏
//             NavigationRail(
//               backgroundColor: theme.surface,
//               selectedIndex: _currentIndex,
//               onDestinationSelected: (index) =>
//                   setState(() => _currentIndex = index),
//               labelType: NavigationRailLabelType.all,
//               leading: const Padding(
//                 padding: EdgeInsets.all(16.0),
//                 child: Icon(Icons.arrow_back),
//               ),
//               destinations: const [
//                 NavigationRailDestination(
//                   icon: Icon(Icons.home),
//                   label: Text("首页"),
//                 ),
//                 NavigationRailDestination(
//                   icon: Icon(Icons.video_library),
//                   label: Text("视频"),
//                 ),
//                 NavigationRailDestination(
//                   icon: Icon(Icons.people),
//                   label: Text("帖子"),
//                 ),
//                 NavigationRailDestination(
//                   icon: Icon(Icons.live_tv),
//                   label: Text("直播"),
//                 ),
//                 NavigationRailDestination(
//                   icon: Icon(Icons.person),
//                   label: Text("我的"),
//                 ),
//               ],
//             ),
//
//             // 主内容区域
//             Expanded(
//               child: Column(
//                 children: [
//                   // 顶部栏（Logo + Tab + 搜索框）
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 20,
//                       vertical: 8,
//                     ),
//                     decoration: BoxDecoration(
//                       border: Border(
//                         bottom: BorderSide(color: theme.onSurface.faded(0.1)),
//                       ),
//                     ),
//                     child: Row(
//                       children: [
//                         // Logo
//                         const Text(
//                           "Bogo",
//                           style: TextStyle(
//                             fontSize: 22,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.pink,
//                           ),
//                         ),
//                         const SizedBox(width: 20),
//
//                         // Tab 分类
//                         Expanded(
//                           child: Row(
//                             children: [
//                               _buildTopTab(
//                                 theme.toThemeData(),
//                                 "推荐",
//                                 selected: true,
//                               ),
//                               const SizedBox(width: 16),
//                               _buildTopTab(
//                                 theme.toThemeData(),
//                                 "关注",
//                                 selected: true,
//                               ),
//                               const SizedBox(width: 16),
//                               _buildTopTab(
//                                 theme.toThemeData(),
//                                 "发现",
//                                 selected: true,
//                               ),
//                             ],
//                           ),
//                         ),
//
//                         // 搜索框
//                         SizedBox(
//                           width: 280,
//                           child: TextField(
//                             decoration: InputDecoration(
//                               prefixIcon: const Icon(Icons.search, size: 20),
//                               hintText: "搜索你感兴趣的视频",
//                               isDense: true,
//                               contentPadding: const EdgeInsets.symmetric(
//                                 vertical: 8,
//                               ),
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(8),
//                                 borderSide: BorderSide(
//                                   color: theme.onSurface.faded(0.3),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//
//                   // 页面内容
//                   Expanded(child: _pages[_currentIndex]),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       );
//     }
//  Widget _buildTopTab(ThemeData theme, String text, {bool selected = false}) {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Text(
//           text,
//           style: TextStyle(
//             fontSize: selected
//                 ? theme.bottomNavigationBarTheme.selectedLabelStyle?.fontSize
//                 : theme.bottomNavigationBarTheme.unselectedLabelStyle?.fontSize,
//             color: selected
//                 ? theme.bottomNavigationBarTheme.selectedItemColor
//                 : theme.bottomNavigationBarTheme.unselectedItemColor,
//             fontWeight: selected ? FontWeight.bold : FontWeight.normal,
//           ),
//         ),
//         if (selected)
//           Container(
//             margin: const EdgeInsets.only(top: 2),
//             height: 2,
//             width: 20,
//             color: theme.colorScheme.secondary,
//           ),
//       ],
//     );
//   }
