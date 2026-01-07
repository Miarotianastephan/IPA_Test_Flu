import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:live_app/models/conversation.dart';
import 'package:live_app/page/group_info_page.dart';
import 'package:live_app/provider/api_provider.dart';
import 'package:live_app/provider/i18n_provider.dart';
import 'package:live_app/widgets/group_avatar_widget.dart';
import 'package:live_app/widgets/message/action_panel.dart';
import 'package:live_app/widgets/message/audio_message_item.dart';
import 'package:live_app/widgets/message/audio_recorder_widget.dart';
import 'package:live_app/widgets/message/chat_input_bar.dart';
import 'package:live_app/widgets/message/emoji_text_input.dart';
import 'package:live_app/widgets/message/message_item.dart';
import 'package:live_app/widgets/message/message_item_gif.dart';
import 'package:live_app/widgets/message/video_message_item.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:video_player/video_player.dart';

import '../models/conversation_user.dart';
import '../provider/conversation_provider.dart';

class GroupChatDetailPage extends ConsumerStatefulWidget {
  final Conversation? conversation;
  final int? conversationId;

  const GroupChatDetailPage({
    super.key,
    this.conversation,
    this.conversationId,
  });

  @override
  ConsumerState<GroupChatDetailPage> createState() =>
      _GroupChatDetailPageState();
}

class _GroupChatDetailPageState extends ConsumerState<GroupChatDetailPage> {
  final EmojiTextController _controller = EmojiTextController();
  final ScrollController _scroll = ScrollController();
  int _lastMessageCount = 0;
  double _lastMaxScrollExtent = 0;
  int _unreadCount = 0;
  bool _showUnreadIndicator = false;
  bool _initialScrollDone = false;
  final Set<int> _unreadMsgIds = {};
  double _previousKeyboardHeight = 0.0;

  final FocusNode _focusNode = FocusNode();
  bool _showActionPanel = false;
  bool _isMenuExpanded = true;
  bool _showAudioRecorder = false;
  final ImagePicker _picker = ImagePicker();

  int get conversationId {
    final id = widget.conversationId ?? widget.conversation?.id;
    if (id == null) {
      throw StateError('Both conversationId and conversation are null');
    }
    return id;
  }

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
          Future.delayed(const Duration(milliseconds: 300), () {
            if (_scroll.hasClients) {
              _scroll.jumpTo(_scroll.position.maxScrollExtent);
            }
          });
        });
      } else {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void initState() {
    super.initState();

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        if (_showActionPanel) {
          setState(() {
            _showActionPanel = false;
          });
        }
        setState(() {
          _isMenuExpanded = false;
        });
      } else {
        setState(() {
          _isMenuExpanded = true;
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
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(conversationProvider(conversationId));
    final conversation = chatState.conversation ?? widget.conversation;
    final messages = chatState.messages;
    final i18n = ref.read(i18nNotifierProvider.notifier);
    String translate(String key) => i18n.translate(key);

    if (conversation == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Text(translate("loading")),
        ),
        body: const Center(
          child: CircularProgressIndicator(color: Colors.blue),
        ),
      );
    }

    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;

      final currentLen = messages.length;
      bool wasAtBottom = (_scroll.offset >= _lastMaxScrollExtent - 50);

      if (keyboardHeight > _previousKeyboardHeight && keyboardHeight > 0) {
        Future.delayed(const Duration(milliseconds: 100), () {
          if (_scroll.hasClients) {
            _scroll.jumpTo(_scroll.position.maxScrollExtent);
          }
        });
      }
      _previousKeyboardHeight = keyboardHeight;

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
          title: GestureDetector(
            onTap: () {
              // TODO: Navigate to group details page
            },
            child: Row(
              children: [
                GroupAvatarWidget(members: conversation.users, size: 36),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        conversation.name ?? translate("groupChat"),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        "${conversation.users.length} ${translate("members")}",
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            Builder(
              builder: (buttonContext) {
                return IconButton(
                  icon: const Icon(Icons.more_horiz, color: Colors.white),
                  onPressed: () async {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GroupInfoPage(
                          conversation: conversation,
                          conversationId: conversationId,
                        ),
                      ),
                    );
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
                        for (final u in conversation.users) {
                          if (u.userId == msg.senderId) {
                            senderConvUser = u;
                            break;
                          }
                        }

                        final senderUserInfo = senderConvUser?.user;
                        final nickname =
                            senderUserInfo?.nickname ??
                            senderUserInfo?.username ??
                            "User ${msg.senderId}";

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
                                  "${translate("unreadMessage")}· ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}",
                                  style: const TextStyle(
                                    color: Colors.redAccent,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              _buildMessageWidget(
                                msg,
                                senderUserInfo,
                                senderConvUser,
                                nickname,
                                msgType,
                                content,
                              ),
                            ],
                          );
                        }

                        return _buildMessageWidget(
                          msg,
                          senderUserInfo,
                          senderConvUser,
                          nickname,
                          msgType,
                          content,
                        );
                      },
                    ),
                  ),
                  if (_showUnreadIndicator)
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: GestureDetector(
                        onTap: () {
                          _scroll.animateTo(
                            _scroll.position.maxScrollExtent,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "$_unreadCount ${translate("newMessages")}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.arrow_downward,
                                color: Colors.white,
                                size: 16,
                              ),
                            ],
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

  Widget _buildMessageWidget(
    dynamic msg,
    dynamic senderUserInfo,
    ConversationUser? senderConvUser,
    String nickname,
    String msgType,
    String content,
  ) {
    if (msgType == 'text') {
      return ChatMessageItem(
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
            conversationProvider(conversationId).notifier,
          );
          notifier.resendMessage(msg);
        },
        onRead: () {
          final notifier = ref.read(
            conversationProvider(conversationId).notifier,
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
    } else if (msgType == 'gif') {
      return ChatGifMessageItem(
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
            conversationProvider(conversationId).notifier,
          );
          notifier.resendMessage(msg);
        },
        onRead: () {
          final notifier = ref.read(
            conversationProvider(conversationId).notifier,
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
    } else if (msgType == "audio") {
      return ChatAudioMessageItem(
        messageId: msg.id,
        audioUrl: content,
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
            conversationProvider(conversationId).notifier,
          );
          notifier.resendMessage(msg);
        },
        onRead: () {
          final notifier = ref.read(
            conversationProvider(conversationId).notifier,
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
    } else if (msgType == 'video') {
      return ChatVideoMessageItem(
        messageId: msg.id,
        videoUrl: content,
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
            conversationProvider(conversationId).notifier,
          );
          notifier.resendMessage(msg);
        },
        onRead: () {
          final notifier = ref.read(
            conversationProvider(conversationId).notifier,
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
    } else if (msgType == "image") {
      return ChatGifMessageItem(
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
            conversationProvider(conversationId).notifier,
          );
          notifier.resendMessage(msg);
        },
        onRead: () {
          final notifier = ref.read(
            conversationProvider(conversationId).notifier,
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
    }

    return const SizedBox.shrink();
  }

  Widget _buildInputBar() {
    if (_showAudioRecorder) {
      return AudioRecorderWidget(
        onCancel: () {
          setState(() {
            _showAudioRecorder = false;
          });
        },
        onSend: (path) async {
          _sendAudio(path);
          if (mounted) {
            setState(() {
              _showAudioRecorder = false;
            });
          }
        },
      );
    }

    return ChatInputBar(
      controller: _controller,
      focusNode: _focusNode,
      isMenuExpanded: _isMenuExpanded,
      onToggleMenu: () {
        setState(() {
          _isMenuExpanded = true;
        });
      },
      onToggleActionPanel: _toggleActionPanel,
      onGalleryTap: () => _pickImage(ImageSource.gallery),
      onCameraTap: () => _pickImage(ImageSource.camera),
      onMicTap: () {
        setState(() {
          _showAudioRecorder = true;
          _showActionPanel = false;
          _focusNode.unfocus();
        });
      },
      onSend: _send,
    );
  }

  Widget _buildKeyboardOrPanelSpace() {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final panelHeight = keyboardHeight > 0
        ? keyboardHeight.ceilToDouble()
        : 360;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      height: _showActionPanel
          ? panelHeight.toDouble()
          : keyboardHeight > 0
          ? keyboardHeight.ceilToDouble()
          : bottomPadding,
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
    bool isGroup = true;

    if (message != null) {
      textToSend = '{"type": "gif","isGroup":$isGroup, "content": "$message"}';
    } else {
      final payload = {
        "type": "text",
        "isGroup": isGroup,
        "content": _controller.getMessageText().trim(),
      };
      textToSend = jsonEncode(payload);
    }

    final notifier = ref.read(conversationProvider(conversationId).notifier);
    notifier.sendMessage(textToSend);

    _scroll.jumpTo(_scroll.position.maxScrollExtent);
    _controller.clear();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  void _sendAudio(String path) async {
    try {
      final userService = ref.read(userServiceProvider);
      final response = await userService.uploadFile(path);
      bool isGroup = true;
      if (response.data != null) {
        final fileUrl = response.data!.url;
        final textToSend =
            '{"type": "audio","isGroup":$isGroup, "content": "$fileUrl"}';
        final notifier = ref.read(
          conversationProvider(conversationId).notifier,
        );
        notifier.sendMessage(textToSend);
        _scroll.jumpTo(_scroll.position.maxScrollExtent);
      }
    } catch (e) {
      debugPrint("Error sending audio: $e");
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  Future<void> _sendImage(String path) async {
    try {
      final userService = ref.read(userServiceProvider);
      final response = await userService.uploadFile(path);
      bool isGroup = true;

      if (response.data != null) {
        final fileUrl = response.data!.url;

        final textToSend =
            '{"type": "image","isGroup":$isGroup, "content": "$fileUrl"}';
        final notifier = ref.read(
          conversationProvider(conversationId).notifier,
        );
        notifier.sendMessage(textToSend);
        _scroll.jumpTo(_scroll.position.maxScrollExtent);
      }
    } catch (e) {
      debugPrint("Error sending image: $e");
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
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

  Future<void> _pickImage(ImageSource source) async {
    try {
      final result = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF1D1D1D),
          title: const Text(
            'Select Media Type',
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.image, color: Colors.white70),
                title: const Text(
                  'Image',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () => Navigator.pop(context, 'image'),
              ),
              ListTile(
                leading: const Icon(Icons.videocam, color: Colors.white70),
                title: const Text(
                  'Video',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () => Navigator.pop(context, 'video'),
              ),
            ],
          ),
        ),
      );

      if (result == null || !mounted) return;

      if (result == 'image') {
        final XFile? image = await _picker.pickImage(
          source: source,
          imageQuality: 85,
        );
        if (image == null || !mounted) return;

        await showDialog(
          context: context,
          barrierColor: Colors.black.withValues(alpha: 0.9),
          barrierDismissible: false,
          builder: (context) {
            return _ImagePreviewDialog(
              imagePath: image.path,
              onSend: _sendImage,
            );
          },
        );
      } else if (result == 'video') {
        await _pickVideo(source);
      }
    } catch (e) {
      debugPrint("Error picking media: $e");
    }
  }

  Future<void> _pickVideo(ImageSource source) async {
    try {
      final XFile? video = await _picker.pickVideo(
        source: source,
        maxDuration: const Duration(minutes: 5),
        preferredCameraDevice: CameraDevice.rear,
      );
      if (video == null || !mounted) return;

      await showDialog(
        context: context,
        barrierColor: Colors.black.withValues(alpha: 0.9),
        barrierDismissible: false,
        builder: (context) {
          return _VideoPreviewDialog(videoPath: video.path, onSend: _sendVideo);
        },
      );
    } catch (e) {
      debugPrint("Error picking video: $e");
    }
  }

  Future<void> _sendVideo(String path) async {
    try {
      final file = File(path);
      if (!file.existsSync()) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Video file not found'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final fileSize = await file.length();

      // Check file size (max 50MB for example)
      if (fileSize > 50 * 1024 * 1024) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Video is too large. Maximum size is 50MB.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 4),
            ),
          );
        }
        return;
      }

      final userService = ref.read(userServiceProvider);

      try {
        final response = await userService.uploadFile(path);

        bool isGroup = false;

        if (response.data != null && response.data!.url.isNotEmpty) {
          final fileUrl = response.data!.url;

          final textToSend =
              '{"type": "video","isGroup":$isGroup, "content": "$fileUrl"}';
          final notifier = ref.read(
            conversationProvider(conversationId).notifier,
          );
          notifier.sendMessage(textToSend);
          _scroll.jumpTo(_scroll.position.maxScrollExtent);
        }
      } on Exception catch (e) {
        // Handle backend error (code != 1) or parsing error
        final errorMessage = e.toString().replaceAll('Exception: ', '');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Upload failed: $errorMessage'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e, stackTrace) {
      debugPrint("Error sending video: $e");
      debugPrint("Stack trace: $stackTrace");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send video: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }
}

class _ImagePreviewDialog extends StatefulWidget {
  final String imagePath;
  final Future<void> Function(String) onSend;

  const _ImagePreviewDialog({required this.imagePath, required this.onSend});

  @override
  State<_ImagePreviewDialog> createState() => _ImagePreviewDialogState();
}

class _ImagePreviewDialogState extends State<_ImagePreviewDialog> {
  bool _isUploading = false;

  Future<void> _handleSend() async {
    setState(() => _isUploading = true);

    try {
      await widget.onSend(widget.imagePath);
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint("Error sending image: $e");
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: Stack(
        children: [
          Positioned.fill(
            child: InteractiveViewer(
              child: Image.file(File(widget.imagePath), fit: BoxFit.contain),
            ),
          ),

          if (_isUploading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.7),
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        strokeWidth: 3,
                        color: Colors.white,
                      ),
                      SizedBox(height: 16),
                      Text(
                        "Envoi en cours...",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          /// Footer transparent
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: Theme.of(
                      context,
                    ).primaryColor.withOpacity(0.5),
                    child: IconButton(
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Colors.white70,
                        size: 28,
                      ),
                      onPressed: _isUploading
                          ? null
                          : () => Navigator.pop(context),
                    ),
                  ),
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: Theme.of(
                      context,
                    ).primaryColor.withOpacity(0.5),
                    child: IconButton(
                      icon: const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 40,
                      ),
                      onPressed: _isUploading ? null : _handleSend,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VideoPreviewDialog extends StatefulWidget {
  final String videoPath;
  final Future<void> Function(String) onSend;

  const _VideoPreviewDialog({required this.videoPath, required this.onSend});

  @override
  State<_VideoPreviewDialog> createState() => _VideoPreviewDialogState();
}

class _VideoPreviewDialogState extends State<_VideoPreviewDialog> {
  bool _isUploading = false;

  // Video Player (for non-Huawei devices)
  VideoPlayerController? _videoPlayerController;

  // MediaKit Player (for Huawei devices)
  Player? _mediaKitPlayer;
  VideoController? _mediaKitVideoController;

  bool _useMediaKit = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<bool> _isHuaweiDevice() async {
    if (!Platform.isAndroid) return false;
    final info = await DeviceInfoPlugin().androidInfo;
    return info.manufacturer.toLowerCase() == 'huawei';
  }

  Future<void> _initializeVideo() async {
    try {
      _useMediaKit = await _isHuaweiDevice();

      if (_useMediaKit) {
        await _initializeMediaKit();
      } else {
        await _initializeVideoPlayer();
      }
    } catch (e) {
      debugPrint("Error initializing video preview: $e");
    }
  }

  Future<void> _initializeMediaKit() async {
    try {
      _mediaKitPlayer = Player();
      _mediaKitVideoController = VideoController(_mediaKitPlayer!);

      await _mediaKitPlayer!.open(Media(widget.videoPath), play: false);
      await _mediaKitPlayer!.setPlaylistMode(PlaylistMode.single);
      await _mediaKitPlayer!.play();

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      debugPrint("Error initializing MediaKit preview: $e");
    }
  }

  Future<void> _initializeVideoPlayer() async {
    try {
      _videoPlayerController = VideoPlayerController.file(
        File(widget.videoPath),
      );
      await _videoPlayerController!.initialize();
      await _videoPlayerController!.setLooping(true);
      await _videoPlayerController!.play();

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      debugPrint("Error initializing VideoPlayer preview: $e");
    }
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _mediaKitPlayer?.dispose();
    super.dispose();
  }

  Future<void> _handleSend() async {
    setState(() => _isUploading = true);

    try {
      await widget.onSend(widget.videoPath);
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint("Error sending video: $e");
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  void _togglePlayPause() {
    setState(() {
      if (_useMediaKit) {
        if (_mediaKitPlayer?.state.playing ?? false) {
          _mediaKitPlayer?.pause();
        } else {
          _mediaKitPlayer?.play();
        }
      } else {
        if (_videoPlayerController?.value.isPlaying ?? false) {
          _videoPlayerController?.pause();
        } else {
          _videoPlayerController?.play();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isPlaying = _useMediaKit
        ? (_mediaKitPlayer?.state.playing ?? false)
        : (_videoPlayerController?.value.isPlaying ?? false);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: Stack(
        children: [
          // Video player
          Positioned.fill(
            child: Center(
              child: _isInitialized
                  ? (_useMediaKit && _mediaKitVideoController != null
                        ? Video(
                            controller: _mediaKitVideoController!,
                            controls: null,
                          )
                        : _videoPlayerController != null
                        ? AspectRatio(
                            aspectRatio:
                                _videoPlayerController!.value.aspectRatio,
                            child: VideoPlayer(_videoPlayerController!),
                          )
                        : const SizedBox.shrink())
                  : const CircularProgressIndicator(color: Colors.white),
            ),
          ),

          // Play/Pause button overlay
          if (_isInitialized && !_isUploading)
            Positioned.fill(
              child: GestureDetector(
                onTap: _togglePlayPause,
                child: Center(
                  child: AnimatedOpacity(
                    opacity: isPlaying ? 0.0 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 48,
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // Uploading overlay
          if (_isUploading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.7),
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        strokeWidth: 3,
                        color: Colors.white,
                      ),
                      SizedBox(height: 16),
                      Text(
                        "Uploading video...",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Bottom buttons
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.6),
                  ],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: Theme.of(
                      context,
                    ).primaryColor.withValues(alpha: 0.5),
                    child: IconButton(
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Colors.white70,
                        size: 28,
                      ),
                      onPressed: _isUploading
                          ? null
                          : () => Navigator.pop(context),
                    ),
                  ),
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: Theme.of(
                      context,
                    ).primaryColor.withValues(alpha: 0.5),
                    child: IconButton(
                      icon: const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 40,
                      ),
                      onPressed: _isUploading ? null : _handleSend,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
