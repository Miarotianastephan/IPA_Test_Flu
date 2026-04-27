import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/provider/api_provider.dart';
import 'package:live_app/utils/hls_video_utils.dart';
import 'package:uuid/uuid.dart';
import 'package:web/web.dart' as web;

export 'package:live_app/widgets/video/web_encrypted_video_player_stub.dart'
    show WebAdVideoPlayer;

class WebAdVideoPlayer extends ConsumerStatefulWidget {
  final String videoUrl;
  final String encryptionKey;
  final String videoId;
  final VoidCallback? onVideoEnded;

  const WebAdVideoPlayer({
    super.key,
    required this.videoUrl,
    required this.encryptionKey,
    required this.videoId,
    this.onVideoEnded,
  });

  @override
  ConsumerState<WebAdVideoPlayer> createState() => _WebAdVideoPlayerState();
}

class _WebAdVideoPlayerState extends ConsumerState<WebAdVideoPlayer> {
  final String _viewId = 'ad-video-${const Uuid().v4()}';
  bool _isLoading = true;
  String? _error;
  HlsJS? _hls;
  web.HTMLVideoElement? _videoElement;
  String? _blobUrl;
  bool _hasEnded = false;

  @override
  void initState() {
    super.initState();
    _registerViewFactory();
    _initializePlayback();
  }

  void _registerViewFactory() {
    ui_web.platformViewRegistry.registerViewFactory(_viewId, (int viewId) {
      final video = web.document.createElement('video') as web.HTMLVideoElement
        ..id = 'video-$_viewId'
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.backgroundColor = 'black'
        ..controls = false
        ..autoplay = true
        ..playsInline = true;

      _videoElement = video;
      return video;
    });
  }

  void _setupVideoListeners() {
    if (_videoElement == null) return;

    _videoElement!.onEnded.listen((_) {
      if (!_hasEnded && mounted) {
        _hasEnded = true;
        widget.onVideoEnded?.call();
      }
    });

    _videoElement!.onError.listen((_) {
      final error = _videoElement!.error;
      if (error != null && mounted) {
        debugPrint('[debugAd] WebAdVideoPlayer: Error - ${error.message}');
        setState(() {
          _error = 'Video playback error';
        });
      }
    });
  }

  @override
  void dispose() {
    _hls?.destroy();
    _hls = null;
    if (_blobUrl != null) {
      web.URL.revokeObjectURL(_blobUrl!);
    }
    super.dispose();
  }

  Future<void> _initializePlayback() async {
    try {
      final playbackInfo = await ref
          .read(videoServiceProvider)
          .playVideo(videoUrl: widget.videoUrl, key: widget.encryptionKey);

      final rewrittenM3u8 = rewriteM3u8WithAbsoluteUrls(
        playbackInfo.m3u8Content,
        widget.videoUrl,
      );

      if (isIOS() || supportsNativeHls()) {
        final base64Content = base64Encode(utf8.encode(rewrittenM3u8));
        _blobUrl = 'data:application/x-mpegURL;base64,$base64Content';
      } else {
        final blob = web.Blob(
          [rewrittenM3u8.toJS].toJS,
          web.BlobPropertyBag(type: 'application/x-mpegURL'),
        );
        _blobUrl = web.URL.createObjectURL(blob);
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _initializeHls();
          _setupVideoListeners();
        });
      }
    } catch (e) {
      debugPrint('[debugAd] WebAdVideoPlayer: Error initializing - $e');
      if (mounted) {
        setState(() {
          _error = 'Error loading video: $e';
          _isLoading = false;
        });
      }
    }
  }

  void _initializeHls() {
    if (_videoElement == null || _blobUrl == null) {
      return;
    }

    try {
      final hlsSupported = HlsJS.isSupported();

      if (hlsSupported) {
        _hls = HlsJS();
        _hls!.on(
          'hlsError',
          ((JSAny event, JSAny data) {
            debugPrint('[debugAd] WebAdVideoPlayer: HLS error');
          }).toJS,
        );
        _hls!.loadSource(_blobUrl!);
        _hls!.attachMedia(_videoElement!);
      } else if (supportsNativeHls()) {
        _videoElement!.src = _blobUrl!;
        _videoElement!.load();
      } else {
        _videoElement!.src = _blobUrl!;
      }
    } catch (e) {
      debugPrint('[debugAd] WebAdVideoPlayer: Failed to initialize HLS - $e');
      setState(() {
        _error = 'Failed to initialize player';
      });
    }
  }

  Future<void> _retry() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    await _initializePlayback();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 48),
            const SizedBox(height: 16),
            Text(
              'Playback Error',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _error!,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.white70),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _retry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return HtmlElementView(viewType: _viewId);
  }
}
