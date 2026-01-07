import 'dart:io';
import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../repository/audio_repository.dart';
import '../../utils/text_util.dart';
import '../encrypted_image.dart';
import 'waveform_widget.dart';

class ChatAudioMessageItem extends ConsumerStatefulWidget {
  final int messageId;
  final String audioUrl;
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

  const ChatAudioMessageItem({
    super.key,
    required this.audioUrl,
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
  ConsumerState<ChatAudioMessageItem> createState() =>
      _ChatAudioMessageItemState();
}

class _ChatAudioMessageItemState extends ConsumerState<ChatAudioMessageItem> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  String? _cachedAudioPath;

  @override
  void initState() {
    super.initState();
    _loadCachedAudio();
    _audioPlayer.onPlayerComplete.listen((event) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _position = Duration.zero;
        });
      }
    });
    _audioPlayer.onPositionChanged.listen((p) {
      if (mounted) {
        setState(() {
          _position = p;
        });
      }
    });
    _audioPlayer.onDurationChanged.listen((d) {
      if (mounted) {
        setState(() {
          _duration = d;
        });
      }
    });
  }

  @override
  void didUpdateWidget(ChatAudioMessageItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.audioUrl != widget.audioUrl) {
      _loadCachedAudio();
    }
  }

  Future<void> _loadCachedAudio() async {
    final audioRepo = ref.read(audioRepositoryProvider);

    final isUrl = widget.audioUrl.startsWith('http');

    if (isUrl) {
      final cache = await audioRepo.getAudioCache(widget.audioUrl);

      if (cache?.localPath != null) {
        final file = File(cache!.localPath!);
        final exists = await file.exists();

        if (exists && mounted) {
          setState(() {
            _cachedAudioPath = cache.localPath;
          });
          await _loadAudioDuration();
        } else {
          audioRepo.enqueueDownload(widget.audioUrl);
        }
      } else {
        audioRepo.enqueueDownload(widget.audioUrl);
      }
    } else {
      await _loadAudioDuration();
    }
  }

  Future<void> _loadAudioDuration() async {
    try {
      String audioPath = _cachedAudioPath ?? widget.audioUrl;

      final isLocalFile = !audioPath.startsWith('http');

      if (!isLocalFile) {
        return;
      }

      final file = File(audioPath);
      if (!await file.exists()) {
        return;
      }

      Source source = DeviceFileSource(audioPath);

      await _audioPlayer.setSource(source);
    } catch (e) {
      debugPrint('[ChatAudioMessageItem] Error loading audio duration: $e');
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playPause() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
      setState(() => _isPlaying = false);
    } else {
      String audioPath = widget.audioUrl;

      if (_cachedAudioPath != null) {
        audioPath = _cachedAudioPath!;
      }

      final isLocalFile = !audioPath.startsWith('http');

      if (isLocalFile) {
        final file = File(audioPath);
        final exists = await file.exists();

        if (!exists) {
          return;
        }
      }

      try {
        Source source = audioPath.startsWith('http')
            ? UrlSource(audioPath)
            : DeviceFileSource(audioPath);
        await _audioPlayer.play(source);
        setState(() => _isPlaying = true);
      } catch (e) {
        debugPrint("Error $e");
      }
    }
  }

  String _formatDuration(Duration duration) {
    if (duration.inSeconds < 0) return "00:00";
    final int min = duration.inMinutes;
    final int sec = duration.inSeconds % 60;
    return '${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final bubbleColor = const Color.fromARGB(255, 32, 32, 32);
    final textColor = Colors.white;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
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
                nickname: widget.nickname,
                userId: widget.userId,
                size: 40,
              ),
            ),
          const SizedBox(width: 8),
          Flexible(
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
                        fontSize: 13,
                      ),
                    ),
                  ),
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: bubbleColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Stack(
                        children: [
                          Column(
                            crossAxisAlignment: widget.isSelf
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  GestureDetector(
                                    onTap: widget.resending ? null : _playPause,
                                    child: Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: widget.isSelf
                                            ? Colors.white
                                            : Colors.white24,
                                        shape: BoxShape.circle,
                                      ),
                                      child: widget.resending
                                          ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: Center(
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      color: Colors.white,
                                                    ),
                                              ),
                                            )
                                          : Icon(
                                              _isPlaying
                                                  ? Icons.pause
                                                  : Icons.play_arrow,
                                              color: widget.isSelf
                                                  ? Colors.black54
                                                  : Colors.white,
                                              size: 22,
                                            ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  SizedBox(
                                    width: 140,
                                    child: Opacity(
                                      opacity: widget.resending ? 0.5 : 1.0,
                                      child: WaveformSlider(
                                        progress: _duration.inMilliseconds > 0
                                            ? (_position.inMilliseconds /
                                                      _duration.inMilliseconds)
                                                  .clamp(0.0, 1.0)
                                            : 0.0,
                                        height: 36,
                                        activeColor: Colors.white,
                                        inactiveColor: textColor.withOpacity(
                                          0.15,
                                        ),
                                        seed: widget
                                            .messageId, // Unique seed for each message
                                        onSeek: widget.resending
                                            ? null
                                            : (progress) {
                                                final seekTo =
                                                    _duration.inMilliseconds *
                                                    progress;
                                                _audioPlayer.seek(
                                                  Duration(
                                                    milliseconds: seekTo
                                                        .toInt(),
                                                  ),
                                                );
                                              },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _formatDuration(
                                      _position.inMilliseconds > 0
                                          ? _position
                                          : _duration,
                                    ),
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                formatMessageTime(widget.createdAt),
                                style: TextStyle(
                                  color: widget.isSelf
                                      ? Colors.white70
                                      : Colors.white54,
                                  fontSize: 11,
                                ),
                              ),
                            ],
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
          const SizedBox(width: 8),
          if (widget.isSelf)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: UserAvatar(
                url: widget.avatarUrl,
                nickname: widget.nickname,
                userId: widget.userId,
                size: 40,
              ),
            ),
        ],
      ),
    );
  }
}
