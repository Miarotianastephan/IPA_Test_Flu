import 'package:flutter/foundation.dart';
import 'package:live_app/api/services/video_service.dart';
import 'package:live_app/models/ad_video.dart';
import 'package:live_app/services/hls_proxy_server.dart';
import 'package:uuid/uuid.dart';

class PreloadedAdVideo {
  final String videoUrl;
  final String proxyUrl;
  final String sessionId;

  PreloadedAdVideo({
    required this.videoUrl,
    required this.proxyUrl,
    required this.sessionId,
  });
}

class AdVideoPreloadService {
  final VideoService videoService;
  final Map<String, PreloadedAdVideo> _preloadedVideos = {};
  final Set<String> _preloadingUrls = {};

  AdVideoPreloadService(this.videoService);

  bool isPreloaded(String videoUrl) {
    return _preloadedVideos.containsKey(videoUrl);
  }

  PreloadedAdVideo? getPreloaded(String videoUrl) {
    return _preloadedVideos[videoUrl];
  }

  Future<void> preloadAdVideos(List<AdVideo> ads, String encryptionKey) async {
    for (final ad in ads) {
      if (ad.videoUrl != null) {
        await preloadVideo(ad.videoUrl!, encryptionKey);
      }
    }
  }

  Future<PreloadedAdVideo?> preloadVideo(
    String videoUrl,
    String encryptionKey,
  ) async {
    if (_preloadedVideos.containsKey(videoUrl)) {
      return _preloadedVideos[videoUrl];
    }

    if (_preloadingUrls.contains(videoUrl)) {
      return null;
    }

    _preloadingUrls.add(videoUrl);

    try {
      HlsProxyServer.instance.acquire();
      await HlsProxyServer.instance.start();

      // Fetch the m3u8 content
      final playbackInfo = await videoService.playVideo(
        videoUrl: videoUrl,
        key: encryptionKey,
      );

      // Register with proxy server
      final sessionId = const Uuid().v4();
      final proxyUrl = HlsProxyServer.instance.registerPlaylist(
        sessionId,
        playbackInfo.m3u8Content,
        baseUrl: videoUrl,
      );

      final preloaded = PreloadedAdVideo(
        videoUrl: videoUrl,
        proxyUrl: proxyUrl,
        sessionId: sessionId,
      );

      _preloadedVideos[videoUrl] = preloaded;

      return preloaded;
    } catch (e) {
      debugPrint('[debugAd]❌ Failed to preload ad video: $e');
      return null;
    } finally {
      _preloadingUrls.remove(videoUrl);
    }
  }

  void clearPreloaded(String videoUrl) {
    final preloaded = _preloadedVideos.remove(videoUrl);
    if (preloaded != null) {
      HlsProxyServer.instance.unregisterPlaylist(preloaded.sessionId);
      HlsProxyServer.instance.release();
    }
  }

  void clearAll() {
    for (final preloaded in _preloadedVideos.values) {
      HlsProxyServer.instance.unregisterPlaylist(preloaded.sessionId);
      HlsProxyServer.instance.release();
    }
    _preloadedVideos.clear();
  }
}
