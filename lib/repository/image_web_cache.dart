import 'dart:js_interop';
import 'dart:typed_data';
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

    final indexedDB = web.window.indexedDB;
    final request = indexedDB.open(dbName, dbVersion);

    request.onupgradeneeded = (web.IDBVersionChangeEvent event) {
      final db = request.result as web.IDBDatabase;
      if (!db.objectStoreNames.contains(storeName)) {
        db.createObjectStore(storeName);
      }
    }.toJS;

    request.onsuccess = (web.Event event) {
      _db = request.result as web.IDBDatabase;
      completer.complete();
    }.toJS;

    request.onerror = (web.Event event) {
      completer.completeError('Failed to open IndexedDB');
    }.toJS;

    return completer.future;
  }

  Future<Uint8List?> get(String url) async {
    try {
      await init();
      if (_db == null) return null;

      final completer = Completer<Uint8List?>();
      final transaction = _db!.transaction(storeName.toJS, 'readonly');
      final store = transaction.objectStore(storeName);
      final request = store.get(url.toJS);

      request.onsuccess = (web.Event event) {
        final result = request.result;
        if (result != null && !result.isUndefinedOrNull) {
          completer.complete((result as JSUint8Array).toDart);
        } else {
          completer.complete(null);
        }
      }.toJS;

      request.onerror = (web.Event event) {
        completer.complete(null);
      }.toJS;

      return completer.future;
    } catch (e) {
      return null;
    }
  }

  Future<void> put(String url, Uint8List bytes) async {
    try {
      await init();
      if (_db == null) return;

      final completer = Completer<void>();
      final transaction = _db!.transaction(storeName.toJS, 'readwrite');
      final store = transaction.objectStore(storeName);

      final request = store.put(bytes.toJS, url.toJS);

      request.onsuccess = (web.Event event) {
        completer.complete();
      }.toJS;

      request.onerror = (web.Event event) {
        completer.completeError('Failed to store image in IndexedDB');
      }.toJS;

      return completer.future;
    } catch (e) {
      // Ignore write failures and fall back to network on next request.
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
        completer.complete();
      }.toJS;

      request.onerror = (web.Event event) {
        completer.completeError('Failed to clear IndexedDB');
      }.toJS;

      return completer.future;
    } catch (e) {
      // Ignore clear failures; cache cleanup is best-effort on web.
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
      return 0;
    }
  }
}
