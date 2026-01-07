import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/page/maintenance_page.dart';
import 'package:live_app/page/my/my_follow_page.dart';
import 'package:live_app/provider/i18n_provider.dart';
import 'package:live_app/widgets/conversation_tile.dart';
import 'package:live_app/widgets/empty_widget.dart';
import 'package:live_app/widgets/message/message_popup_menu_route.dart';

import '../../config/storage_config.dart';
import '../../models/conversation.dart';
import '../../models/conversation_user.dart';
import '../../provider/conversation_list_provider.dart';
import '../../provider/current_user_provider.dart';
import '../../provider/system_notification_provider.dart';
import '../../provider/websocket_provider.dart';
import '../../widgets/system_notification_tile.dart';
import '../chat_detail_page.dart';
import '../create_group_page.dart';
import '../group_chat_detail_page.dart';
import '../mutual_follow_page.dart';
import '../search_groups_page.dart';
import '../start_chat_page.dart';
import '../system_notification_page.dart';

class MessageTabPage extends ConsumerStatefulWidget {
  final Map<String, dynamic>? appConfig;

  const MessageTabPage({super.key, this.appConfig});

  @override
  ConsumerState<MessageTabPage> createState() => _MessageTabPageState();
}

class _MessageTabPageState extends ConsumerState<MessageTabPage> {
  int? selfUserId;

  @override
  void initState() {
    super.initState();

    // 加载本地 self id
    final userRaw = StorageService.instance.getValue<String>("user_info");
    if (userRaw != null) {
      final json = jsonDecode(userRaw);
      selfUserId = json["id"];
    }

    Future.microtask(() {
      _initLoad();
    });
  }

  Future<void> _initLoad() async {
    await ref
        .read(conversationListProvider.notifier)
        .loadConversationsAndHistory();

    await ref.read(systemNotificationProvider.notifier).loadNotifications();

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final i18n = ref.read(i18nNotifierProvider.notifier);
    String translate(String key) => i18n.translate(key);
    final config = widget.appConfig;
    final currentUser = ref.watch(currentUserProvider);
    if (currentUser == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    final convState = ref.watch(conversationListProvider);
    final wsState = ref.watch(webSocketProvider);

    final conversationsState = convState.conversations;
    final conversations = conversationsState.where((c) {
      if (c.type == 'single') {
        return c.lastMessageId != 0;
      }
      return true;
    }).toList();

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
                                title: Text(translate("startConversation")),
                                onTap: () =>
                                    Navigator.pop(context, "start_chat"),
                              ),
                              ListTile(
                                leading: const Icon(Icons.favorite),
                                title: Text(translate("myFollows")),
                                onTap: () =>
                                    Navigator.pop(context, "my_follow"),
                              ),
                              ListTile(
                                leading: const Icon(Icons.search),
                                title: Text(translate("searchGroups")),
                                onTap: () =>
                                    Navigator.pop(context, "search_groups"),
                              ),
                              ListTile(
                                leading: const Icon(Icons.people),
                                title: Text(translate("createGroup")),
                                onTap: () =>
                                    Navigator.pop(context, "create_group"),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );

                  if (!context.mounted) return;

                  if (result == "start_chat") {
                    config?['chat_enable_dm'] == true
                        ? Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const StartChatPage(),
                            ),
                          )
                        : Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const MaintenancePage(isChatPage: true),
                            ),
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
                  if (result == "search_groups") {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SearchGroupsPage(),
                      ),
                    );
                  }
                  if (result == "create_group") {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CreateGroupPage(),
                      ),
                    );
                  }
                },
              );
            },
          ),
        ],
      ),

      body: RefreshIndicator(
        color: Colors.white,
        backgroundColor: Colors.black87,
        onRefresh: () async {
          // 下拉刷新：重新请求最新会话列表
          await ref
              .read(conversationListProvider.notifier)
              .loadConversationsAndHistory(isRefresh: true);
        },
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(), // 允许下拉
          padding: const EdgeInsets.all(10),
          itemCount: conversations.isEmpty ? 2 : conversations.length + 2,
          itemBuilder: (context, index) {
            if (index == 0) {
              final notificationState = ref.watch(systemNotificationProvider);
              final lastNotification = notificationState.lastNotification;
              return SystemNotificationTile(
                title: lastNotification?.title,
                unreadCount: notificationState.unreadCount > 0
                    ? notificationState.unreadCount
                    : null,
                lastNotification: lastNotification?.content,
                timeStr: lastNotification != null
                    ? TimeOfDay.fromDateTime(
                        lastNotification.createdAt.toLocal(),
                      ).format(context)
                    : null,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SystemNotificationPage(),
                    ),
                  );
                },
              );
            }

            if (conversations.isEmpty) {
              return SizedBox(
                height: MediaQuery.of(context).size.height - 300,
                child: EmptyWidget(
                  icon: Icons.chat_bubble_outline_outlined,
                  message: translate("noConversationFound"),
                ),
              );
            }

            if (index == conversations.length + 1) {
              return const SizedBox(height: kToolbarHeight);
            }

            final Conversation c = conversations[index - 1];

            final uniqueUsers = c.users.where((item) {
              final currentId = item.user?.id;
              return currentId != null &&
                  c.users.indexWhere((i) => i.user?.id == currentId) ==
                      c.users.indexOf(item);
            }).toList();
            final isGroupChat = c.type == 'group';

            ConversationUser? peer;
            for (final u in c.users) {
              if (u.userId != selfUserId) {
                peer = u;
                break;
              }
            }

            if (!isGroupChat && (peer == null || peer.user == null)) {
              return ListTile(
                leading: CircleAvatar(backgroundColor: Colors.grey),
                title: Text(
                  translate("loading"),
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: Text("", style: TextStyle(color: Colors.white54)),
              );
            }

            final lastMsg = c.lastMessage?.content ?? "";
            String timeStr = "";
            final lm = c.lastMessage;
            if (lm != null) {
              final localTime = lm.createdAt.toLocal();
              timeStr = TimeOfDay.fromDateTime(localTime).format(context);
            }

            String displayTitle;
            if (isGroupChat) {
              displayTitle = c.name ?? translate("groupChat");
            } else {
              displayTitle = peer?.user?.nickname ?? "用户${peer?.userId ?? ''}";
            }

            String? avatarUrl;
            if (!isGroupChat && peer?.user?.avatar != null) {
              avatarUrl = peer!.user!.avatar;
            }

            String msgType = "text";
            String content = "";

            if (lastMsg.isNotEmpty) {
              try {
                Map<String, dynamic> msgTojsn = jsonDecode(lastMsg);
                msgType = msgTojsn['type'] ?? "text";
                content = msgTojsn['content'] ?? "";
              } catch (e) {
                content = lastMsg;
              }
            }

            return ConversationTile(
              title: displayTitle,
              lastMessage: content.isEmpty && isGroupChat
                  ? "Welcome to this new group"
                  : (msgType == "text" ? content : msgType),
              timeStr: timeStr,
              unreadCount: c.unreadCount,
              avatarUrl: avatarUrl,
              isGroupChat: isGroupChat,
              nickname: isGroupChat
                  ? displayTitle
                  : c.users
                      .firstWhere(
                        (element) => element.userId != selfUserId,
                        orElse: () => ConversationUser(
                          userId: 0,
                          id: 0,
                          conversationId: 0,
                          joinedAt: DateTime.now(),
                        ),
                      )
                      .user
                      ?.nickname,
              onTap: () {
                if (isGroupChat) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => GroupChatDetailPage(conversation: c),
                    ),
                  );
                } else {
                  if (peer?.user == null) return;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatDetailPage(user: peer!.user!),
                    ),
                  );
                }
              },
            );
          },
        ),
      ),
    );
  }
}
