import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/l10n/app_localizations.dart';
import 'package:live_app/provider/websocket_provider.dart';

import '../models/conversation_user.dart';
import '../models/userinfo.dart';
import '../provider/conversation_provider.dart';
import '../widgets/message_item.dart';
import '../widgets/message_popup_menu_route.dart';

class ChatDetailPage extends ConsumerStatefulWidget {
  final UserInfo user;
  const ChatDetailPage({super.key, required this.user});

  @override
  ConsumerState<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends ConsumerState<ChatDetailPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scroll = ScrollController();
  int _lastMessageCount = 0;
  double _lastMaxScrollExtent = 0;
  int _unreadCount = 0;
  bool _showUnreadIndicator = false;
  bool _initialScrollDone = false;
  final Set<int> _unreadMsgIds = {};

  int? _firstUnreadIndex(List messages) {
    for (int i = 0; i < messages.length; i++) {
      if (_unreadMsgIds.contains(messages[i].id)) return i;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatControllerProvider(widget.user.id));
    final conversation = chatState.conversation;
    final messages = chatState.messages;
    final localisations = AppLocalizations.of(context)!;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;

      final currentLen = messages.length;

      // 判断是否在旧的底部，而不是新的底部（避免新消息扩展列表高度导致判断失败）
      bool wasAtBottom = (_scroll.offset >= _lastMaxScrollExtent - 50);

      if (currentLen != _lastMessageCount) {
        _lastMessageCount = currentLen;

        if (wasAtBottom) {
          _scroll.jumpTo(_scroll.position.maxScrollExtent);
          _unreadMsgIds.clear();
          _unreadCount = 0;
          _showUnreadIndicator = false;

          if (!_initialScrollDone) {
            setState(() {
              _initialScrollDone = true;
            });
          }
        } else {
          final lastMsg = messages.isNotEmpty ? messages.last : null;
          if (lastMsg != null) {
            final isSelfMsg = lastMsg.isSelf;
            if (!isSelfMsg) {
              _unreadMsgIds.add(lastMsg.id);
              _unreadCount = _unreadMsgIds.length;
              _showUnreadIndicator = true;
            }
          }
        }

        setState(() {});
      }

      // 记录本帧新的最大高度，在下一帧用来判断是否在底部
      _lastMaxScrollExtent = _scroll.position.maxScrollExtent;
    });

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          "${widget.user.nickname}",
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          Builder(
            builder: (buttonContext) {
              return IconButton(
                icon: const Icon(Icons.more_horiz, color: Colors.white),
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

                  final result = await Navigator.of(buttonContext).push(
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
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(8),
                          elevation: 6,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                leading: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                title: Text(
                                  localisations.clearHistory,
                                  style: TextStyle(color: Colors.red),
                                ),
                                onTap: () async {
                                  Navigator.pop(buttonContext);

                                  final confirm = await showDialog<bool>(
                                    context: buttonContext,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text(
                                          localisations.confirmClearingHistory,
                                        ),
                                        content: Text(
                                          localisations
                                              .actionCanNotBeUndoneWhenClearingHistory,
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, false),
                                            child: Text(localisations.cancel),
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, true),
                                            child: Text(
                                              localisations.clearHistory,
                                              style: TextStyle(
                                                color: Colors.red,
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  );

                                  if (confirm == true) {
                                    final notifier = ref.read(
                                      chatControllerProvider(
                                        widget.user.id,
                                      ).notifier,
                                    );
                                    notifier.clearHistory();
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );

                  if (!buttonContext.mounted) return;

                  if (result == "clear_history") {
                    final notifier = ref.read(
                      chatControllerProvider(widget.user.id).notifier,
                    );
                    notifier.clearHistory();
                  }
                },
              );
            },
          ),
        ],
      ),

      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 150),
                  opacity: _initialScrollDone ? 1 : 0,
                  child: ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.all(12),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];

                      ConversationUser? senderConvUser;
                      for (final u in conversation!.users) {
                        if (u.userId == msg.senderId) {
                          senderConvUser = u;
                          break;
                        }
                      }

                      final senderUserInfo = senderConvUser?.user;
       
                      final nickname =
                          senderUserInfo?.nickname ??
                          senderUserInfo?.username ??
                          widget.user.username;

                      final firstUnread = _firstUnreadIndex(messages);
                      final isDividerHere =
                          (firstUnread != null && firstUnread == index);

                      if (isDividerHere) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                "${localisations.unreadMessage}· ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}",
                                style: const TextStyle(
                                  color: Colors.redAccent,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            ChatMessageItem(
                              messageId: msg.id,
                              message: msg.content,
                              isSelf: msg.isSelf,
                              createdAt: msg.createdAt,
                              avatarUrl: senderUserInfo?.avatar ?? "",
                              nickname: nickname,
                              userId: senderConvUser?.userId,
                              showFailed: msg.sendFailed,
                              resending: msg.resending,
                              hasRead: msg.isRead,
                              onResend: () {
                                final notifier = ref.read(
                                  chatControllerProvider(
                                    widget.user.id,
                                  ).notifier,
                                );
                                notifier.resendMessage(msg);
                              },
                              onRead: () {
                                final notifier = ref.read(
                                  chatControllerProvider(
                                    widget.user.id,
                                  ).notifier,
                                );
                                notifier.onRead(msg);

                                setState(() {
                                  _unreadMsgIds.remove(msg.id);
                                  _unreadCount = _unreadMsgIds.length;
                                  if (_unreadCount == 0) {
                                    _showUnreadIndicator = false;
                                  }
                                });
                              },
                            ),
                          ],
                        );
                      }

                      return ChatMessageItem(
                        messageId: msg.id,
                        message: msg.content,
                        isSelf: msg.isSelf,
                        createdAt: msg.createdAt,
                        avatarUrl: senderUserInfo?.avatar ?? "",
                        nickname: nickname,
                        userId: senderConvUser?.userId,
                        showFailed: msg.sendFailed,
                        resending: msg.resending,
                        hasRead: msg.isRead,
                        onResend: () {
                          final notifier = ref.read(
                            chatControllerProvider(widget.user.id).notifier,
                          );
                          notifier.resendMessage(msg);
                        },
                        onRead: () {
                          final notifier = ref.read(
                            chatControllerProvider(widget.user.id).notifier,
                          );
                          notifier.onRead(msg);

                          setState(() {
                            _unreadMsgIds.remove(msg.id);
                            _unreadCount = _unreadMsgIds.length;
                            if (_unreadCount == 0) {
                              _showUnreadIndicator = false;
                            }
                          });
                        },
                      );
                    },
                  ),
                ),
                if (_showUnreadIndicator)
                  Positioned(
                    bottom: 10,
                    right: 20,
                    child: GestureDetector(
                      onTap: () {
                        final totalHeight =
                            _scroll.position.maxScrollExtent +
                            _scroll.position.viewportDimension;
                        _scroll.jumpTo(totalHeight);
                        setState(() {
                          _unreadMsgIds.clear();
                          _unreadCount = 0;
                          _showUnreadIndicator = false;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "${localisations.unread} $_unreadCount ${localisations.item}${_unreadCount > 1 ? 's' : ''}",
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    final localisations = AppLocalizations.of(context)!;
    return Container(
      color: const Color(0xFF1A1A1A),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 150),
                  child: TextField(
                    controller: _controller,
                    maxLines: null,
                    cursorColor: Colors.white,
                    style: const TextStyle(color: Colors.white, fontSize: 20),
                    decoration: InputDecoration(
                      hintText: localisations.enterMessage,
                      hintStyle: TextStyle(color: Colors.white54, fontSize: 20),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: _send,
              // onPressed: _send,
            ),
          ],
        ),
      ),
    );
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    final notifier = ref.read(chatControllerProvider(widget.user.id).notifier);
    notifier.sendMessage(text);
    _scroll.jumpTo(_scroll.position.maxScrollExtent);
    _controller.clear();
  }

  void _sendTextMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    final ws = ref.read(webSocketProvider.notifier);
    final watch = ref.watch(currentConversationIdProvider);

    ws.state.manager.sendPrivateMessage(text, widget.user.id, watch!);
    _scroll.jumpTo(_scroll.position.maxScrollExtent);
    _controller.clear();
  }
}
