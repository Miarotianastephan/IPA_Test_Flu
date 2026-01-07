import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/provider/i18n_provider.dart';

import '../models/api_response.dart';
import '../models/page_response.dart';
import '../models/userinfo.dart';
import '../provider/api_provider.dart';
import '../widgets/general_user_tab.dart';
import 'chat_detail_page.dart';

class MutualFollowPage extends ConsumerStatefulWidget {
  const MutualFollowPage({super.key});

  @override
  ConsumerState<MutualFollowPage> createState() => _MutualFollowPageState();
}

class _MutualFollowPageState extends ConsumerState<MutualFollowPage> {
  int page = 1;
  bool loading = false;
  bool isLoaded = false;
  bool finished = false;
  String keyword = "";

  final List<UserInfo> results = [];

  @override
  void initState() {
    super.initState();
    loadData(refresh: true);
  }

  Future<void> loadData({bool refresh = false}) async {
    if (loading) return;

    setState(() => loading = true);

    if (refresh) {
      page = 1;
      finished = false;
    }

    final userService = ref.read(userServiceProvider);

    ApiResponse<PageResponse<UserInfo>> resp = await userService
        .mutualFollowings(page, 20, keyword);

    if (resp.code == 1 && resp.data != null) {
      final list = resp.data!.list;

      if (refresh) results.clear();

      results.addAll(list);
      isLoaded = true;

      if (list.length < 20) {
        finished = true;
      } else {
        page++;
      }
    }

    setState(() => loading = false);
  }

  void onRefresh() => loadData(refresh: true);

  void onLoadMore() {
    if (!finished) loadData(refresh: false);
  }

  @override
  Widget build(BuildContext context) {
    final i18n = ref.read(i18nNotifierProvider.notifier);
    String translate(String key) => i18n.translate(key);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(translate("followEachOther")),
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              cursorColor: Colors.white,
              decoration: InputDecoration(
                hintText: translate("pleaseEnterYourUsernameOrId"),
                prefixIcon: Icon(Icons.search),
                border: InputBorder.none,
                // 移除边框
                enabledBorder: InputBorder.none,
                // 取消可用状态边框
                focusedBorder: InputBorder.none, // 取消聚焦状态边框
              ),
              onChanged: (v) {
                keyword = v.trim();
                onRefresh();
              },
            ),
          ),
          Expanded(
            child: GeneralUserTab(
              loading: loading,
              results: results,
              isLoaded: isLoaded,
              onRefresh: onRefresh,
              onLoadMore: onLoadMore,
              finished: finished,
              onTap: (user) => {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ChatDetailPage(user: user)),
                ),
              },
            ),
          ),
        ],
      ),
    );
  }
}
