import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart' as dio_lib;
import 'package:flutter/foundation.dart';

class HlsProxyServer {
  static HlsProxyServer? _instance;
  static HlsProxyServer get instance => _instance ??= HlsProxyServer._();

  HlsProxyServer._();

  HttpServer? _server;
  int? _port;
  int _refCount = 0;
  Completer<void>? _startCompleter;
  bool _isStarting = false;

  final Map<String, String> _playlists = {};
  final Map<String, String> _baseUrls = {};
  final Map<String, Map<String, String>> _headers = {};
  final Map<String, int> _totalSegments = {};
  final Map<String, int> _servedSegments = {};
  final dio_lib.Dio _dio = dio_lib.Dio();

  int? get port => _port;
  bool get isRunning => _server != null;

  void acquire() {
    _refCount++;
  }

  Future<void> release() async {
    _refCount--;
    if (_refCount <= 0) {
      _refCount = 0;
      await stop();
    }
  }

  Future<int> start() async {
    if (_server != null && _port != null) {
      return _port!;
    }

    if (_isStarting && _startCompleter != null) {
      await _startCompleter!.future;
      return _port!;
    }

    _isStarting = true;
    _startCompleter = Completer<void>();

    try {
      _server = await HttpServer.bind(
        InternetAddress.loopbackIPv4,
        0,
        shared: true,
      );

      _port = _server!.port;

      _server!.listen(_handleRequest);

      if (_startCompleter != null && !_startCompleter!.isCompleted) {
        _startCompleter!.complete();
      }

      return _port!;
    } catch (e) {
      _isStarting = false;
      rethrow;
    }
  }

  Future<void> stop() async {
    if (_server == null) return;

    await _server!.close(force: true);
    _server = null;
    _port = null;
    _isStarting = false;
    _playlists.clear();
    _baseUrls.clear();
    _headers.clear();
    _totalSegments.clear();
    _servedSegments.clear();
  }

  String registerPlaylist(
    String sessionId,
    String m3u8Content, {
    String? baseUrl,
    Map<String, String>? requestHeaders,
  }) {
    if (baseUrl != null) {
      _baseUrls[sessionId] = baseUrl;
    }
    if (requestHeaders != null) {
      _headers[sessionId] = requestHeaders;
    }

    final rewrittenContent = _rewriteM3u8(sessionId, m3u8Content, baseUrl);
    _playlists[sessionId] = rewrittenContent;

    _servedSegments[sessionId] = 0;

    final url = 'http://127.0.0.1:$_port/playlist/$sessionId.m3u8';
    return url;
  }

  double getProgress(String sessionId) {
    final total = _totalSegments[sessionId] ?? 0;
    final served = _servedSegments[sessionId] ?? 0;
    if (total == 0) return 0;
    return (served / total * 100).clamp(0, 100);
  }

  void unregisterPlaylist(String sessionId) {
    _playlists.remove(sessionId);
    _baseUrls.remove(sessionId);
    _headers.remove(sessionId);
    _totalSegments.remove(sessionId);
    _servedSegments.remove(sessionId);
  }

  Future<void> _handleRequest(HttpRequest request) async {
    final path = request.uri.path;

    request.response.headers.add('Access-Control-Allow-Origin', '*');
    request.response.headers.add(
      'Access-Control-Allow-Methods',
      'GET, OPTIONS',
    );
    request.response.headers.add('Access-Control-Allow-Headers', '*');

    if (request.method == 'OPTIONS') {
      request.response.statusCode = HttpStatus.ok;
      await request.response.close();
      return;
    }

    try {
      if (path.startsWith('/playlist/')) {
        await _handlePlaylistRequest(request);
      } else if (path.startsWith('/segment/')) {
        await _handleSegmentRequest(request);
      } else if (path.startsWith('/key/')) {
        await _handleKeyRequest(request);
      } else if (path == '/health') {
        request.response.statusCode = HttpStatus.ok;
        request.response.write('OK');
        await request.response.close();
      } else {
        request.response.statusCode = HttpStatus.notFound;
        request.response.write('Not Found');
        await request.response.close();
      }
    } catch (e) {
      request.response.statusCode = HttpStatus.internalServerError;
      request.response.write('Internal Server Error: $e');
      await request.response.close();
    }
  }

  Future<void> _handlePlaylistRequest(HttpRequest request) async {
    final path = request.uri.path;
    final match = RegExp(r'^/playlist/([^/]+)\.m3u8$').firstMatch(path);

    if (match == null) {
      request.response.statusCode = HttpStatus.notFound;
      request.response.write('Invalid playlist path');
      await request.response.close();
      return;
    }

    final sessionId = match.group(1)!;
    final m3u8Content = _playlists[sessionId];

    if (m3u8Content == null) {
      request.response.statusCode = HttpStatus.notFound;
      request.response.write('Session not found');
      await request.response.close();
      return;
    }

    request.response.headers.contentType = ContentType(
      'application',
      'vnd.apple.mpegurl',
    );
    request.response.headers.add(
      'Cache-Control',
      'no-cache, no-store, must-revalidate',
    );
    request.response.write(m3u8Content);
    await request.response.close();
  }

  Future<void> _handleSegmentRequest(HttpRequest request) async {
    final path = request.uri.path;
    final match = RegExp(r'^/segment/([^/]+)/(.+)$').firstMatch(path);

    if (match == null) {
      request.response.statusCode = HttpStatus.notFound;
      request.response.write('Invalid segment path');
      await request.response.close();
      return;
    }

    final sessionId = match.group(1)!;
    final encodedUrl = match.group(2)!;
    final segmentUrl = Uri.decodeComponent(encodedUrl);

    try {
      final headers = _headers[sessionId] ?? {};
      final response = await _dio.get<List<int>>(
        segmentUrl,
        options: dio_lib.Options(
          responseType: dio_lib.ResponseType.bytes,
          headers: headers,
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        request.response.headers.contentType = ContentType('video', 'mp2t');
        request.response.headers.add('Cache-Control', 'max-age=3600');
        request.response.headers.add('Cache-Control', 'max-age=3600');
        request.response.add(response.data!);
        await request.response.close();

        final current = _servedSegments[sessionId] ?? 0;
        _servedSegments[sessionId] = current + 1;
      } else {
        request.response.statusCode = HttpStatus.badGateway;
        request.response.write('Failed to fetch segment');
        await request.response.close();
      }
    } catch (e) {
      request.response.statusCode = HttpStatus.badGateway;
      request.response.write('Error fetching segment: $e');
      await request.response.close();
    }
  }

  Future<void> _handleKeyRequest(HttpRequest request) async {
    final path = request.uri.path;
    final match = RegExp(r'^/key/([^/]+)/(.+)$').firstMatch(path);

    if (match == null) {
      request.response.statusCode = HttpStatus.notFound;
      request.response.write('Invalid key path');
      await request.response.close();
      return;
    }

    final sessionId = match.group(1)!;
    final encodedUrl = match.group(2)!;
    final keyUrl = Uri.decodeComponent(encodedUrl);

    try {
      final headers = _headers[sessionId] ?? {};
      final response = await _dio.get<List<int>>(
        keyUrl,
        options: dio_lib.Options(
          responseType: dio_lib.ResponseType.bytes,
          headers: headers,
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        request.response.headers.contentType = ContentType(
          'application',
          'octet-stream',
        );
        request.response.headers.add('Cache-Control', 'max-age=3600');
        request.response.add(response.data!);
        await request.response.close();
      } else {
        request.response.statusCode = HttpStatus.badGateway;
        request.response.write('Failed to fetch key');
        await request.response.close();
      }
    } catch (e) {
      request.response.statusCode = HttpStatus.badGateway;
      request.response.write('Error fetching key: $e');
      await request.response.close();
    }
  }

  String _rewriteM3u8(String sessionId, String m3u8Content, String? baseUrl) {
    final lines = m3u8Content.split('\n');
    final rewrittenLines = <String>[];
    int segmentCount = 0;

    for (var line in lines) {
      line = line.trim();

      if (line.startsWith('#EXT-X-KEY:')) {
        final rewrittenLine = _rewriteKeyLine(sessionId, line, baseUrl);
        rewrittenLines.add(rewrittenLine);
      } else if (line.isNotEmpty &&
          !line.startsWith('#') &&
          (line.endsWith('.ts') ||
              line.contains('.ts?') ||
              line.endsWith('.aac') ||
              line.endsWith('.m4s') ||
              line.contains('.ts#'))) {
        final segmentUrl = _resolveUrl(line, baseUrl);
        final encodedUrl = Uri.encodeComponent(segmentUrl);
        final proxyUrl =
            'http://127.0.0.1:$_port/segment/$sessionId/$encodedUrl';
        rewrittenLines.add(proxyUrl);
        segmentCount++;
      } else {
        rewrittenLines.add(line);
      }
    }

    _totalSegments[sessionId] = segmentCount;

    return rewrittenLines.join('\n');
  }

  String _rewriteKeyLine(String sessionId, String line, String? baseUrl) {
    final uriMatch = RegExp(r'URI="([^"]+)"').firstMatch(line);
    if (uriMatch == null) return line;

    final originalUri = uriMatch.group(1)!;

    if (originalUri.startsWith('data:')) {
      return line;
    }

    final keyUrl = _resolveUrl(originalUri, baseUrl);
    final encodedUrl = Uri.encodeComponent(keyUrl);
    final proxyKeyUrl = 'http://127.0.0.1:$_port/key/$sessionId/$encodedUrl';

    return line.replaceFirst('URI="$originalUri"', 'URI="$proxyKeyUrl"');
  }

  String _resolveUrl(String url, String? baseUrl) {
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }

    if (baseUrl == null) {
      return url;
    }

    final baseUri = Uri.parse(baseUrl);
    if (url.startsWith('/')) {
      return '${baseUri.scheme}://${baseUri.host}${baseUri.hasPort ? ':${baseUri.port}' : ''}$url';
    } else {
      final basePath = baseUri.path.substring(
        0,
        baseUri.path.lastIndexOf('/') + 1,
      );
      return '${baseUri.scheme}://${baseUri.host}${baseUri.hasPort ? ':${baseUri.port}' : ''}$basePath$url';
    }
  }
}
