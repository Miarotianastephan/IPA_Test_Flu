import 'dart:js_interop';
import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;
import 'dart:async';

class ImageWebCache {
  static const String dbName = 'image_cache_db';
  static const String storeName = 'images';
  static const int dbVersion = 2;

  web.IDBDatabase? _db;
  Future<void>? _initFuture;

  Future<void> init() async {
    if (_db != null) return;
    if (_initFuture != null) return _initFuture;

    _initFuture = _init();
    try {
      await _initFuture;
    } finally {
      _initFuture = null;
    }
  }

  Future<void> _init() async {
    final completer = Completer<void>();
    debugPrint('[ImageWebCache] Opening IndexedDB: $dbName (v$dbVersion)');

    final indexedDB = web.window.indexedDB;
    final request = indexedDB.open(dbName, dbVersion);

    request.onupgradeneeded = (web.IDBVersionChangeEvent event) {
      debugPrint('[ImageWebCache] Database upgrade needed');
      final db = request.result as web.IDBDatabase;
      if (!db.objectStoreNames.contains(storeName)) {
        debugPrint('[ImageWebCache] Creating object store: $storeName');
        db.createObjectStore(storeName);
      }
    }.toJS;

    request.onsuccess = (web.Event event) {
      debugPrint('[ImageWebCache] Database opened successfully');
      _db = request.result as web.IDBDatabase;
      completer.complete();
    }.toJS;

    request.onerror = (web.Event event) {
      debugPrint('[ImageWebCache] Failed to open database: ${request.error}');
      completer.completeError('Failed to open IndexedDB');
    }.toJS;

    return completer.future;
  }

  Future<String?> get(String url) async {
    try {
      await init();
      if (_db == null) return null;

      final completer = Completer<String?>();
      final transaction = _db!.transaction(storeName.toJS, 'readonly');
      final store = transaction.objectStore(storeName);
      final request = store.get(url.toJS);

      request.onsuccess = (web.Event event) {
        final result = request.result;
        if (result != null && !result.isUndefinedOrNull) {
          debugPrint('[ImageWebCache] Cache hit for $url');
          completer.complete((result as JSString).toDart);
        } else {
          debugPrint('[ImageWebCache] Cache miss for $url');
          completer.complete(null);
        }
      }.toJS;

      request.onerror = (web.Event event) {
        debugPrint('[ImageWebCache] Error during get: ${request.error}');
        completer.complete(null);
      }.toJS;

      return completer.future;
    } catch (e) {
      debugPrint('[ImageWebCache] Exception in get: $e');
      return null;
    }
  }

  Future<void> put(String url, String base64) async {
    try {
      await init();
      if (_db == null) return;

      final completer = Completer<void>();
      final transaction = _db!.transaction(storeName.toJS, 'readwrite');
      final store = transaction.objectStore(storeName);

      debugPrint('[ImageWebCache] Storing image in IndexedDB for $url');
      final request = store.put(base64.toJS, url.toJS);

      request.onsuccess = (web.Event event) {
        debugPrint('[ImageWebCache] Successfully stored image in IndexedDB');
        completer.complete();
      }.toJS;

      request.onerror = (web.Event event) {
        debugPrint('[ImageWebCache] Error during put: ${request.error}');
        completer.completeError('Failed to store image in IndexedDB');
      }.toJS;

      return completer.future;
    } catch (e) {
      debugPrint('[ImageWebCache] Exception in put: $e');
    }
  }

  Future<void> clear() async {
    try {
      await init();
      if (_db == null) return;

      final completer = Completer<void>();
      final transaction = _db!.transaction(storeName.toJS, 'readwrite');
      final store = transaction.objectStore(storeName);
      final request = store.clear();

      request.onsuccess = (web.Event event) {
        debugPrint('[ImageWebCache] Successfully cleared IndexedDB');
        completer.complete();
      }.toJS;

      request.onerror = (web.Event event) {
        debugPrint('[ImageWebCache] error during clear: ${request.error}');
        completer.completeError('Failed to clear IndexedDB');
      }.toJS;

      return completer.future;
    } catch (e) {
      debugPrint('[ImageWebCache] Exception in clear: $e');
    }
  }

  Future<int> getCount() async {
    try {
      await init();
      if (_db == null) return 0;

      final completer = Completer<int>();
      final transaction = _db!.transaction(storeName.toJS, 'readonly');
      final store = transaction.objectStore(storeName);
      final request = store.count();

      request.onsuccess = (web.Event event) {
        completer.complete((request.result as JSNumber).toDartInt);
      }.toJS;

      request.onerror = (web.Event event) {
        completer.complete(0);
      }.toJS;

      return completer.future;
    } catch (e) {
      debugPrint('[ImageWebCache] Exception in getCount: $e');
      return 0;
    }
  }
}
