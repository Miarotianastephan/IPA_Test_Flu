import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/widgets/video/encrypted_hls_player.dart';
import 'package:live_app/widgets/video/web_encrypted_video_player_stub.dart'
    if (dart.library.html) 'package:live_app/widgets/video/web_ad_video_player.dart';

class AdVideoPlayerScreen extends ConsumerWidget {
  final String videoUrl;
  final String encryptionKey;
  final int duration;
  final VoidCallback onVideoFinished;
  final String? preloadedProxyUrl;
  final String? preloadedSessionId;

  const AdVideoPlayerScreen({
    super.key,
    required this.videoUrl,
    required this.encryptionKey,
    required this.duration,
    required this.onVideoFinished,
    this.preloadedProxyUrl,
    this.preloadedSessionId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _AdVideoPlayerScreenContent(
      videoUrl: videoUrl,
      encryptionKey: encryptionKey,
      duration: duration,
      onVideoFinished: onVideoFinished,
      preloadedProxyUrl: preloadedProxyUrl,
      preloadedSessionId: preloadedSessionId,
    );
  }
}

class _AdVideoPlayerScreenContent extends StatefulWidget {
  final String videoUrl;
  final String encryptionKey;
  final int duration;
  final VoidCallback onVideoFinished;
  final String? preloadedProxyUrl;
  final String? preloadedSessionId;

  const _AdVideoPlayerScreenContent({
    required this.videoUrl,
    required this.encryptionKey,
    required this.duration,
    required this.onVideoFinished,
    this.preloadedProxyUrl,
    this.preloadedSessionId,
  });

  @override
  State<_AdVideoPlayerScreenContent> createState() =>
      _AdVideoPlayerScreenContentState();
}

class _AdVideoPlayerScreenContentState
    extends State<_AdVideoPlayerScreenContent> {
  bool _isVideoFinished = false;
  Timer? _finishTimer;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _finishTimer?.cancel();
    super.dispose();
  }

  void _finishAd() {
    if (!_isVideoFinished && mounted) {
      _isVideoFinished = true;
      widget.onVideoFinished();
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Container(color: Colors.black54),

          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.height * 0.8,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    spreadRadius: 4,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  children: [
                    _buildVideoPlayer(),

                    Positioned(
                      top: 16,
                      right: 16,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextButton(
                          onPressed: _finishAd,
                          child: const Text(
                            'Skip Ad',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoPlayer() {
    if (kIsWeb) {
      return WebAdVideoPlayer(
        videoUrl: widget.videoUrl,
        encryptionKey: widget.encryptionKey,
        videoId: 'ad-video-${widget.videoUrl.hashCode}',
        onVideoEnded: _finishAd,
      );
    }

    return EncryptedHlsPlayer(
      videoUrl: widget.videoUrl,
      encryptionKey: widget.encryptionKey,
      videoId: 'ad-video-${widget.videoUrl.hashCode}',
      onVideoEnded: _finishAd,
      preloadedProxyUrl: widget.preloadedProxyUrl,
      preloadedSessionId: widget.preloadedSessionId,
      showPlayerControls: false,
    );
  }
}
