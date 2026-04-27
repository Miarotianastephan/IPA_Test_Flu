import 'dart:async';
import 'dart:collection';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;

import 'web_image_worker_models.dart';

final _WebImageWorkerClient _client = _WebImageWorkerClient();

bool get supportsWebImageWorker => _client.isAvailable;

WebImageLayoutData? getCachedWebImageLayout({
  required String url,
  required String encryptionKey,
}) {
  return _client.getCachedLayout(url: url, encryptionKey: encryptionKey);
}

WebImageDisplayData? getCachedWebImageDisplay({
  required String url,
  required String encryptionKey,
  int? targetWidth,
}) {
  return _client.getCachedDisplay(
    url: url,
    encryptionKey: encryptionKey,
    targetWidth: targetWidth,
  );
}

Future<WebImageLayoutData?> warmWebImageLayout({
  required String url,
  required String fileType,
  required String encryptionKey,
}) {
  return _client.loadLayout(
    url: url,
    fileType: fileType,
    encryptionKey: encryptionKey,
  );
}

Future<WebImageDisplayData?> loadWebImage({
  required String url,
  required String fileType,
  required String encryptionKey,
  int? targetWidth,
}) {
  return _client.loadImage(
    url: url,
    fileType: fileType,
    encryptionKey: encryptionKey,
    targetWidth: targetWidth,
  );
}

class _WebImageWorkerClient {
  static const int _layoutCacheEntries = 240;
  static const int _displayCacheEntries = 120;

  final LinkedHashMap<String, WebImageLayoutData> _layoutCache =
      LinkedHashMap<String, WebImageLayoutData>();
  final LinkedHashMap<String, WebImageDisplayData> _displayCache =
      LinkedHashMap<String, WebImageDisplayData>();
  final Map<String, Future<WebImageLayoutData>> _layoutFutures =
      <String, Future<WebImageLayoutData>>{};
  final Map<String, Future<WebImageDisplayData>> _displayFutures =
      <String, Future<WebImageDisplayData>>{};
  final Map<int, Completer<dynamic>> _pendingMessages =
      <int, Completer<dynamic>>{};

  web.Worker? _worker;
  bool _failed = false;
  int _nextMessageId = 1;

  _WebImageWorkerClient() {
    _initializeWorker();
  }

  bool get isAvailable => _isAvailable;

  bool get _hasRequiredWebCrypto {
    try {
      if (!web.window.isSecureContext) {
        return false;
      }

      final crypto = web.window.getProperty<JSObject?>('crypto'.toJS);
      final subtle = crypto?.getProperty<JSAny?>('subtle'.toJS);
      return subtle != null && !subtle.isUndefinedOrNull;
    } catch (_) {
      return false;
    }
  }

  bool get _isAvailable => !_failed && _worker != null && _hasRequiredWebCrypto;

  void _initializeWorker() {
    try {
      if (!_hasRequiredWebCrypto) {
        _failed = true;
        return;
      }

      final workerUrl = Uri.base.resolve('image_worker.js').toString();
      final worker = web.Worker(workerUrl.toJS);
      worker.onmessage = ((web.Event event) {
        _handleMessage(event as web.MessageEvent);
      }).toJS;
      worker.onerror = ((web.Event event) {
        _failed = true;
        final error = StateError('Web image worker failed');
        final pending = _pendingMessages.values.toList(growable: false);
        _pendingMessages.clear();
        for (final completer in pending) {
          if (!completer.isCompleted) {
            completer.completeError(error);
          }
        }
        debugPrint(error.toString());
      }).toJS;
      _worker = worker;
    } catch (e) {
      _failed = true;
      debugPrint('Failed to initialize web image worker: $e');
    }
  }

  void _handleMessage(web.MessageEvent event) {
    final payload = event.data;
    if (payload == null) {
      return;
    }

    final values = (payload as JSArray<JSAny?>).toDart;
    if (values.length < 7) {
      return;
    }

    final id = _intValue(values[0]);
    final completer = _pendingMessages.remove(id);
    if (completer == null || completer.isCompleted) {
      return;
    }

    final ok = _boolValue(values[1]);
    if (ok) {
      completer.complete(values);
      return;
    }

    final message = _stringValue(values[6], fallback: 'Unknown worker error');
    completer.completeError(StateError(message));
  }

  Future<dynamic> _postMessage(
    String action,
    Map<String, Object?> payload,
  ) async {
    if (!_isAvailable) {
      throw StateError('Web image worker is unavailable');
    }

    final id = _nextMessageId++;
    final completer = Completer<dynamic>();
    _pendingMessages[id] = completer;

    final message = <JSAny?>[
      id.toJS,
      action.toJS,
      (payload['url'] as String).toJS,
      (payload['fileType'] as String).toJS,
      (payload['encryptionKey'] as String).toJS,
      (payload['targetWidth'] as int?)?.toJS,
    ].toJS;

    _worker!.postMessage(message);
    return completer.future;
  }

  int? _bucketDimension(int? value) {
    if (value == null || value <= 0) {
      return null;
    }
    return ((value + 95) ~/ 96) * 96;
  }

  String _layoutCacheKey(String url, String encryptionKey) {
    return '$url::$encryptionKey';
  }

  String _displayCacheKeyWithEncryption(
    String url,
    String encryptionKey,
    int? targetWidth,
  ) {
    final bucket = _bucketDimension(targetWidth) ?? 0;
    return '${_layoutCacheKey(url, encryptionKey)}#$bucket';
  }

  bool _boolValue(JSAny? value, {bool fallback = false}) {
    if (value == null) {
      return fallback;
    }
    return (value as JSBoolean).toDart;
  }

  int _intValue(JSAny? value, {int fallback = 0}) {
    if (value == null) {
      return fallback;
    }
    return (value as JSNumber).toDartInt;
  }

  String _stringValue(JSAny? value, {String fallback = ''}) {
    if (value == null) {
      return fallback;
    }
    return (value as JSString).toDart;
  }

  WebImageLayoutData? getCachedLayout({
    required String url,
    required String encryptionKey,
  }) {
    final key = _layoutCacheKey(url, encryptionKey);
    final entry = _layoutCache.remove(key);
    if (entry == null) {
      return null;
    }
    _layoutCache[key] = entry;
    return entry;
  }

  void _putLayoutCache(
    String url,
    String encryptionKey,
    WebImageLayoutData entry,
  ) {
    final key = _layoutCacheKey(url, encryptionKey);
    _layoutCache.remove(key);
    _layoutCache[key] = entry;

    while (_layoutCache.length > _layoutCacheEntries) {
      _layoutCache.remove(_layoutCache.keys.first);
    }
  }

  WebImageDisplayData? getCachedDisplay({
    required String url,
    required String encryptionKey,
    int? targetWidth,
  }) {
    final key = _displayCacheKeyWithEncryption(url, encryptionKey, targetWidth);
    final entry = _displayCache.remove(key);
    if (entry == null) {
      return null;
    }
    _displayCache[key] = entry;
    return entry;
  }

  void _putDisplayCache(
    String url,
    String encryptionKey,
    int? targetWidth,
    WebImageDisplayData entry,
  ) {
    final key = _displayCacheKeyWithEncryption(url, encryptionKey, targetWidth);
    final previous = _displayCache.remove(key);
    if (previous?.objectUrl != null && previous!.objectUrl != entry.objectUrl) {
      web.URL.revokeObjectURL(previous.objectUrl!);
    }

    _displayCache[key] = entry;

    while (_displayCache.length > _displayCacheEntries) {
      final oldestKey = _displayCache.keys.first;
      final oldest = _displayCache.remove(oldestKey);
      if (oldest?.objectUrl != null) {
        web.URL.revokeObjectURL(oldest!.objectUrl!);
      }
    }
  }

  Future<WebImageLayoutData?> loadLayout({
    required String url,
    required String fileType,
    required String encryptionKey,
  }) async {
    final cached = getCachedLayout(url: url, encryptionKey: encryptionKey);
    if (cached != null) {
      return cached;
    }

    final cacheKey = _layoutCacheKey(url, encryptionKey);
    final existingFuture = _layoutFutures[cacheKey];
    if (existingFuture != null) {
      return existingFuture;
    }

    final future = _loadLayout(
      url: url,
      fileType: fileType,
      encryptionKey: encryptionKey,
    );
    _layoutFutures[cacheKey] = future;

    return future.whenComplete(() {
      _layoutFutures.remove(cacheKey);
    });
  }

  Future<WebImageLayoutData> _loadLayout({
    required String url,
    required String fileType,
    required String encryptionKey,
  }) async {
    final response = await _postMessage('loadLayout', <String, Object?>{
      'url': url,
      'fileType': fileType,
      'encryptionKey': encryptionKey,
    });

    if (response is! List<JSAny?> || response.length < 7) {
      throw StateError('Malformed layout response from worker');
    }

    final layout = WebImageLayoutData(
      isSvg: _boolValue(response[3]),
      width: _intValue(response[4], fallback: 3),
      height: _intValue(response[5], fallback: 4),
    );
    _putLayoutCache(url, encryptionKey, layout);
    return layout;
  }

  Future<WebImageDisplayData?> loadImage({
    required String url,
    required String fileType,
    required String encryptionKey,
    int? targetWidth,
  }) async {
    final cached = getCachedDisplay(
      url: url,
      encryptionKey: encryptionKey,
      targetWidth: targetWidth,
    );
    if (cached != null) {
      return cached;
    }

    final cacheKey = _displayCacheKeyWithEncryption(
      url,
      encryptionKey,
      targetWidth,
    );
    final existingFuture = _displayFutures[cacheKey];
    if (existingFuture != null) {
      return existingFuture;
    }

    final future = _loadImage(
      url: url,
      fileType: fileType,
      encryptionKey: encryptionKey,
      targetWidth: targetWidth,
    );
    _displayFutures[cacheKey] = future;

    return future.whenComplete(() {
      _displayFutures.remove(cacheKey);
    });
  }

  Future<WebImageDisplayData> _loadImage({
    required String url,
    required String fileType,
    required String encryptionKey,
    int? targetWidth,
  }) async {
    final response = await _postMessage('loadImage', <String, Object?>{
      'url': url,
      'fileType': fileType,
      'encryptionKey': encryptionKey,
      'targetWidth': _bucketDimension(targetWidth),
    });

    if (response is! List<JSAny?> || response.length < 7) {
      throw StateError('Malformed image response from worker');
    }

    final kind = _stringValue(response[2], fallback: 'error');
    final isSvg = _boolValue(response[3]);
    final width = _intValue(response[4], fallback: 3);
    final height = _intValue(response[5], fallback: 4);

    final layout = WebImageLayoutData(
      isSvg: isSvg,
      width: width,
      height: height,
    );
    _putLayoutCache(url, encryptionKey, layout);

    WebImageDisplayData result;
    if (kind == 'svg') {
      result = WebImageDisplayData(
        isSvg: true,
        width: width,
        height: height,
        svgText: response[6] == null ? null : _stringValue(response[6]),
      );
    } else {
      if (kind != 'raster') {
        throw StateError('Worker returned no blob for raster image');
      }
      final blob = response[6] as web.Blob;

      result = WebImageDisplayData(
        isSvg: false,
        width: width,
        height: height,
        objectUrl: web.URL.createObjectURL(blob),
      );
    }

    _putDisplayCache(url, encryptionKey, targetWidth, result);
    return result;
  }
}
