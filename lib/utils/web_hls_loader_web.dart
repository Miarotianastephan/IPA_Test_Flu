import 'dart:js_interop';

@JS('loadMediaKitHls')
external JSPromise<JSAny?>? _loadMediaKitHls();

Future<void> preloadWebHlsForHome() async {
  await _loadMediaKitHls()?.toDart;
}
