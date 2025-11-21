import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  List<Map<String, dynamic>> _conversations = [
    // Mock data for conversation list
    {
      'userId': 123,
      'userName': '用户123',
      'lastMessage': '你好，这是最后一条消息',
      'lastMessageTime': DateTime.now().subtract(const Duration(minutes: 5)),
    },
    {
      'userId': 456,
      'userName': '用户456',
      'lastMessage': '再见！',
      'lastMessageTime': DateTime.now().subtract(
          const Duration(hours: 1, minutes: 10)),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.people),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const MutualFollowPage(),
              ),
            );
          },
        ),
        actions: [
          Builder(
            builder: (context) {
              return IconButton(
                icon: const Icon(Icons.add),
                onPressed: () async {
                  final RenderBox button = context
                      .findRenderObject() as RenderBox;
                  final RenderBox overlay = Overlay
                      .of(context)
                      .context
                      .findRenderObject() as RenderBox;
                  final Offset position = button.localToGlobal(
                      Offset.zero, ancestor: overlay);
                  final selected = await showMenu<String>(
                    context: context,
                    position: RelativeRect.fromLTRB(
                      position.dx,
                      position.dy + button.size.height,
                      position.dx + button.size.width,
                      position.dy,
                    ),
                    items: [
                      PopupMenuItem<String>(
                        value: 'start_chat',
                        child: ListTile(
                          leading: const Icon(Icons.chat),
                          title: const Text('发起对话'),
                        ),
                      ),
                    ],
                    color: Theme.of(context).colorScheme.onSecondary,
                  );
                  if (selected == 'start_chat') {
                    debugPrint('发起对话');
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const StartChatPage(),
                      ),
                    );
                  }
                },
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: _conversations.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text("系统通知"),
              subtitle: const Text("查看最新的系统消息"),
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
          final convo = _conversations[index - 1];
          final userName = convo['userName'] ?? '用户${convo['userId']}';
          final lastMessage = convo['lastMessage'] ?? '';
          final lastMessageTime = convo['lastMessageTime'] as DateTime?;
          final timeString = lastMessageTime != null
              ? TimeOfDay.fromDateTime(lastMessageTime).format(context)
              : '';
          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatDetailPage(userId: convo['userId']),
                ),
              );
            },
            child: ListTile(
              title: Text(userName),
              subtitle: Text(
                  lastMessage, maxLines: 1, overflow: TextOverflow.ellipsis),
              trailing: Text(timeString),
            ),
          );
        },
      ),
    );
  }
}
