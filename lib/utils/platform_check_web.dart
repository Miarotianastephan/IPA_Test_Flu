import 'package:web/web.dart' as web;

bool isWebIOSImpl() {
  final ua = web.window.navigator.userAgent.toLowerCase();

  return ua.contains('iphone') ||
      ua.contains('ipad') ||
      ua.contains('ipod');
}