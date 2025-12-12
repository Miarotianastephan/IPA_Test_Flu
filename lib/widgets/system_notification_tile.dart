import 'package:flutter/material.dart';
import 'package:live_app/l10n/app_localizations.dart';
import 'package:live_app/widgets/encrypted_image.dart';

class SystemNotificationTile extends StatelessWidget {
  final String? title;
  final VoidCallback onTap;
  final int? unreadCount;
  final String? lastMessage;
  final String? timeStr;
  final String? avatarUrl;
  final bool isGroupChat;
  final String? nickname;

  const SystemNotificationTile({
    super.key,
    required this.onTap,
    this.title,
    this.unreadCount,
    this.lastMessage,
    this.timeStr,
    this.avatarUrl,
    this.isGroupChat = false,
    this.nickname,
  });

  @override
  Widget build(BuildContext context) {
    final localisations = AppLocalizations.of(context)!;
    return ListTile(
      leading: _buildLeading(),
      title: Text(
        title ?? localisations.systemNotification,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        lastMessage ?? localisations.checkTheLatestSystemNotification,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: Colors.white54),
      ),
      trailing: _buildTrailing(),
      onTap: onTap,
    );
  }

  Widget _buildLeading() {
    if (avatarUrl == null && title == null) {
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
      key: ValueKey(avatarUrl ?? nickname),
      url: avatarUrl,
      nickname: nickname,
      size: 40,
    );
  }

  Widget? _buildTrailing() {
    if (unreadCount == null && timeStr == null) {
      return null;
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (timeStr != null)
          Text(
            timeStr!,
            style: const TextStyle(color: Colors.white38, fontSize: 11),
          ),
        if (timeStr != null && unreadCount != null && unreadCount! > 0)
          const SizedBox(height: 4),
        if (unreadCount != null && unreadCount! > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: title == null ? Colors.blue : Colors.red,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              (unreadCount! > 999) ? '999+' : unreadCount.toString(),
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
