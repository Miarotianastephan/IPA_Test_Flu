import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:live_app/constants/ad_placement.dart';
import 'package:live_app/models/message.dart';
import 'package:live_app/provider/ad_provider.dart';
import 'package:live_app/provider/app_config_provider.dart';
import 'package:live_app/provider/i18n_provider.dart';
import 'package:live_app/provider/my_user_provider.dart';
import 'package:live_app/provider/support_provider.dart';
import 'package:live_app/utils/device_info_helper.dart';
import 'package:live_app/utils/utils.dart';
import 'package:live_app/widgets/ad_banner_carousel.dart';
import 'package:live_app/widgets/message/ad_chat_bubble.dart';
import 'package:live_app/widgets/message/audio_message_item.dart';
import 'package:live_app/widgets/message/audio_recorder_widget.dart';
import 'package:live_app/widgets/message/chat_input_bar.dart';
import 'package:live_app/widgets/message/chat_menu_button.dart';
import 'package:live_app/widgets/message/emoji_text_input.dart';
import 'package:live_app/widgets/message/message_item.dart';
import 'package:live_app/widgets/message/message_item_gif.dart';
import 'package:live_app/widgets/message/video_message_item.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:video_player/video_player.dart';
import 'package:photo_view/photo_view.dart';

import '../models/conversation_user.dart';
import '../models/userinfo.dart';
import '../models/vip.dart';
import '../provider/api_provider.dart';
import '../provider/conversation_provider.dart';
import '../provider/current_user_provider.dart';
import '../utils/app_package_info.dart';
import '../utils/conversation_utils.dart';
import '../widgets/message/action_panel.dart';

class ChatDetailPage extends ConsumerStatefulWidget {
  final UserInfo user;
  final bool isSupportChat;
  final int? conversationId;
  const ChatDetailPage({
    super.key,
    required this.user,
    this.isSupportChat = false,
    this.conversationId,
  });

  @override
  ConsumerState<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends ConsumerState<ChatDetailPage> {
  ChatController get _chatNotifier {
    if (widget.conversationId != null) {
      return ref.read(conversationProvider(widget.conversationId!).notifier);
    }
    return ref.read(chatControllerProvider(widget.user.id).notifier);
  }

  final EmojiTextController _controller = EmojiTextController();
  final ScrollController _scroll = ScrollController();
  int _lastMessageCount = 0;
  double _lastMaxScrollExtent = 0;
  int _unreadCount = 0;
  bool _showUnreadIndicator = false;
  bool _initialScrollDone = false;
  final Set<int> _unreadMsgIds = {};
  double pannelHeight = 0.0;
  double _previousKeyboardHeight = 0.0;
  final FocusNode _focusNode = FocusNode();

  bool _chatLogRequested = false;
  ProviderSubscription<String?>? _currentUserIdSub;

  bool _showActionPanel = false;
  bool _isMenuExpanded = true;
  bool _showAudioRecorder = false;
  bool _bannerClosed = false;
  final ImagePicker _picker = ImagePicker();

  bool _isAdSlot(int displayIndex, int adsToInsert, int adsAfter) {
    if (adsToInsert == 0) return false;
    if ((displayIndex + 1) % (adsAfter + 1) != 0) return false;
    final adIndex = (displayIndex + 1) ~/ (adsAfter + 1) - 1;
    return adIndex < adsToInsert;
  }

  int _getAdIndex(int displayIndex, int adsAfter) {
    return (displayIndex + 1) ~/ (adsAfter + 1) - 1;
  }

  int _getMessageIndex(int displayIndex, int adsAfter, int adsToInsert) {
    final adsBeforeThis = _isAdSlot(displayIndex, adsToInsert, adsAfter)
        ? _getAdIndex(displayIndex, adsAfter)
        : (_getAdIndex(displayIndex, adsAfter) + 1).clamp(0, adsToInsert);
    return displayIndex - adsBeforeThis;
  }

  int _getAdsToInsert(int messageCount, int adCount, int adsAfter) {
    if (messageCount == 0 || adCount == 0) return 0;
    final maxAdsToInsert = messageCount ~/ adsAfter;
    return maxAdsToInsert < adCount ? maxAdsToInsert : adCount;
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _chatLog();
      if (widget.isSupportChat) {
        _sendDeviceInfo();
      }
    });

    _currentUserIdSub = ref.listenManual<String?>(currentUserIdProvider, (
      prev,
      next,
    ) {
      if (!mounted) return;
      if (prev == next) return;
      if (next == null) return;
      _chatLog();
    });

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
    _currentUserIdSub?.close();
    _focusNode.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _chatLog() {
    // Support chats use agent IDs that are not in the users table,
    // so the chat-log endpoint would fail with a FK constraint error.
    if (widget.isSupportChat) return;
    final selfUser = ref.read(userProvider).user;
    if (selfUser == null) return;
    if (_chatLogRequested) return;
    _chatLogRequested = true;

    final provider = supportChatLogProvider((
      fromUserId: selfUser.id,
      toUserId: widget.user.id,
    ));

    ref.invalidate(provider);
    ref.read(provider.future).then((value) {
      debugPrint('chatLog loaded: ${value?.id}');
    }).catchError((e, st) {
      debugPrint('chatLog error: $e\n$st');
    });
  }

  Future<void> _sendDeviceInfo() async {
    try {
      final deviceInfo = await _collectDeviceInfo();
      await ref.read(messageServiceProvider).sendDeviceInfo(deviceInfo);
    } catch (e) {
      debugPrint('Failed to send device info: $e');
    }
  }

  Future<Map<String, dynamic>> _collectDeviceInfo() async {
    final deviceInfoPlugin = DeviceInfoPlugin();
    final deviceHelper = DeviceInfoHelper.instance;
    final packageInfo = await AppPackageInfoUtil.getInfo();

    String platform = deviceHelper.getPlatform();
    String? osVersion;
    int? sdkInt;
    bool isPhysicalDevice = true;
    String? brand;
    String? model;
    String? manufacturer;

    if (kIsWeb) {
      if (await deviceHelper.isIosWeb()) {
        platform = 'ios';
        manufacturer = 'Apple';
      } else {
        platform = 'h5';
      }
      final webInfo = await deviceInfoPlugin.webBrowserInfo;
      osVersion = webInfo.platform;
      brand = webInfo.browserName.name;
      model = webInfo.userAgent;
    } else if (Platform.isAndroid) {
      final androidInfo = await deviceInfoPlugin.androidInfo;
      osVersion = androidInfo.version.release;
      sdkInt = androidInfo.version.sdkInt;
      isPhysicalDevice = androidInfo.isPhysicalDevice;
      brand = androidInfo.brand;
      model = androidInfo.model;
      manufacturer = androidInfo.manufacturer;
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfoPlugin.iosInfo;
      osVersion = iosInfo.systemVersion;
      isPhysicalDevice = iosInfo.isPhysicalDevice;
      brand = 'Apple';
      model = iosInfo.model;
      manufacturer = 'Apple';
    }

    return {
      'platform': platform,
      'osVersion': osVersion,
      'sdkInt': sdkInt ?? "",
      "flavor": "",
      'isPhysicalDevice': isPhysicalDevice,
      'brand': brand,
      'model': model,
      'manufacturer': manufacturer,
      'appVersion': packageInfo.version,
      'buildNumber': packageInfo.buildNumber,
      'packageName': packageInfo.packageName,
    };
  }

  @override
  Widget build(BuildContext context) {
    final chatState = widget.conversationId != null
        ? ref.watch(conversationProvider(widget.conversationId!))
        : ref.watch(chatControllerProvider(widget.user.id));
    final conversation = chatState.conversation;
    final messages = chatState.messages;
    final i18n = ref.read(i18nNotifierProvider.notifier);
    String translate(String key) => i18n.translate(key);

    final adState = ref.watch(adListProvider(AdPlacement.chatList));
    final adsAfter = ref.watch(appConfigProvider).data?.adsAfter ?? 5;
    final int adCount = adState.list.length;
    final int adsToInsert =
        adsAfter > 0 ? _getAdsToInsert(messages.length, adCount, adsAfter) : 0;
    final int totalItemCount = messages.length + adsToInsert;

    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;

      final currentLen = messages.length;

      // 判断是否在旧的底部，而不是新的底部（避免新消息扩展列表高度导致判断失败）
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
          title: GestureDetector(
            onTap: () => toUserDetailPage(
              context: context,
              ref: ref,
              userId: widget.user.id,
              url: widget.user.avatar,
              nickname: widget.user.nickname,
              vip: widget.user.vip,
            ),
            child: Text(
              "${widget.user.nickname}",
              style: const TextStyle(color: Colors.white),
            ),
          ),
          actions: [ChatMenuButton(user: widget.user)],
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
                      itemCount: totalItemCount,
                      itemBuilder: (context, index) {
                        if (_isAdSlot(index, adsToInsert, adsAfter)) {
                          final adIndex = _getAdIndex(index, adsAfter);
                          if (adIndex < adState.list.length) {
                            return AdChatBubble(ad: adState.list[adIndex]);
                          }
                          return const SizedBox.shrink();
                        }

                        final messageIndex = _getMessageIndex(
                          index,
                          adsAfter,
                          adsToInsert,
                        );
                        if (messageIndex < 0 ||
                            messageIndex >= messages.length) {
                          return const SizedBox.shrink();
                        }

                        final msg = messages[messageIndex];

                        if (conversation == null) {
                          return const SizedBox.shrink();
                        }

                        ConversationUser? senderConvUser;
                        for (final u in conversation.users) {
                          // Match by senderId or senderSupportId
                          if (msg.senderId != null &&
                              u.userId == msg.senderId) {
                            senderConvUser = u;
                            break;
                          }
                          if (msg.senderSupportId != null &&
                              u.agentSupportId == msg.senderSupportId) {
                            senderConvUser = u;
                            break;
                          }
                        }

                        final senderUserInfo = senderConvUser?.user;

                        final String nickname;
                        if (senderConvUser?.isSupportAgent == true) {
                          final agentUsername =
                              senderConvUser?.agentSupport?.username ?? "客服白兔";
                          nickname = translate(agentUsername);
                        } else {
                          nickname = senderUserInfo?.nickname ??
                              senderUserInfo?.username ??
                              widget.user.username ??
                              '';
                        }

                        final firstUnread = _firstUnreadIndex(messages);
                        final isDividerHere =
                            (firstUnread != null && firstUnread == index);
                        if (isDividerHere) {
                          return Column(
                            children: [
                              Column(
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
                                  _buildMessage(
                                    msg,
                                    senderUserInfo,
                                    nickname,
                                    senderConvUser,
                                  ),
                                ],
                              ),
                            ],
                          );
                        }
                        return Column(
                          children: [
                            _buildMessage(
                              msg,
                              senderUserInfo,
                              nickname,
                              senderConvUser,
                            ),
                          ],
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
                          final totalHeight = _scroll.position.maxScrollExtent +
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
                            "${translate("unread")} $_unreadCount ${translate("item")}${_unreadCount > 1 ? 's' : ''}",
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (!_bannerClosed && adState.list.isNotEmpty)
              AdBannerCarousel(
                ads: adState.list,
                onClose: () => setState(() => _bannerClosed = true),
              ),
            _buildInputBar(),
            _buildKeyboardOrPanelSpace(),
          ],
        ),
      ),
    );
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
          await _sendAudio(path);
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
    final panelHeight =
        keyboardHeight > 0 ? keyboardHeight.ceilToDouble() : 360;

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
    bool isGroup = false;

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

    final notifier = _chatNotifier;
    notifier.sendMessage(textToSend);

    // if (widget.user.isBot) {
    //   trackAiChat();
    // }

    _scroll.jumpTo(_scroll.position.maxScrollExtent);
    _controller.clear();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  Future<void> _sendAudio(String path, {XFile? audioFile}) async {
    try {
      if (widget.isSupportChat) {
        // Support chats don't support file uploads - show message to user
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('File uploads are not supported in support chats'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
        }
        return;
      }

      final userService = ref.read(userServiceProvider);
      final response = await userService.uploadFile(
        path,
        bytes:
            kIsWeb && audioFile != null ? await audioFile.readAsBytes() : null,
        fileName: kIsWeb && audioFile != null ? audioFile.name : null,
        type: 'audio',
      );
      bool isGroup = false;
      if (response.data != null) {
        final fileUrl = response.data!.url;
        final textToSend =
            '{"type": "audio","isGroup":$isGroup, "content": "$fileUrl"}';
        final notifier = ref.read(
          chatControllerProvider(widget.user.id).notifier,
        );
        notifier.sendMessage(textToSend);

        // if (widget.user.isBot) {
        //   trackAiChat();
        // }

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

  Future<void> _sendImage(String path, {XFile? imageFile}) async {
    try {
      final userService = ref.read(userServiceProvider);
      final response = await userService.uploadFile(
        path,
        bytes:
            kIsWeb && imageFile != null ? await imageFile.readAsBytes() : null,
        fileName: kIsWeb && imageFile != null ? imageFile.name : null,
        type: 'image',
      );

      bool isGroup = false;

      if (response.data != null) {
        final fileUrl = response.data!.url;

        final textToSend =
            '{"type": "image","isGroup":$isGroup, "content": "$fileUrl"}';
        final notifier = widget.conversationId != null
            ? ref.read(conversationProvider(widget.conversationId!).notifier)
            : ref.read(chatControllerProvider(widget.user.id).notifier);
        notifier.sendMessage(textToSend, messageType: "image");

        // if (widget.user.isBot) {
        //   trackAiChat();
        // }

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

  void _showFullScreenImage(String imageUrl) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _FullScreenImageViewer(imageUrl: imageUrl),
      ),
    );
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
              imageFile: image,
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

  Map<String, dynamic> _getMessageProperties(Message msg) {
    String msgType;
    String content;

    if (msg.content.trim().startsWith('{')) {
      try {
        final msgToJson = jsonDecode(msg.content);
        msgType = msgToJson['type'] ?? 'text';
        content = msgToJson['content'] ?? msg.content;
      } catch (e) {
        msgType = 'text';
        content = msg.content;
      }
    } else {
      msgType = 'text';
      content = msg.content;
    }

    return {'type': msgType, 'content': content};
  }

  Map<String, dynamic> _getSenderDisplayInfo(
    ConversationUser? senderConvUser,
    UserInfo? senderUserInfo,
    bool isSelf,
  ) {
    final String avatarUrl;
    final String nickname;
    final Vip? vip;

    if (isSelf) {
      nickname = senderUserInfo?.nickname ?? senderUserInfo?.username ?? '';
      avatarUrl = senderUserInfo?.avatar ?? "";
      vip = senderUserInfo?.vip;
    } else {
      final bool isSupport = isSupportAgent(senderConvUser);
      if (isSupport) {
        nickname = getSupportAgentDisplayName(senderConvUser);
        avatarUrl = getSupportAgentAvatar(senderConvUser) ?? "";
        vip = null;
      } else {
        nickname = senderUserInfo?.nickname ??
            senderUserInfo?.username ??
            widget.user.username ??
            '';
        avatarUrl = senderUserInfo?.avatar ?? "";
        vip = senderUserInfo?.vip;
      }
    }

    return {
      'avatarUrl': avatarUrl,
      'nickname': nickname,
      'vip': vip,
      'isSupportAgent': isSelf ? false : isSupportAgent(senderConvUser),
    };
  }

  void _handleMessageRead(Message msg) {
    final notifier = ref.read(chatControllerProvider(widget.user.id).notifier);
    notifier.onRead(msg);

    setState(() {
      _unreadMsgIds.remove(msg.id);
      _unreadCount = _unreadMsgIds.length;
      if (_unreadCount == 0) {
        _showUnreadIndicator = false;
      }
    });
  }

  void _handleMessageResend(Message msg) {
    final notifier = ref.read(chatControllerProvider(widget.user.id).notifier);
    notifier.resendMessage(msg);
  }

  Widget _buildMessage(
    Message msg,
    UserInfo? senderUserInfo,
    String nickname,
    ConversationUser? senderConvUser,
  ) {
    final msgProps = _getMessageProperties(msg);
    final String msgType = msgProps['type'];
    final String content = msgProps['content'];

    final displayInfo = _getSenderDisplayInfo(
      senderConvUser,
      senderUserInfo,
      msg.isSelf,
    );
    final String avatarUrl = displayInfo['avatarUrl'];
    final String displayNickname = displayInfo['nickname'];
    final Vip? vip = displayInfo['vip'];

    if (msgType == 'text') {
      return ChatMessageItem(
        messageId: msg.id,
        message: content,
        isSelf: msg.isSelf,
        createdAt: msg.createdAt,
        avatarUrl: avatarUrl,
        nickname: displayNickname,
        vip: vip,
        userId: senderConvUser?.userId,
        showFailed: msg.sendFailed,
        resending: msg.resending,
        hasRead: msg.isRead,
        onResend: () => _handleMessageResend(msg),
        onRead: () => _handleMessageRead(msg),
      );
    } else if (msgType == 'gif') {
      return ChatGifMessageItem(
        messageId: msg.id,
        gifUrl: content,
        isSelf: msg.isSelf,
        avatarUrl: avatarUrl,
        nickname: displayNickname,
        vip: vip,
        userId: senderConvUser?.userId,
        createdAt: msg.createdAt,
        showFailed: msg.sendFailed,
        resending: msg.resending,
        hasRead: msg.isRead,
        onTap: () => _showFullScreenImage(content),
        onResend: () => _handleMessageResend(msg),
        onRead: () => _handleMessageRead(msg),
      );
    } else if (msgType == 'audio') {
      return ChatAudioMessageItem(
        messageId: msg.id,
        audioUrl: content,
        isSelf: msg.isSelf,
        avatarUrl: avatarUrl,
        nickname: displayNickname,
        vip: vip,
        userId: senderConvUser?.userId,
        createdAt: msg.createdAt,
        showFailed: msg.sendFailed,
        resending: msg.resending,
        hasRead: msg.isRead,
        onResend: () => _handleMessageResend(msg),
        onRead: () => _handleMessageRead(msg),
      );
    } else if (msgType == 'video') {
      return ChatVideoMessageItem(
        messageId: msg.id,
        videoUrl: content,
        isSelf: msg.isSelf,
        avatarUrl: avatarUrl,
        nickname: displayNickname,
        vip: vip,
        userId: senderConvUser?.userId,
        createdAt: msg.createdAt,
        showFailed: msg.sendFailed,
        resending: msg.resending,
        hasRead: msg.isRead,
        onResend: () => _handleMessageResend(msg),
        onRead: () => _handleMessageRead(msg),
      );
    } else if (msgType == 'image') {
      return ChatGifMessageItem(
        messageId: msg.id,
        gifUrl: content,
        isSelf: msg.isSelf,
        avatarUrl: avatarUrl,
        nickname: displayNickname,
        vip: vip,
        userId: senderConvUser?.userId,
        createdAt: msg.createdAt,
        showFailed: msg.sendFailed,
        resending: msg.resending,
        hasRead: msg.isRead,
        onTap: () => _showFullScreenImage(content),
        onResend: () => _handleMessageResend(msg),
        onRead: () => _handleMessageRead(msg),
      );
    }
    return const SizedBox.shrink();
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
          return _VideoPreviewDialog(
            videoPath: video.path,
            videoFile: video,
            onSend: _sendVideo,
          );
        },
      );
    } catch (e) {
      debugPrint("Error picking video: $e");
    }
  }

  Future<void> _sendVideo(String path, {XFile? videoFile}) async {
    try {
      final userService = ref.read(userServiceProvider);
      final response = await userService.uploadFile(
        path,
        bytes:
            kIsWeb && videoFile != null ? await videoFile.readAsBytes() : null,
        fileName: kIsWeb && videoFile != null ? videoFile.name : null,
        type: 'video',
      );

      bool isGroup = false;

      if (response.data != null && response.data!.url.isNotEmpty) {
        final fileUrl = response.data!.url;
        debugPrint("File upload successful, URL: $fileUrl");

        final textToSend =
            '{"type": "video","isGroup":$isGroup, "content": "$fileUrl"}';
        debugPrint("Sending message: $textToSend");

        final notifier = ref.read(
          chatControllerProvider(widget.user.id).notifier,
        );

        notifier.sendMessage(textToSend);
        // if (widget.user.isBot) {
        //   trackAiChat();
        // }

        _scroll.jumpTo(_scroll.position.maxScrollExtent);
      }
    } catch (e) {
      debugPrint("Error sending video: $e");

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
  final XFile? imageFile;
  final Future<void> Function(String, {XFile? imageFile}) onSend;

  const _ImagePreviewDialog({
    required this.imagePath,
    this.imageFile,
    required this.onSend,
  });

  @override
  State<_ImagePreviewDialog> createState() => _ImagePreviewDialogState();
}

class _ImagePreviewDialogState extends State<_ImagePreviewDialog> {
  bool _isUploading = false;

  Future<void> _handleSend() async {
    setState(() => _isUploading = true);

    try {
      await widget.onSend(widget.imagePath, imageFile: widget.imageFile);
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
              child: kIsWeb
                  ? _webImagePreview(imagePath: widget.imagePath)
                  : Image.file(File(widget.imagePath), fit: BoxFit.contain),
            ),
          ),

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
                      onPressed:
                          _isUploading ? null : () => Navigator.pop(context),
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

  Widget _webImagePreview({required String imagePath}) {
    if (kIsWeb) {
      return FutureBuilder<Uint8List>(
        future: widget.imageFile?.readAsBytes() ?? _readFileAsBytes(imagePath),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            return Image.memory(snapshot.data!, fit: BoxFit.contain);
          } else if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Error loading image',
                style: TextStyle(color: Colors.white),
              ),
            );
          }
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        },
      );
    }
    return Image.file(File(imagePath), fit: BoxFit.contain);
  }

  Future<Uint8List> _readFileAsBytes(String path) async {
    if (kIsWeb) {
      try {
        if (path.startsWith('data:')) {
          final base64String = path.split(',')[1];
          return const Base64Decoder().convert(base64String);
        }

        final file = File(path);
        if (await file.exists()) {
          return await file.readAsBytes();
        }

        throw Exception('Unable to read web image file: $path');
      } catch (e) {
        debugPrint('Error reading web image: $e');
        rethrow;
      }
    }
    return await File(path).readAsBytes();
  }
}

class _VideoPreviewDialog extends StatefulWidget {
  final String videoPath;
  final XFile? videoFile;
  final Future<void> Function(String, {XFile? videoFile}) onSend;

  const _VideoPreviewDialog({
    required this.videoPath,
    this.videoFile,
    required this.onSend,
  });

  @override
  State<_VideoPreviewDialog> createState() => _VideoPreviewDialogState();
}

class _VideoPreviewDialogState extends State<_VideoPreviewDialog> {
  bool _isUploading = false;

  VideoPlayerController? _videoPlayerController;

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
    if (kIsWeb || !Platform.isAndroid) return false;
    final info = await DeviceInfoPlugin().androidInfo;
    return info.manufacturer.toLowerCase() == 'huawei';
  }

  Future<void> _initializeVideo() async {
    try {
      if (kIsWeb) {
        // For web, use a simpler approach or skip video preview
        _useMediaKit = false;
        await _initializeWebVideo();
      } else {
        _useMediaKit = await _isHuaweiDevice();

        if (_useMediaKit) {
          await _initializeMediaKit();
        } else {
          await _initializeVideoPlayer();
        }
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

  Future<void> _initializeWebVideo() async {
    try {
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      debugPrint("Error initializing web video preview: $e");
    }
  }

  Widget _webVideoPlaceholder() {
    return Container(
      width: 300,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.videocam_outlined, color: Colors.white70, size: 48),
          SizedBox(height: 16),
          Text(
            'Video Preview\n(Not available on web)',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
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
      await widget.onSend(widget.videoPath, videoFile: widget.videoFile);
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
          Positioned.fill(
            child: Center(
              child: _isInitialized
                  ? (kIsWeb
                      ? _webVideoPlaceholder()
                      : (_useMediaKit && _mediaKitVideoController != null
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
                              : const SizedBox.shrink()))
                  : const CircularProgressIndicator(color: Colors.white),
            ),
          ),
          if (_isInitialized && !_isUploading && !kIsWeb)
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
                      onPressed:
                          _isUploading ? null : () => Navigator.pop(context),
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

class _FullScreenImageViewer extends StatefulWidget {
  final String imageUrl;

  const _FullScreenImageViewer({required this.imageUrl});

  @override
  State<_FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<_FullScreenImageViewer> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: PhotoView(
          imageProvider: NetworkImage(widget.imageUrl),
          backgroundDecoration: const BoxDecoration(color: Colors.black),
          minScale: PhotoViewComputedScale.contained,
          maxScale: PhotoViewComputedScale.covered * 4.0,
          enableRotation: false,
          loadingBuilder: (context, event) => Center(
            child: CircularProgressIndicator(
              value: event == null
                  ? 0
                  : event.cumulativeBytesLoaded /
                      (event.expectedTotalBytes ?? 1),
              color: Colors.white,
            ),
          ),
          errorBuilder: (context, error, stackTrace) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.broken_image, color: Colors.white70, size: 64),
                const SizedBox(height: 16),
                Text(
                  'Failed to load image',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
