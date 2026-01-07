import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../provider/emoji_provider.dart';
import '../../utils/text_util.dart';
import '../encrypted_image.dart';

class ChatMessageItem extends ConsumerStatefulWidget {
  final int messageId;
  final String message;
  final bool isSelf;
  final String avatarUrl;
  final String? nickname;
  final int? userId;
  final DateTime createdAt;
  final bool showFailed;
  final bool resending;
  final bool hasRead;
  final VoidCallback? onResend;

  final VoidCallback? onRead;

  const ChatMessageItem({
    super.key,
    required this.message,
    required this.isSelf,
    required this.avatarUrl,
    required this.messageId,
    this.nickname,
    this.userId,
    required this.createdAt,
    this.showFailed = true,
    this.resending = false,
    this.onResend,
    this.hasRead = false,
    this.onRead,
  });

  @override
  ConsumerState<ChatMessageItem> createState() => _ChatMessageItemState();
}

class _ChatMessageItemState extends ConsumerState<ChatMessageItem> {
  Widget buildMessageContent(String messageContent) {
    final regex = RegExp(r'\^\*#\*([\w]+)\*#\*\^');
    final matches = regex.allMatches(messageContent);

    if (matches.isEmpty) {
      return Text(
        messageContent,
        style: TextStyle(
          color: widget.isSelf ? Colors.black : Colors.white,
          fontSize: 16,
        ),
      );
    }

    final emojiState = ref.watch(emojiProvider(1));

    final children = <InlineSpan>[];
    int lastEnd = 0;

    for (final match in matches) {
      if (match.start > lastEnd) {
        children.add(
          TextSpan(
            text: messageContent.substring(lastEnd, match.start),
            style: TextStyle(
              color: widget.isSelf ? Colors.black : Colors.white,
              fontSize: 16,
            ),
          ),
        );
      }

      final code = match.group(1)!;

      try {
        final emoji = emojiState.emojis.firstWhere(
          (e) => e.code == '^*#*$code*#*^',
        );

        children.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: _buildEmojiWidget(emoji.url, 24, 24),
            ),
          ),
        );
      } catch (e) {
        children.add(
          TextSpan(
            text: code,
            style: TextStyle(
              color: widget.isSelf ? Colors.black : Colors.white,
              fontSize: 16,
            ),
          ),
        );
      }

      lastEnd = match.end;
    }

    if (lastEnd < messageContent.length) {
      children.add(
        TextSpan(
          text: messageContent.substring(lastEnd),
          style: TextStyle(
            color: widget.isSelf ? Colors.black : Colors.white,
            fontSize: 16,
          ),
        ),
      );
    }

    return RichText(text: TextSpan(children: children));
  }

  @override
  Widget build(BuildContext context) {
    final bubbleColor = widget.isSelf
        ? const Color(0xFFFFFFFF)
        : const Color(0xFF333333);

    return VisibilityDetector(
      key: Key("msg_${widget.message.hashCode}_${widget.messageId}"),
      onVisibilityChanged: (info) {
        if (!widget.hasRead && info.visibleFraction > 0.3) {
          widget.onRead?.call();
        }
      },

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: widget.isSelf
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!widget.isSelf)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: UserAvatar(
                url: widget.avatarUrl,
                size: 40,
                userId: widget.isSelf ? null : widget.userId,
                nickname: widget.nickname,
              ),
            ),
          const SizedBox(width: 8),
          Flexible(
            child: Align(
              alignment: widget.isSelf
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.isSelf && widget.showFailed)
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0, right: 4.0),
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () => widget.onResend?.call(),
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: Center(
                            child: widget.resending
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.red,
                                    ),
                                  )
                                : Container(
                                    width: 20,
                                    height: 20,
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    alignment: Alignment.center,
                                    child: const Text(
                                      "!",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.7,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!widget.isSelf && widget.nickname != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4, top: 10),
                            child: Text(
                              "@${widget.nickname}",
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(bottom: 6),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: bubbleColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: widget.isSelf
                                    ? CrossAxisAlignment.end
                                    : CrossAxisAlignment.start,
                                children: [
                                  buildMessageContent(widget.message),
                                  const SizedBox(height: 4),
                                  Text(
                                    formatMessageTime(widget.createdAt),
                                    style: TextStyle(
                                      color: widget.isSelf
                                          ? Colors.black54
                                          : Colors.white70,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              top: 14,
                              left: widget.isSelf ? null : -3,
                              right: widget.isSelf ? -3 : null,
                              child: Transform.rotate(
                                angle: math.pi / (widget.isSelf ? 5 : -5),
                                child: Container(
                                  width: 10,
                                  height: 10,
                                  color: bubbleColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          if (widget.isSelf)
            UserAvatar(
              url: widget.avatarUrl,
              nickname: widget.nickname,
              size: 40,
            ),
        ],
      ),
    );
  }

  Widget _buildEmojiWidget(String path, double width, double height) {
    final isLocalFile =
        path.startsWith('/') || (path.length > 2 && path[1] == ':');

    if (!kIsWeb && isLocalFile) {
      final file = File(path);
      if (file.existsSync()) {
        return SvgPicture.memory(
          file.readAsBytesSync(),
          width: width,
          height: height,
        );
      }
    }

    return SvgPicture.network(
      path,
      width: width,
      height: height,
      placeholderBuilder: (_) => SizedBox(
        width: width,
        height: height,
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
    );
  }
}
