import 'dart:async';
import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';

class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  final _appLinks = AppLinks();
  StreamSubscription? _sub;
  final _controller = StreamController<Uri>.broadcast();
  Uri? _initialUri;
  Stream<Uri> get linkStream => _controller.stream;
  Uri? get initialUri => _initialUri;

  Future<void> init() async {
    try {
      final initialLink = await _appLinks.getInitialLink();
      if (initialLink != null) {
        _initialUri = initialLink;
        _controller.add(initialLink);
      }

      _sub = _appLinks.uriLinkStream.listen(
        (Uri uri) {
          _controller.add(uri);
        },
        onError: (err) {
          debugPrint('Deep link error: $err');
        },
      );
    } catch (e) {
      debugPrint('Failed to initialize deep links: $e');
    }
  }

  String? handlePaymentCallback(Uri uri) {
    if (uri.scheme == 'live-app-flu' && uri.path == '/payment/callback') {
      final orderNo = uri.queryParameters['order_no'];
      final status = uri.queryParameters['status'];

      debugPrint('Payment callback received: order=$orderNo, status=$status');

      return orderNo;
    }

    return null;
  }

  void dispose() {
    _sub?.cancel();
    _controller.close();
  }
}
