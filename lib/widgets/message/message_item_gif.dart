import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:live_app/utils/text_util.dart';
import 'package:live_app/widgets/encrypted_image.dart';
import 'package:visibility_detector/visibility_detector.dart';

class ChatGifMessageItem extends StatefulWidget {
  final int messageId;
  final String gifUrl;
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

  const ChatGifMessageItem({
    super.key,
    required this.gifUrl,
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
  State<ChatGifMessageItem> createState() => _ChatGifMessageItemState();
}

class _ChatGifMessageItemState extends State<ChatGifMessageItem> {
  @override
  Widget build(BuildContext context) {
    final bubbleColor = const Color.fromARGB(255, 32, 32, 32);

    return VisibilityDetector(
      key: Key("gif_${widget.gifUrl.hashCode}_${widget.messageId}"),
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
                      crossAxisAlignment: widget.isSelf
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
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
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: bubbleColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: widget.isSelf
                                    ? CrossAxisAlignment.end
                                    : CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      widget.gifUrl,
                                      width: 150,
                                      height: 150,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    formatMessageTime(widget.createdAt),
                                    style: TextStyle(
                                      color: Colors.white70,
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
}
