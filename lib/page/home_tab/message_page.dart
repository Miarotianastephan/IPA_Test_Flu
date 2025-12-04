import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/l10n/app_localizations.dart';
import 'package:live_app/page/my/my_follow_page.dart';
import 'package:live_app/widgets/empty_widget.dart';

import '../../config/storage_config.dart';
import '../../models/conversation.dart';
import '../../models/conversation_user.dart';
import '../../provider/conversation_list_provider.dart';
import '../../provider/websocket_provider.dart';
import '../../widgets/message_popup_menu_route.dart';
import '../../widgets/system_notification_tile.dart';
import '../chat_detail_page.dart';
import '../mutual_follow_page.dart';
import '../start_chat_page.dart';
import '../system_notification_page.dart';

class MessageTabPage extends ConsumerStatefulWidget {
  const MessageTabPage({super.key});

  @override
  ConsumerState<MessageTabPage> createState() => _MessageTabPageState();
}

class _MessageTabPageState extends ConsumerState<MessageTabPage> {
  int? selfUserId;
  bool _initialLoading = true;

  @override
  void initState() {
    super.initState();

    // 加载本地 self id
    final userRaw = StorageService.instance.getValue<String>("user_info");
    if (userRaw != null) {
      final json = jsonDecode(userRaw);
      selfUserId = json["id"];
    }

    Future.microtask(() => _initLoad());
  }

  Future<void> _initLoad() async {
    await ref
        .read(conversationListProvider.notifier)
        .loadConversationsAndHistory();

    if (mounted) {
      setState(() {
        _initialLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final convState = ref.watch(conversationListProvider);
    final wsState = ref.watch(webSocketProvider);
    final localisations = AppLocalizations.of(context)!;

    final conversations = convState.conversations;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Row(
          children: [
            Icon(
              Icons.link,
              color: wsState.isConnected ? Colors.green : Colors.red,
              size: 25,
            ),
            const SizedBox(width: 10),
            if (wsState.isRetrying)
              SizedBox(
                width: 13,
                height: 13,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                ),
              ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.people),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MutualFollowPage()),
            );
          },
        ),
        actions: [
          Builder(
            builder: (buttonContext) {
              return IconButton(
                icon: const Icon(Icons.add, color: Colors.white),
                onPressed: () async {
                  final RenderBox button =
                      buttonContext.findRenderObject() as RenderBox;
                  final RenderBox overlay =
                      Overlay.of(buttonContext).context.findRenderObject()
                          as RenderBox;

                  final Offset buttonPosition = button.localToGlobal(
                    Offset.zero,
                    ancestor: overlay,
                  );

                  final double rightInset =
                      overlay.size.width -
                      (buttonPosition.dx + button.size.width);

                  final result = await Navigator.of(context).push(
                    MessagePopupMenuRoute(
                      duration: const Duration(milliseconds: 150),
                      position: RelativeRect.fromLTRB(
                        buttonPosition.dx,
                        buttonPosition.dy + button.size.height - 10,
                        rightInset,
                        0,
                      ),
                      child: IntrinsicWidth(
                        child: Material(
                          color: Theme.of(context).colorScheme.onSecondary,
                          borderRadius: BorderRadius.circular(8),
                          elevation: 6,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                leading: const Icon(Icons.chat),
                                title: Text(localisations.startConversation),
                                onTap: () =>
                                    Navigator.pop(context, "start_chat"),
                              ),
                              ListTile(
                                leading: const Icon(Icons.favorite),
                                title: Text(localisations.myFollows),
                                onTap: () =>
                                    Navigator.pop(context, "my_follow"),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );

                  if (!context.mounted) return;

                  if (result == "start_chat") {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const StartChatPage()),
                    );
                  }
                  if (result == "my_follow") {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MyFollowPage(
                          onTap: (user) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChatDetailPage(user: user),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  }
                },
              );
            },
          ),
        ],
      ),

      body: _initialLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : RefreshIndicator(
              color: Colors.white,
              backgroundColor: Colors.black87,
              onRefresh: () async {
                // 下拉刷新：重新请求最新会话列表
                await ref
                    .read(conversationListProvider.notifier)
                    .loadConversationsAndHistory(isRefresh: true);
              },
              child: (conversations.isEmpty)
                  ? EmptyWidget(
                      icon: Icons.chat_bubble_outline_outlined,
                      message: localisations.noConversationFound,
                    )
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(), // 允许下拉
                      padding: const EdgeInsets.all(10),
                      itemCount: conversations.isEmpty
                          ? 2
                          : conversations.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return SystemNotificationTile(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const SystemNotificationPage(),
                                ),
                              );
                            },
                          );
                        }

                        final Conversation c = conversations[index - 1];

                        // Détermine si c'est une conversation de groupe
                        final isGroupChat = c.users.length > 2;

                        ConversationUser? peer;
                        for (final u in c.users) {
                          if (u.userId != selfUserId) {
                            peer = u;
                            break;
                          }
                        }

                        if (!isGroupChat &&
                            (peer == null || peer.user == null)) {
                          return ListTile(
                            leading: CircleAvatar(backgroundColor: Colors.grey),
                            title: Text(
                              localisations.loading,
                              style: TextStyle(color: Colors.white),
                            ),
                            subtitle: Text(
                              "",
                              style: TextStyle(color: Colors.white54),
                            ),
                          );
                        }

                        final lastMsg = c.lastMessage?.content ?? "";
                        String timeStr = "";
                        final lm = c.lastMessage;
                        if (lm != null) {
                          timeStr = TimeOfDay.fromDateTime(
                            lm.createdAt,
                          ).format(context);
                        }

                        String displayTitle;
                        if (isGroupChat) {
                          displayTitle = c.name ?? localisations.groupChat;
                        } else {
                          displayTitle =
                              peer?.user?.nickname ?? "用户${peer?.userId ?? ''}";
                        }

                        String? avatarUrl;
                        if (!isGroupChat && peer?.user?.avatar != null) {
                          avatarUrl = peer!.user!.avatar;
                        }

                        return SystemNotificationTile(
                          title: displayTitle,
                          lastMessage: lastMsg,
                          timeStr: timeStr,
                          unreadCount: c.unreadCount,
                          avatarUrl: avatarUrl,
                          isGroupChat: isGroupChat,
                          onTap: () {
                            if (!isGroupChat && peer?.user == null) return;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ChatDetailPage(user: peer!.user!),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
    );
  }
}
