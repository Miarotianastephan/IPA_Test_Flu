import 'package:flutter/material.dart';

import '../models/in_app_notice.dart';
import '../widgets/encrypted_image.dart';

enum SnackBarType { success, error, warning, info }

class ToastUtil {
  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  static OverlayEntry? _currentNoticeOverlay;

  static void showNotice(BuildContext context, InAppNotice notice) {
    // Dismiss any existing notice
    _currentNoticeOverlay?.remove();
    _currentNoticeOverlay = null;

    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => _NoticeOverlay(
        notice: notice,
        onDismiss: () {
          overlayEntry.remove();
          if (_currentNoticeOverlay == overlayEntry) {
            _currentNoticeOverlay = null;
          }
        },
      ),
    );

    _currentNoticeOverlay = overlayEntry;
    Overlay.of(context).insert(overlayEntry);
  }

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

class _NoticeOverlay extends StatefulWidget {
  final InAppNotice notice;
  final VoidCallback onDismiss;

  const _NoticeOverlay({
    required this.notice,
    required this.onDismiss,
  });

  @override
  State<_NoticeOverlay> createState() => _NoticeOverlayState();
}

class _NoticeOverlayState extends State<_NoticeOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(_controller);

    _controller.forward();

    // Auto dismiss after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        _dismiss();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _dismiss() async {
    await _controller.reverse();
    widget.onDismiss();
  }

  @override
  Widget build(BuildContext context) {
    final notice = widget.notice;
    final mediaQuery = MediaQuery.of(context);

    return Positioned(
      top: mediaQuery.padding.top + 8,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            color: Colors.transparent,
            child: GestureDetector(
              onTap: () {
                _dismiss();
                notice.onTap();
              },
              onVerticalDragEnd: (details) {
                if (details.primaryVelocity != null &&
                    details.primaryVelocity! < 0) {
                  _dismiss();
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: UserAvatar(url: "${notice.avatarUrl}"),
                  title: Text(
                    notice.title,
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    notice.content,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white54),
                  ),
                  trailing: notice.time != null
                      ? Text(
                          TimeOfDay.fromDateTime(notice.time!).format(context),
                          style: const TextStyle(color: Colors.white38),
                        )
                      : null,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
