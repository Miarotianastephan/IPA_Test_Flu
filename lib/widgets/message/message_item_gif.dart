import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/models/vip.dart';
import 'package:live_app/provider/my_user_provider.dart';
import 'package:live_app/repository/image_repository.dart';
import 'package:live_app/utils/text_util.dart';
import 'package:live_app/widgets/encrypted_image.dart';
import 'package:live_app/widgets/vip_badge.dart';
import 'package:visibility_detector/visibility_detector.dart';

class ChatGifMessageItem extends ConsumerStatefulWidget {
  final int messageId;
  final String gifUrl;
  final bool isSelf;
  final String avatarUrl;
  final String? nickname;
  final Vip? vip;
  final String? userId;
  final DateTime createdAt;
  final bool showFailed;
  final bool resending;
  final bool hasRead;
  final VoidCallback? onResend;
  final VoidCallback? onRead;
  final VoidCallback? onTap;

  const ChatGifMessageItem({
    super.key,
    required this.gifUrl,
    required this.isSelf,
    required this.avatarUrl,
    required this.messageId,
    this.nickname,
    this.vip,
    this.userId,
    required this.createdAt,
    this.showFailed = true,
    this.resending = false,
    this.onResend,
    this.hasRead = false,
    this.onRead,
    this.onTap,
  });

  @override
  ConsumerState<ChatGifMessageItem> createState() => _ChatGifMessageItemState();
}

class _ChatGifMessageItemState extends ConsumerState<ChatGifMessageItem> {
  String? _cachedImagePath;

  @override
  void initState() {
    super.initState();
    _loadCachedImage();
  }

  @override
  void didUpdateWidget(ChatGifMessageItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.gifUrl != widget.gifUrl) {
      _loadCachedImage();
    }
  }

  Future<void> _loadCachedImage() async {
    final imageRepo = ref.read(imageRepositoryProvider);

    final isUrl = widget.gifUrl.startsWith('http');

    if (isUrl) {
      final cache = await imageRepo.getImageCache(widget.gifUrl);

      if (cache?.localPath != null) {
        final file = File(cache!.localPath!);
        final exists = await file.exists();

        if (exists && mounted) {
          setState(() {
            _cachedImagePath = cache.localPath;
          });
        } else {
          imageRepo.enqueueDownload(widget.gifUrl);
        }
      } else {
        imageRepo.enqueueDownload(widget.gifUrl);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userProvider);
    final userVip = userState.user?.vip;
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
                vip: widget.vip,
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
                            child: Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    "@${widget.nickname}",
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 15,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                                VipBadge(vip: widget.vip, size: 15),
                              ],
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
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      GestureDetector(
                                        onTap: widget.onTap,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child: _buildGifImage(widget.gifUrl),
                                        ),
                                      ),
                                      if (widget.resending)
                                        Container(
                                          width: 150,
                                          height: 150,
                                          decoration: BoxDecoration(
                                            color: Colors.black.withOpacity(
                                              0.5,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: const Center(
                                            child: CircularProgressIndicator(
                                              strokeWidth: 3,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                    ],
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
              vip: userVip,
              size: 40,
            ),
        ],
      ),
    );
  }

  Widget _buildGifImage(String path) {
    String imagePath = path;

    if (_cachedImagePath != null) {
      imagePath = _cachedImagePath!;
    }

    final isLocalFile =
        !imagePath.startsWith('http') &&
        (imagePath.startsWith('/') ||
            (imagePath.length > 2 && imagePath[1] == ':'));

    if (isLocalFile) {
      final file = File(imagePath);
      final exists = file.existsSync();

      if (exists) {
        return Image.file(file, width: 150, height: 150, fit: BoxFit.cover);
      } else {
        return const SizedBox(
          width: 150,
          height: 150,
          child: Center(
            child: Icon(
              Icons.image_not_supported,
              color: Colors.grey,
              size: 48,
            ),
          ),
        );
      }
    }

    return Image.network(
      imagePath,
      width: 150,
      height: 150,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return const SizedBox(
          width: 150,
          height: 150,
          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return const SizedBox(
          width: 150,
          height: 150,
          child: Center(child: Icon(Icons.broken_image, color: Colors.grey)),
        );
      },
    );
  }
}
