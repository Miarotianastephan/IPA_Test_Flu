import 'dart:async';

import 'package:flutter/widgets.dart';

import '../api/services/payment_service.dart';

/// Polls /api/user/payment/check every 5 seconds until the content is purchased.
///
/// Bonus: when the app comes back to the foreground (AppLifecycleState.resumed),
/// an immediate check is triggered without waiting for the next 5-second tick.
class VideoPaymentPollingService with WidgetsBindingObserver {
  final PaymentService _paymentService;
  final String contentId;
  final String contentType;
  final void Function(bool isPurchased) onStatusChanged;
  final void Function() onPurchased;
  final void Function(String error) onError;

  Timer? _timer;
  bool _isDisposed = false;

  VideoPaymentPollingService({
    required PaymentService paymentService,
    required this.contentId,
    required this.contentType,
    required this.onStatusChanged,
    required this.onPurchased,
    required this.onError,
  }) : _paymentService = paymentService;

  void start() {
    WidgetsBinding.instance.addObserver(this);
    _check().then((_) {
      if (!_isDisposed) {
        _scheduleTimer();
      }
    });
  }

  void stop() {
    _isDisposed = true;
    _timer?.cancel();
    _timer = null;
    WidgetsBinding.instance.removeObserver(this);
  }

  void _scheduleTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => _check());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !_isDisposed) {
      // Immediate check when user returns to the app.
      _timer?.cancel();
      _check().then((_) {
        if (!_isDisposed) _scheduleTimer();
      });
    }
  }

  Future<void> _check() async {
    if (_isDisposed) return;

    try {
      final response = await _paymentService.check(
        contentType: contentType,
        contentId: contentId,
      );

      if (_isDisposed) return;

      if (response.data != null) {
        onStatusChanged(response.data!);
        debugPrint(
          "------------------------------------------- $contentType/$contentId => ${response.data!}",
        );

        if (response.data!) {
          stop();
          onPurchased();
        }
      }
    } catch (e) {
      if (!_isDisposed) {
        onError(e.toString());
      }
    }
  }
}
