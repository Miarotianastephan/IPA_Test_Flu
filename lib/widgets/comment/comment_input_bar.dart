import 'package:flutter/material.dart';
import 'package:live_app/l10n/app_localizations.dart';

class CommentInputBar extends StatelessWidget {
  final TextEditingController controller;
  final String? replyingToName;
  final VoidCallback? onCancelReply;
  final Future<void> Function(String content) onSend;
  final bool darkStyle; // 控制黑/白主题

  const CommentInputBar({
    super.key,
    required this.controller,
    required this.onSend,
    this.replyingToName,
    this.onCancelReply,
    this.darkStyle = false,
  });

  @override
  Widget build(BuildContext context) {
    final isReplying = replyingToName != null;
    final textColor = darkStyle ? Colors.black : Colors.white;
    final hintColor = darkStyle ? Colors.black54 : Colors.white70;

    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            style: TextStyle(color: textColor),
            cursorColor: textColor,
            decoration: InputDecoration(
              hintText: isReplying
                  ? "${AppLocalizations.of(context)!.reply} $replyingToName..."
                  : "${AppLocalizations.of(context)!.postComment}...",
              hintStyle: TextStyle(color: hintColor),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
            ),
          ),
        ),
        IconButton(
          icon: Icon(Icons.send, color: textColor),
          onPressed: () async {
            final content = controller.text.trim();
            if (content.isNotEmpty) {
              await onSend(content);
              controller.clear();
            }
          },
        ),
        if (isReplying && onCancelReply != null)
          IconButton(
            icon: Icon(Icons.close, color: Colors.grey),
            onPressed: onCancelReply,
          ),
      ],
    );
  }
}
