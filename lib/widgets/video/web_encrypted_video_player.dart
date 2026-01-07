import 'dart:js_interop';
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/provider/api_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:web/web.dart' as web;

@JS('Hls')
extension type HlsJS._(JSObject _) implements JSObject {
  external factory HlsJS();
  external static bool isSupported();
  external void loadSource(String src);
  external void attachMedia(web.HTMLVideoElement video);
  external void destroy();
  external void on(String event, JSFunction callback);
}

@JS('JSON.stringify')
external String _jsonStringify(JSAny? obj);

class WebEncryptedVideoPlayer extends ConsumerStatefulWidget {
  final String videoUrl;
  final String encryptionKey;

  const WebEncryptedVideoPlayer({
    super.key,
    required this.videoUrl,
    required this.encryptionKey,
  });

  @override
  ConsumerState<WebEncryptedVideoPlayer> createState() =>
      _WebEncryptedVideoPlayerState();
}

class _WebEncryptedVideoPlayerState
    extends ConsumerState<WebEncryptedVideoPlayer> {
  final String _viewId = 'hls-video-${const Uuid().v4()}';
  bool _isLoading = true;
  String? _error;
  HlsJS? _hls;
  web.HTMLVideoElement? _videoElement;
  String? _blobUrl;

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
        ..controls = true
        ..autoplay = true;

      _videoElement = video;
      return video;
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

      final blob = web.Blob(
        [playbackInfo.m3u8Content.toJS].toJS,
        web.BlobPropertyBag(type: 'application/x-mpegURL'),
      );
      _blobUrl = web.URL.createObjectURL(blob);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _initializeHls();
        });
      }
    } catch (e, stack) {
      debugPrint('[WebEncryptedVideoPlayer] Error initializing playback: $e');
      debugPrint('[WebEncryptedVideoPlayer] Stack trace: $stack');
      if (mounted) {
        setState(() {
          _error = e.toString();
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
      if (HlsJS.isSupported()) {
        _hls = HlsJS();

        _hls!.on(
          'hlsError',
          ((JSAny event, JSAny data) {
            final errorDetails = _jsonStringify(data);
            debugPrint('[WebEncryptedVideoPlayer] HLS Error: $errorDetails');
          }).toJS,
        );

        _hls!.loadSource(_blobUrl!);
        _hls!.attachMedia(_videoElement!);
      } else {
        _videoElement!.src = _blobUrl!;
      }
    } catch (e) {
      debugPrint('[WebEncryptedVideoPlayer] Error initializing HLS: $e');
      setState(() {
        _error = 'Failed to initialize video player: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text('Error loading video: $_error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _error = null;
                });
                _initializePlayback();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return HtmlElementView(viewType: _viewId);
  }
}
