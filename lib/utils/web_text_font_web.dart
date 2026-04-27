import 'dart:js_interop';

import 'package:flutter/services.dart';
import 'package:web/web.dart' as web;

@JS('__detectPureIosSafari')
external bool _detectPureIosSafari();

const miniTexFontFamily = 'MiniTex';
const iosSafariCjkLiteFontFamily = 'IosSafariCJKLite';
const _iosSafariCjkLiteFontUrl = 'fonts/ios-safari-cjk-lite.woff2';

Future<void>? _iosSafariCjkLiteFontLoad;
bool _iosSafariCjkLiteFontLoaded = false;

String? getEffectiveWebTextFontFamily() {
  if (!isPureIosSafariWeb) {
    return miniTexFontFamily;
  }
  return _iosSafariCjkLiteFontLoaded ? iosSafariCjkLiteFontFamily : null;
}

bool get isPureIosSafariWeb {
  return _detectPureIosSafari();
}

Future<void> loadIosSafariCjkLiteFontIfNeeded() {
  if (!isPureIosSafariWeb) {
    return Future<void>.value();
  }

  return _iosSafariCjkLiteFontLoad ??= _loadIosSafariCjkLiteFont();
}

Future<void> _loadIosSafariCjkLiteFont() async {
  final fontData = _fetchIosSafariCjkLiteFontData();
  final fontLoader = FontLoader(iosSafariCjkLiteFontFamily)..addFont(fontData);
  await fontLoader.load();
  _iosSafariCjkLiteFontLoaded = true;
}

Future<ByteData> _fetchIosSafariCjkLiteFontData() async {
  final response = await web.window.fetch(_iosSafariCjkLiteFontUrl.toJS).toDart;
  if (!response.ok) {
    throw StateError(
      'Failed to load $_iosSafariCjkLiteFontUrl: HTTP ${response.status}',
    );
  }
  final arrayBuffer = await response.arrayBuffer().toDart;
  return ByteData.view(arrayBuffer.toDart);
}
