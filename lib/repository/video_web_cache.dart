import 'dart:async';
import 'package:web/web.dart' as web;
import 'dart:js_interop';

class VideoWebCache {
  static const String dbName = 'video_cache_db';
  static const String storeName = 'videos';
  static const int dbVersion = 1;

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

  Future<web.IDBDatabase> _openDatabase() async {
    final completer = Completer<web.IDBDatabase>();
    final request = web.window.indexedDB.open(dbName, dbVersion);

    request.onupgradeneeded = (web.IDBVersionChangeEvent e) {
      final db = request.result as web.IDBDatabase;
      if (!db.objectStoreNames.contains(storeName)) {
        db.createObjectStore(storeName);
      }
    }.toJS;

    request.onsuccess = (web.Event e) {
      completer.complete(request.result as web.IDBDatabase);
    }.toJS;

    request.onerror = (web.Event e) {
      completer.completeError('Failed to open IndexedDB');
    }.toJS;

    return completer.future;
  }

  Future<void> _init() async {
    _db = await _openDatabase();
  }

  Future<void> put(String url, String base64Data) async {
    await init();
    final completer = Completer<void>();
    final transaction = _db!.transaction(storeName.toJS, 'readwrite');
    final store = transaction.objectStore(storeName);
    final request = store.put(base64Data.toJS, url.toJS);

    request.onsuccess = (web.Event e) {
      completer.complete();
    }.toJS;
    request.onerror = (web.Event e) {
      completer.completeError('Put failed');
    }.toJS;

    return completer.future;
  }

  Future<String?> get(String url) async {
    await init();
    final completer = Completer<String?>();
    final transaction = _db!.transaction(storeName.toJS, 'readonly');
    final store = transaction.objectStore(storeName);
    final request = store.get(url.toJS);

    request.onsuccess = (web.Event e) {
      final result = request.result;
      if (result != null) {
        completer.complete((result as JSString).toDart);
      } else {
        completer.complete(null);
      }
    }.toJS;

    request.onerror = (web.Event e) {
      completer.complete(null);
    }.toJS;

    return completer.future;
  }

  Future<void> clear() async {
    await init();
    final completer = Completer<void>();
    final transaction = _db!.transaction(storeName.toJS, 'readwrite');
    final store = transaction.objectStore(storeName);
    final request = store.clear();

    request.onsuccess = (web.Event e) {
      completer.complete();
    }.toJS;
    request.onerror = (web.Event e) {
      completer.completeError('Clear failed');
    }.toJS;

    return completer.future;
  }
}
