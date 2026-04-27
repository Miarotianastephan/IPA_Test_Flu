import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/provider/i18n_provider.dart';
import 'package:live_app/models/vip.dart';
import 'package:live_app/widgets/encrypted_image.dart';
import 'package:live_app/widgets/vip_badge.dart';

class SystemNotificationTile extends ConsumerStatefulWidget {
  final String? title;
  final VoidCallback onTap;
  final int? unreadCount;
  final String? lastNotification;
  final String? timeStr;
  final String? avatarUrl;
  final bool isGroupChat;
  final String? nickname;
  final Vip? vip;

  const SystemNotificationTile({
    super.key,
    required this.onTap,
    this.title,
    this.unreadCount,
    this.lastNotification,
    this.timeStr,
    this.avatarUrl,
    this.isGroupChat = false,
    this.nickname,
    this.vip,
  });

  @override
  ConsumerState<SystemNotificationTile> createState() =>
      _SystemNotificationTileState();
}

class _SystemNotificationTileState
    extends ConsumerState<SystemNotificationTile> {
  @override
  Widget build(BuildContext context) {
    final i18n = ref.read(i18nNotifierProvider.notifier);
    String translate(String key) => i18n.translate(key);
    return ListTile(
      leading: _buildLeading(),
      title: Row(
        children: [
          Flexible(
            child: Text(
              widget.title ?? translate("systemNotification"),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          VipBadge(vip: widget.vip),
        ],
      ),
      subtitle: Text(
        widget.lastNotification ??
            translate("checkTheLatestSystemNotification"),
      ),
      trailing: _buildTrailing(),
      onTap: widget.onTap,
    );
  }

  Widget _buildLeading() {
    if (widget.avatarUrl == null) {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.notifications, color: Colors.white, size: 24),
      );
    }

    return UserAvatar(
      key: ValueKey(widget.avatarUrl ?? widget.nickname),
      url: widget.avatarUrl,
      nickname: widget.nickname,
      size: 40,
    );
  }

  Widget? _buildTrailing() {
    if (widget.unreadCount == null && widget.timeStr == null) {
      return null;
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (widget.timeStr != null)
          Text(
            widget.timeStr!,
            style: const TextStyle(color: Colors.white38, fontSize: 11),
          ),
        if (widget.timeStr != null &&
            widget.unreadCount != null &&
            widget.unreadCount! > 0)
          const SizedBox(height: 4),
        if (widget.unreadCount != null && widget.unreadCount! > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: widget.title == null ? Colors.blue : Colors.red,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              (widget.unreadCount! > 999)
                  ? '999+'
                  : widget.unreadCount.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }
}
