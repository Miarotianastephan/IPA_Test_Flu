import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/models/conversation.dart';
import 'package:live_app/models/group.dart';
import 'package:live_app/page/group_chat_detail_page.dart';
import 'package:live_app/provider/i18n_provider.dart';
import 'package:live_app/utils/toast_util.dart';

import '../models/base_list_state.dart';
import '../provider/api_provider.dart';
import '../provider/search_group_list_provider.dart';

class SearchGroupsPage extends ConsumerStatefulWidget {
  const SearchGroupsPage({super.key});

  @override
  ConsumerState<SearchGroupsPage> createState() => _SearchGroupsPageState();
}

class _SearchGroupsPageState extends ConsumerState<SearchGroupsPage> {
  String _keyword = "";
  bool _groupLoaded = false;
  bool _hasSearched = false; // 是否发起过搜索

  /// 触发搜索（刷新）
  void _fetchGroups() {
    if (_keyword.isEmpty) return;

    setState(() {
      _hasSearched = true; // 标记为已经搜索过
    });

    ref.read(searchGroupListProvider(_keyword).notifier).fetch(refresh: true);
  }

  /// 加载更多
  void _loadMoreGroups() {
    if (_keyword.isEmpty) return;

    final notifier = ref.read(searchGroupListProvider(_keyword).notifier);
    final state = ref.read(searchGroupListProvider(_keyword));

    if (state.loading || state.finished) return;
    notifier.fetch(refresh: false);
  }

  Future<void> _joinGroup(Group group) async {
    final i18n = ref.read(i18nNotifierProvider.notifier);
    String translate(String key) => i18n.translate(key);

    try {
      final messageService = ref.read(messageServiceProvider);
      final response = await messageService.joinGroup(group.conversationId);

      if (!mounted) return;

      if (response.code == 1) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(translate("joinedGroupSuccessfully")),
            backgroundColor: Colors.green,
          ),
        );

        final conversationResponse = await messageService.getMyConversations(
          page: 1,
          limit: 100,
        );

        if (!mounted) return;

        Conversation? conversation;
        if (conversationResponse.code == 1 &&
            conversationResponse.data != null) {
          conversation = conversationResponse.data!.list.firstWhere(
            (c) => c.id == group.conversationId,
            orElse: () => Conversation(
              id: group.conversationId,
              type: 'group',
              name: group.name,
              createdAt: group.createdAt,
              updatedAt: group.updatedAt,
            ),
          );
        } else {
          conversation = Conversation(
            id: group.conversationId,
            type: 'group',
            name: group.name,
            createdAt: group.createdAt,
            updatedAt: group.updatedAt,
          );
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => GroupChatDetailPage(conversation: conversation),
          ),
        );
      } else {
        ToastUtil.error(response.msg);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${translate("error")}: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildGroupList(
    BaseListState<Group> groupState,
    String Function(String) translate,
  ) {
    if (groupState.loading && groupState.list.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (groupState.list.isEmpty && !groupState.loading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[700]),
            const SizedBox(height: 16),
            Text(
              translate("noGroupsFound"),
              style: TextStyle(color: Colors.grey[500], fontSize: 16),
            ),
          ],
        ),
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (scrollInfo.metrics.pixels >=
            scrollInfo.metrics.maxScrollExtent * 0.9) {
          _loadMoreGroups();
        }
        return false;
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: groupState.list.length + (groupState.loading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= groupState.list.length) {
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            );
          }

          final group = groupState.list[index];
          return Card(
            color: Colors.grey[900],
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: ListTile(
              leading: CircleAvatar(
                radius: 25,
                backgroundColor: Colors.grey[800],
                child: group.avatarUrl == null
                    ? const Icon(Icons.group, color: Colors.white)
                    : null,
              ),
              title: Text(
                group.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: group.description != null
                  ? Text(
                      group.description!,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )
                  : Text(
                      group.visibility == 'public'
                          ? translate("publicGroup")
                          : translate("privateGroup"),
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
              trailing: ElevatedButton(
                onPressed: () => _joinGroup(group),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
                child: Text(translate("join")),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const background = Colors.black;
    final i18n = ref.read(i18nNotifierProvider.notifier);
    String translate(String key) => i18n.translate(key);

    // 监听加载结束，更新 _groupLoaded（跟 SearchDetailPage 一样的写法）
    ref.listen(searchGroupListProvider(_keyword), (prev, next) {
      if (prev?.loading == true && next.loading == false) {
        setState(() => _groupLoaded = true);
      }
    });

    final groupState = ref.watch(searchGroupListProvider(_keyword));

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          translate("searchGroups"),
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              cursorColor: Colors.white,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: translate("searchGroupsByName"),
                hintStyle: const TextStyle(color: Colors.white54),
                prefixIcon: const Icon(Icons.search, color: Colors.white70),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
              onChanged: (v) {
                final vTrim = v.trim();
                setState(() {
                  _keyword = vTrim;
                  _groupLoaded = false; // 关键字变了，重新加载
                  if (_keyword.isEmpty) {
                    _hasSearched = false; // 清空关键字时恢复到初始态
                  }
                });

                if (_keyword.isNotEmpty) {
                  _fetchGroups();
                }
              },
            ),
          ),

          Expanded(
            child: !_hasSearched
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.groups, size: 64, color: Colors.grey[700]),
                        const SizedBox(height: 16),
                        Text(
                          translate("searchForPublicGroups"),
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : _buildGroupList(groupState, translate),
          ),
        ],
      ),
    );
  }
}
