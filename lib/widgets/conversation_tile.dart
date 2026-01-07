import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:live_app/provider/emoji_provider.dart';
import 'package:live_app/provider/i18n_provider.dart';
import 'package:live_app/widgets/encrypted_image.dart';

class ConversationTile extends ConsumerStatefulWidget {
  final String? title;
  final VoidCallback onTap;
  final int? unreadCount;
  final String? lastMessage;
  final String? timeStr;
  final String? avatarUrl;
  final bool isGroupChat;
  final String? nickname;

  const ConversationTile({
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
  ConsumerState<ConversationTile> createState() => _ConversationTileState();
}

class _ConversationTileState extends ConsumerState<ConversationTile> {
  Widget buildMessageContent(String messageContent) {
    final regex = RegExp(r'\^\*#\*([\w]+)\*#\*\^');
    final matches = regex.allMatches(messageContent);

    if (matches.isEmpty) {
      return Text(messageContent, style: TextStyle(fontSize: 16));
    }

    final emojiState = ref.watch(emojiProvider(1));

    final children = <InlineSpan>[];
    int lastEnd = 0;

    for (final match in matches) {
      if (match.start > lastEnd) {
        children.add(
          TextSpan(
            text: messageContent.substring(lastEnd, match.start),
            style: TextStyle(
              color: const Color.fromARGB(255, 158, 158, 158),
              fontSize: 16,
            ),
          ),
        );
      }
      final code = match.group(1)!;

      try {
        final emoji = emojiState.emojis.firstWhere(
          (e) => e.code == '^*#*$code*#*^',
        );

        children.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: _buildEmojiWidget(emoji.url, 16, 16),
            ),
          ),
        );
      } catch (e) {
        children.add(TextSpan(text: code, style: TextStyle(fontSize: 16)));
      }

      lastEnd = match.end;
    }

    if (lastEnd < messageContent.length) {
      children.add(
        TextSpan(
          text: messageContent.substring(lastEnd),
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return RichText(text: TextSpan(children: children));
  }

  @override
  Widget build(BuildContext context) {
    final i18n = ref.read(i18nNotifierProvider.notifier);
    String translate(String key) => i18n.translate(key);
    return ListTile(
      leading: _buildLeading(),
      title: Text(
        widget.title ?? translate("systemNotification"),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: buildMessageContent(
        widget.lastMessage ?? translate("checkTheLatestSystemNotification"),
      ),
      trailing: _buildTrailing(),
      onTap: widget.onTap,
    );
  }

  Widget _buildLeading() {
    if (widget.avatarUrl == null && widget.title == null) {
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

  Widget _buildEmojiWidget(String path, double width, double height) {
    final isLocalFile =
        path.startsWith('/') || (path.length > 2 && path[1] == ':');

    if (!kIsWeb && isLocalFile) {
      final file = File(path);
      if (file.existsSync()) {
        return SvgPicture.memory(
          file.readAsBytesSync(),
          width: width,
          height: height,
        );
      }
    }

    return SvgPicture.network(
      path,
      width: width,
      height: height,
      placeholderBuilder: (_) => SizedBox(
        width: width,
        height: height,
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
    );
  }
}
