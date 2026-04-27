import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/utils/text_util.dart';
import 'package:live_app/widgets/encrypted_image.dart';
import 'package:live_app/widgets/vip_badge.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:live_app/models/vip.dart';
import 'package:live_app/provider/my_user_provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import '../video_player_screen.dart';

class ChatVideoMessageItem extends ConsumerStatefulWidget {
  final int messageId;
  final String videoUrl;
  final bool isSelf;
  final String avatarUrl;
  final String? nickname;
  final Vip? vip; // Changed from vipLogoUrl to Vip object
  final String? userId;
  final DateTime createdAt;
  final bool showFailed;
  final bool resending;
  final bool hasRead;
  final VoidCallback? onResend;
  final VoidCallback? onRead;

  const ChatVideoMessageItem({
    super.key,
    required this.videoUrl,
    required this.isSelf,
    required this.avatarUrl,
    required this.messageId,
    this.nickname,
    this.vip, // Changed from vipLogoUrl to vip
    this.userId,
    required this.createdAt,
    this.showFailed = true,
    this.resending = false,
    this.onResend,
    this.hasRead = false,
    this.onRead,
  });

  @override
  ConsumerState<ChatVideoMessageItem> createState() =>
      _ChatVideoMessageItemState();
}

class _ChatVideoMessageItemState extends ConsumerState<ChatVideoMessageItem> {
  String? _thumbnailPath;
  bool _isGeneratingThumbnail = false;

  @override
  void initState() {
    super.initState();
    _generateThumbnail();
  }

  @override
  void didUpdateWidget(ChatVideoMessageItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl != widget.videoUrl) {
      _generateThumbnail();
    }
  }

  Future<void> _generateThumbnail() async {
    if (_isGeneratingThumbnail) return;

    setState(() {
      _isGeneratingThumbnail = true;
    });

    try {
      final tempDir = await getTemporaryDirectory();
      final thumbnailPath = await VideoThumbnail.thumbnailFile(
        video: widget.videoUrl,
        thumbnailPath: tempDir.path,
        imageFormat: ImageFormat.PNG,
        maxHeight: 300,
        quality: 75,
      );

      if (mounted && thumbnailPath != null) {
        setState(() {
          _thumbnailPath = thumbnailPath;
          _isGeneratingThumbnail = false;
        });
      }
    } catch (e) {
      debugPrint("Error generating thumbnail: $e");
      if (mounted) {
        setState(() {
          _isGeneratingThumbnail = false;
        });
      }
    }
  }

  void _openVideoPlayer() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoPlayerScreen(
          videoUrl: widget.videoUrl,
          isNetwork: widget.videoUrl.startsWith('http'),
        ),
      ),
    );
  }

  Widget _buildVideoThumbnail() {
    if (_thumbnailPath != null) {
      return Image.file(
        File(_thumbnailPath!),
        width: 200,
        height: 200,
        fit: BoxFit.cover,
      );
    } else if (_isGeneratingThumbnail) {
      return Container(
        width: 200,
        height: 200,
        color: Colors.grey[800],
        child: const Center(
          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
        ),
      );
    } else {
      return Container(
        width: 200,
        height: 200,
        color: Colors.grey[800],
        child: const Center(
          child: Icon(Icons.videocam_off, color: Colors.white, size: 40),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userProvider);
    final userVip = userState.user?.vip;
    final bubbleColor = const Color.fromARGB(255, 32, 32, 32);
    return VisibilityDetector(
      key: Key("video_${widget.videoUrl.hashCode}_${widget.messageId}"),
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
                                  GestureDetector(
                                    onTap: widget.resending
                                        ? null
                                        : _openVideoPlayer,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child: _buildVideoThumbnail(),
                                        ),
                                        // Play button overlay
                                        if (!widget.resending)
                                          Container(
                                            width: 60,
                                            height: 60,
                                            decoration: BoxDecoration(
                                              color: Colors.black.withOpacity(
                                                0.6,
                                              ),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.play_arrow_rounded,
                                              color: Colors.white,
                                              size: 40,
                                            ),
                                          ),
                                        // Resending overlay
                                        if (widget.resending)
                                          Container(
                                            width: 200,
                                            height: 200,
                                            decoration: BoxDecoration(
                                              color: Colors.black.withOpacity(
                                                0.5,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
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
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    formatMessageTime(widget.createdAt),
                                    style: const TextStyle(
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
}
