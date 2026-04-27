import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/video_info.dart';
import '../encrypted_image.dart';
import '../video_screen.dart';

class VideoPreviewCard extends StatefulWidget {
  final VideoInfo video;
  final double price;
  final int previewDuration;
  final int previewsRemaining;
  final VoidCallback onPreviewEnd;
  final String Function(String) translate;

  const VideoPreviewCard({
    super.key,
    required this.price,
    required this.video,
    required this.previewDuration,
    required this.previewsRemaining,
    required this.onPreviewEnd,
    required this.translate,
  });

  @override
  State<VideoPreviewCard> createState() => _VideoPreviewCardState();
}

class _VideoPreviewCardState extends State<VideoPreviewCard> {
  final ValueNotifier<bool> _videoPlayingNotifier = ValueNotifier<bool>(false);
  int _remainingSeconds = 0;
  Timer? _timer;
  bool _hasStarted = false;
  bool _previewEnded = false;
  bool _showCoverOnly = false;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.previewDuration;
    _videoPlayingNotifier.addListener(_onVideoPlayingChanged);
  }

  void _onVideoPlayingChanged() {
    if (!mounted) return;

    final isPlaying = _videoPlayingNotifier.value;
    if (!_hasStarted && isPlaying) {
      _startTimer();
    }
  }

  void _startTimer() {
    if (_hasStarted) return;
    _hasStarted = true;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        _remainingSeconds--;
      });

      if (_remainingSeconds <= 0) {
        _timer?.cancel();
        _onPreviewExpired();
      }
    });
  }

  void _onPreviewExpired() {
    if (_previewEnded) return;
    _previewEnded = true;
    setState(() {
      _showCoverOnly = true;
    });
    widget.onPreviewEnd();
  }

  @override
  void dispose() {
    _videoPlayingNotifier.removeListener(_onVideoPlayingChanged);
    _timer?.cancel();
    _videoPlayingNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                children: [
                  if (_showCoverOnly)
                    EncryptedImage(
                      url: widget.video.cover,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    )
                  else
                    VideoScreen(
                      encryptionKey: widget.video.encryptionKey,
                      vip: widget.video.user.vip,
                      videoUrl: widget.video.url,
                      videoId: widget.video.id,
                      playingNotifier: _videoPlayingNotifier,
                    ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_showCoverOnly)
                            const Icon(
                              Icons.lock,
                              color: Colors.white,
                              size: 14,
                            )
                          else if (!_hasStarted)
                            const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          else
                            const Icon(
                              Icons.preview,
                              color: Colors.white,
                              size: 14,
                            ),
                          const SizedBox(width: 6),
                          Text(
                            _showCoverOnly
                                ? widget.translate("previewEnded")
                                : _hasStarted
                                ? '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}'
                                : widget.translate("loadingVideo"),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          ExpandableTitle(title: widget.video.title),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Icon(
                  Icons.play_circle_outline,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.translate("freePreviewAvailable"),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  '${widget.previewsRemaining} ${widget.translate("previewsLeft")}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ExpandableTitle extends StatefulWidget {
  final String title;

  const ExpandableTitle({super.key, required this.title});

  @override
  State<ExpandableTitle> createState() => _ExpandableTitleState();
}

class _ExpandableTitleState extends State<ExpandableTitle> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          expanded = !expanded;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        width: double.infinity,
        decoration: const BoxDecoration(color: Colors.black),
        child: Text(
          widget.title,
          maxLines: expanded ? null : 2,
          overflow: expanded ? TextOverflow.visible : TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
