import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/l10n/app_localizations.dart';
import 'package:live_app/provider/websocket_provider.dart';
import 'package:live_app/widgets/message/action_panel.dart';
import 'package:live_app/widgets/message/emoji_text_input.dart';
import 'package:live_app/widgets/message/message_item_gif.dart';

import '../models/conversation_user.dart';
import '../models/userinfo.dart';
import '../provider/conversation_provider.dart';
import '../provider/emoji_provider.dart';
import '../widgets/message_item.dart';
import '../widgets/message_popup_menu_route.dart';

class ChatDetailPage extends ConsumerStatefulWidget {
  final UserInfo user;
  const ChatDetailPage({super.key, required this.user});

  @override
  ConsumerState<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends ConsumerState<ChatDetailPage> {
  final EmojiTextController _controller = EmojiTextController();
  final ScrollController _scroll = ScrollController();
  int _lastMessageCount = 0;
  double _lastMaxScrollExtent = 0;
  int _unreadCount = 0;
  bool _showUnreadIndicator = false;
  bool _initialScrollDone = false;
  final Set<int> _unreadMsgIds = {};
  double pannelHeight = 0.0;

  final FocusNode _focusNode = FocusNode();

  bool _showActionPanel = false;

  int? _firstUnreadIndex(List messages) {
    for (int i = 0; i < messages.length; i++) {
      if (_unreadMsgIds.contains(messages[i].id)) return i;
    }
    return null;
  }

  void _toggleActionPanel() {
    setState(() {
      _showActionPanel = !_showActionPanel;
    });

    Future.delayed(const Duration(milliseconds: 50), () {
      if (_showActionPanel) {
        _focusNode.unfocus();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          setState(() {});
        });
      } else {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      if (ref.read(emojiProvider(1)).emojis.isEmpty) {
        ref.read(emojiProvider(1).notifier).loadEmojis();
      }
      if (ref.read(emojiProvider(2)).emojis.isEmpty) {
        ref.read(emojiProvider(2).notifier).loadEmojis();
      }
    });

    _focusNode.addListener(() {
      if (_focusNode.hasFocus && _showActionPanel) {
        setState(() {
          _showActionPanel = false;
        });
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _scroll.dispose();
    super.dispose();
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

    return GestureDetector(
      onTap: () {
        if (_focusNode.hasFocus || _showActionPanel) {
          _focusNode.unfocus();
          if (_showActionPanel) {
            setState(() {
              _showActionPanel = false;
            });
          }
        }
      },
      behavior: HitTestBehavior.translucent,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
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
                                            localisations
                                                .confirmClearingHistory,
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

                        Map<String, dynamic> msgTojsn = jsonDecode(msg.content);
                        final msgType = msgTojsn['type'];
                        final content = msgTojsn['content'];

                        if (isDividerHere) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                child: Text(
                                  "${localisations.unreadMessage}· ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}",
                                  style: const TextStyle(
                                    color: Colors.redAccent,
                                    fontSize: 14,
                                  ),
                                ),
                              ),

                              if (msgType == 'text')
                                ChatMessageItem(
                                  messageId: msg.id,
                                  message: content,
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
                                )
                              else if (msgType == 'gif')
                                ChatGifMessageItem(
                                  messageId: msg.id,
                                  gifUrl: content,
                                  isSelf: msg.isSelf,
                                  avatarUrl: senderUserInfo?.avatar ?? "",
                                  nickname: nickname,
                                  userId: senderConvUser?.userId,
                                  createdAt: msg.createdAt,
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

                        return msgType == 'gif'
                            ? ChatGifMessageItem(
                                messageId: msg.id,
                                gifUrl: content,
                                isSelf: msg.isSelf,
                                avatarUrl: senderUserInfo?.avatar ?? "",
                                nickname: nickname,
                                userId: senderConvUser?.userId,
                                createdAt: msg.createdAt,
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
                              )
                            : ChatMessageItem(
                                messageId: msg.id,
                                message: content,
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
            _buildKeyboardOrPanelSpace(),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    final localisations = AppLocalizations.of(context)!;

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        color: const Color(0xFF1A1A1A),
        child: Row(
          children: [
            _buildIconButton(Icons.emoji_emotions, onTap: _toggleActionPanel),

            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: EmojiTextField(
                  controller: _controller,
                  sharedFocusNode: _focusNode,
                  hintText: localisations.enterMessage,
                  style: const TextStyle(color: Colors.white, fontSize: 18.0),
                  hintStyle: const TextStyle(color: Colors.white54),
                ),
              ),
            ),

            _buildIconButton(Icons.send, onTap: _send),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton(
    IconData icon, {
    Color color = Colors.white70,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: () {
          if (onTap != null) onTap();
        },
        child: Container(
          width: 38,
          height: 38,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.transparent,
          ),
          child: Column(children: [Icon(icon, size: 30, color: color)]),
        ),
      ),
    );
  }

  Widget _buildKeyboardOrPanelSpace() {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final panelHeight = keyboardHeight > 0
        ? keyboardHeight.ceilToDouble()
        : 360;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      height: _showActionPanel
          ? panelHeight.toDouble()
          : keyboardHeight.ceilToDouble(),
      child: _showActionPanel
          ? GestureDetector(
              onTap: () {},
              behavior: HitTestBehavior.opaque,
              child: ActionPanel(
                onEmojiSelected: _onEmojiSelected,
                onGifSelected: _onGifSelected,
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  void _send({String? message}) {
    String textToSend;

    if (message != null) {
      textToSend = '{"type": "gif", "content": "$message"}';
    } else {
      textToSend =
          '{"type": "text", "content": "${_controller.getMessageText().trim()}"}';
    }

    final notifier = ref.read(chatControllerProvider(widget.user.id).notifier);
    notifier.sendMessage(textToSend);
    _scroll.jumpTo(_scroll.position.maxScrollExtent);
    _controller.clear();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
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

  void _onEmojiSelected(String emojiKey, String svgUrl) {
    _controller.insertEmoji(emojiKey, svgUrl);
  }

  void _onGifSelected(String gifUrl) {
    final currentText = _controller.text;
    final selection = _controller.selection;

    final insertPosition = selection.isValid && selection.start >= 0
        ? selection.start
        : currentText.length;

    final endPosition = selection.isValid && selection.end >= 0
        ? selection.end
        : currentText.length;

    final newText = currentText.replaceRange(
      insertPosition,
      endPosition,
      gifUrl,
    );

    _send(message: newText);
  }
}
