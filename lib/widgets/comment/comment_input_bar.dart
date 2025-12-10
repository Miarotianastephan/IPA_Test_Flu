import 'package:flutter/material.dart';
import 'package:live_app/l10n/app_localizations.dart';

class CommentInputBar extends StatefulWidget {
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
  State<CommentInputBar> createState() => _CommentInputBarState();
}

class _CommentInputBarState extends State<CommentInputBar> {
  bool _isSending = false;

  @override
  Widget build(BuildContext context) {
    final isReplying = widget.replyingToName != null;
    final textColor = widget.darkStyle ? Colors.black : Colors.white;
    final hintColor = widget.darkStyle ? Colors.black54 : Colors.white70;

    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: widget.controller,
            enabled: !_isSending,
            style: TextStyle(color: textColor),
            cursorColor: textColor,
            decoration: InputDecoration(
              hintText: isReplying
                  ? "${AppLocalizations.of(context)!.reply} ${widget.replyingToName}..."
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
        if (_isSending)
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: textColor,
              ),
            ),
          )
        else
          IconButton(
            icon: Icon(Icons.send, color: textColor),
            onPressed: () async {
              final content = widget.controller.text.trim();
              if (content.isNotEmpty && !_isSending) {
                setState(() => _isSending = true);
                try {
                  await widget.onSend(content);
                  widget.controller.clear();
                } finally {
                  if (mounted) {
                    setState(() => _isSending = false);
                  }
                }
              }
            },
          ),
        if (isReplying && widget.onCancelReply != null && !_isSending)
          IconButton(
            icon: Icon(Icons.close, color: Colors.grey),
            onPressed: widget.onCancelReply,
          ),
      ],
    );
  }
}
