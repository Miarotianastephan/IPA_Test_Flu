import 'dart:js_interop';
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

@JS('startCanvasRenderLoop')
external JSFunction startCanvasRenderLoop(
  web.HTMLVideoElement video,
  web.HTMLCanvasElement canvas,
);

bool isIOS() {
  final userAgent = web.window.navigator.userAgent.toLowerCase();
  return userAgent.contains('iphone') ||
      userAgent.contains('ipad') ||
      (userAgent.contains('macintosh') &&
          web.window.navigator.maxTouchPoints > 0);
}

bool isAndroid() {
  final userAgent = web.window.navigator.userAgent.toLowerCase();
  return userAgent.contains('android');
}

bool isMobile() {
  return isIOS() || isAndroid();
}

bool supportsNativeHls() {
  final video = web.document.createElement('video') as web.HTMLVideoElement;
  final result = video.canPlayType('application/vnd.apple.mpegurl');
  return result != '';
}

String rewriteM3u8WithAbsoluteUrls(String m3u8Content, String baseUrl) {
  final baseUri = Uri.parse(baseUrl);
  final basePath = baseUri.path.substring(0, baseUri.path.lastIndexOf('/') + 1);
  final baseUrlWithoutPath =
      '${baseUri.scheme}://${baseUri.host}${baseUri.hasPort ? ':${baseUri.port}' : ''}';

  final lines = m3u8Content.split('\n');
  final rewrittenLines = <String>[];

  for (var line in lines) {
    line = line.trim();

    if (line.isEmpty) {
      rewrittenLines.add(line);
      continue;
    }

    if (line.startsWith('#EXT-X-KEY:')) {
      final rewrittenLine = rewriteKeyLine(line, baseUrlWithoutPath, basePath);
      rewrittenLines.add(rewrittenLine);
      continue;
    }

    if (!line.startsWith('#')) {
      final absoluteUrl = resolveUrl(line, baseUrlWithoutPath, basePath);
      rewrittenLines.add(absoluteUrl);
      continue;
    }

    rewrittenLines.add(line);
  }

  return rewrittenLines.join('\n');
}

String rewriteKeyLine(String line, String baseUrlWithoutPath, String basePath) {
  final uriMatch = RegExp(r'URI="([^"]+)"').firstMatch(line);
  if (uriMatch == null) return line;

  final originalUri = uriMatch.group(1)!;

  if (originalUri.startsWith('data:')) {
    return line;
  }

  final absoluteUrl = resolveUrl(originalUri, baseUrlWithoutPath, basePath);
  return line.replaceFirst('URI="$originalUri"', 'URI="$absoluteUrl"');
}

String resolveUrl(String url, String baseUrlWithoutPath, String basePath) {
  if (url.startsWith('http://') || url.startsWith('https://')) {
    return url;
  }

  if (url.startsWith('/')) {
    return '$baseUrlWithoutPath$url';
  }

  return '$baseUrlWithoutPath$basePath$url';
}
