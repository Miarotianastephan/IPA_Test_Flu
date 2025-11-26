import 'package:flutter/material.dart';

enum SnackBarType { success, error, warning, info }

class ToastUtil {
  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  static void _show(String msg, int duration, SnackBarType type) {
    final colors = _getColors(type);
    final icon = _getIcon(type);

    scaffoldMessengerKey.currentState
        ?.showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(icon, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(msg, style: const TextStyle(color: Colors.white)),
                ),
              ],
            ),
            backgroundColor: colors,
            duration: Duration(seconds: duration),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(5),
            dismissDirection: DismissDirection.down,
          ),
        )
        .closed
        .then((_) {
          scaffoldMessengerKey.currentState?.clearSnackBars();
        });
  }

  static Color _getColors(SnackBarType type) {
    switch (type) {
      case SnackBarType.success:
        return Colors.green;
      case SnackBarType.error:
        return Colors.red;
      case SnackBarType.warning:
        return Colors.orange;
      case SnackBarType.info:
        return Colors.blue;
    }
  }

  static IconData _getIcon(SnackBarType type) {
    switch (type) {
      case SnackBarType.success:
        return Icons.check_circle;
      case SnackBarType.error:
        return Icons.error;
      case SnackBarType.warning:
        return Icons.warning;
      case SnackBarType.info:
        return Icons.info;
    }
  }

  static void success(String msg, {int duration = 3}) {
    _show(msg, duration, SnackBarType.success);
  }

  static void error(String msg, {int duration = 3}) {
    _show(msg, duration, SnackBarType.error);
  }

  static void warning(String msg, {int duration = 3}) {
    _show(msg, duration, SnackBarType.warning);
  }

  static void info(String msg, {int duration = 3}) {
    _show(msg, duration, SnackBarType.info);
  }
}
