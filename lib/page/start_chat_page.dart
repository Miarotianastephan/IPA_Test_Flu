import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/provider/i18n_provider.dart';
import 'package:live_app/widgets/empty_widget.dart';
import 'package:live_app/widgets/html_text_field.dart';

import '../models/userinfo.dart';
import '../provider/conversation_list_provider.dart';
import '../provider/search_user_list_provider.dart';
import '../widgets/general_user_tab.dart';
import 'chat_detail_page.dart';

class StartChatPage extends ConsumerStatefulWidget {
  const StartChatPage({super.key});

  @override
  ConsumerState<StartChatPage> createState() => _StartChatPageState();
}

class _StartChatPageState extends ConsumerState<StartChatPage> {
  String _keyword = "";
  bool _userLoaded = false;
  bool _hasSearched = false; // 是否发起过搜索

  /// 触发搜索（刷新）
  void _fetchUsers() {
    if (_keyword.isEmpty) return;

    setState(() {
      _hasSearched = true; // 标记为已经搜索过
    });

    ref.read(searchUserListProvider(_keyword).notifier).fetch(refresh: true);
  }

  /// 加载更多
  void _loadMoreUsers() {
    if (_keyword.isEmpty) return;

    final notifier = ref.read(searchUserListProvider(_keyword).notifier);
    final state = ref.read(searchUserListProvider(_keyword));

    if (state.loading || state.finished) return;
    notifier.fetch(refresh: false);
  }

  @override
  Widget build(BuildContext context) {
    const background = Colors.black;
    final i18n = ref.read(i18nNotifierProvider.notifier);
    String translate(String key) => i18n.translate(key);

    // 监听加载结束，更新 _userLoaded（跟 SearchDetailPage 一样的写法）
    ref.listen(searchUserListProvider(_keyword), (prev, next) {
      if (prev?.loading == true && next.loading == false) {
        setState(() => _userLoaded = true);
      }
    });

    final userState = ref.watch(searchUserListProvider(_keyword));

    return PopScope(
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          ref
              .read(conversationListProvider.notifier)
              .loadConversationsAndHistory(isRefresh: true);
        }
      },
      child: Scaffold(
        backgroundColor: background,
        appBar: AppBar(
          backgroundColor: background,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          title: Text(
            translate("startConversation"),
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: HtmlTextField(
                cursorColor: Colors.white,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: translate("pleaseEnterYourUsernameOrId"),
                  hintStyle: TextStyle(color: Colors.white54),
                  prefixIcon: Icon(Icons.search, color: Colors.white70),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
                onChanged: (v) {
                  final vTrim = v.trim();
                  setState(() {
                    _keyword = vTrim;
                    _userLoaded = false; // 关键字变了，重新加载
                    if (_keyword.isEmpty) {
                      _hasSearched = false; // 清空关键字时恢复到初始态
                    }
                  });

                  if (_keyword.isNotEmpty) {
                    _fetchUsers();
                  }
                },
              ),
            ),

            Expanded(
              child: !_hasSearched
                  ? Center(
                      child: EmptyWidget(
                        message: ref
                            .read(i18nNotifierProvider.notifier)
                            .translate("searchUsernameOrIdPlaceholder"),
                      ),
                    )
                  // 已经搜索过时显示列表
                  : GeneralUserTab(
                      finished: userState.finished,
                      onRefresh: _fetchUsers,
                      onLoadMore: _loadMoreUsers,
                      isLoaded: _userLoaded,
                      loading: userState.loading,
                      results: userState.list,
                      // 点击用户 -> 进入聊天页
                      onTap: (UserInfo user) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatDetailPage(user: user),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
