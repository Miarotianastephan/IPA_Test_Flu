import 'package:flutter/material.dart';
import 'package:live_app/l10n/app_localizations.dart';

import '../page/search_page.dart';

class TikTokHeader extends StatelessWidget {
  final VoidCallback? onVideoCallPressed;
  final VoidCallback? onSearchPressed;
  final TabController controller;

  const TikTokHeader({
    super.key,
    required this.controller,
    this.onVideoCallPressed,
    this.onSearchPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 8), // 两边留点空
      child: Row(
        children: [
          // 左边按钮：发布视频
          IconButton(
            onPressed: onVideoCallPressed ?? () {},
            icon: Icon(Icons.video_call, color: Colors.white),
          ),

          // 中间 TabBar，Expanded 保证占满剩余空间
          Expanded(
            child: TabBar(
              controller: controller,
              indicator: const BoxDecoration(),
              // 隐藏下划线
              labelColor: Colors.white,
              labelStyle: TextStyle(
                fontSize:
                    Localizations.localeOf(context).languageCode == 'en' ||
                        Localizations.localeOf(context).languageCode == 'es'
                    ? 10
                    : 16,
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelStyle: TextStyle(
                fontSize:
                    Localizations.localeOf(context).languageCode == 'en' ||
                        Localizations.localeOf(context).languageCode == 'es'
                    ? 10
                    : 16,
                color: Color.fromRGBO(255, 255, 255, 0.8),
              ),
              tabs: [
                Tab(text: AppLocalizations.of(context)!.follow),
                Tab(text: AppLocalizations.of(context)!.recommend),
                Tab(text: AppLocalizations.of(context)!.verify),
                Tab(text: AppLocalizations.of(context)!.featured),
              ],
            ),
          ),

          // 右边按钮：搜索
          IconButton(
            onPressed:
                onSearchPressed ??
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SearchPage()),
                  );
                },
            icon: Icon(Icons.search, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
