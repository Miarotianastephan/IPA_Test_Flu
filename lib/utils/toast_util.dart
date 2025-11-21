import 'package:flutter/cupertino.dart';
import 'package:toastification/toastification.dart';

class ToastUtil {
  static void _show(
    String msg,
    int duration,
    ToastificationType type,
    Alignment alignment,
  ) {
    toastification.show(
      title: Text(msg),
      alignment: alignment,
      type: type,
      autoCloseDuration: Duration(seconds: duration),
      closeOnClick: true,
      dragToClose: true,
      style: ToastificationStyle.flatColored,
      closeButton: ToastCloseButton(showType: CloseButtonShowType.none),
      animationDuration: const Duration(milliseconds: 300),
      animationBuilder: (context, animation, alignment, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
        );
        final offsetAnimation = Tween<Offset>(
          begin: const Offset(0, -0.2),
          end: Offset.zero,
        ).animate(curved);

        return SlideTransition(
          position: offsetAnimation,
          child: FadeTransition(
            opacity: animation,
            child: ScaleTransition(scale: curved, child: child),
          ),
        );
      },
    );
  }

  static void success(
    String msg, {
    int duration = 3,
    Alignment alignment = Alignment.center,
  }) {
    _show(msg, duration, ToastificationType.success, alignment);
  }

  static void error(
    String msg, {
    int duration = 3,
    Alignment alignment = Alignment.center,
  }) {
    _show(msg, duration, ToastificationType.error, alignment);
  }

  static void warning(
    String msg, {
    int duration = 3,
    Alignment alignment = Alignment.center,
  }) {
    _show(msg, duration, ToastificationType.warning, alignment);
  }

  static void info(
    String msg, {
    int duration = 3,
    Alignment alignment = Alignment.center,
  }) {
    _show(msg, duration, ToastificationType.info, alignment);
  }
}
