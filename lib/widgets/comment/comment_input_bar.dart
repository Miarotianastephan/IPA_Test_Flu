import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/provider/i18n_provider.dart';

class CommentInputBar extends ConsumerStatefulWidget {
  final TextEditingController controller;
  final String? replyingToName;
  final VoidCallback? onCancelReply;
  final Future<void> Function(String content) onSend;
  final bool darkStyle;

  const CommentInputBar({
    super.key,
    required this.controller,
    required this.onSend,
    this.replyingToName,
    this.onCancelReply,
    this.darkStyle = false,
  });

  @override
  ConsumerState<CommentInputBar> createState() => _CommentInputBarState();
}

class _CommentInputBarState extends ConsumerState<CommentInputBar> {
  bool _isSending = false;

  @override
  Widget build(BuildContext context) {
    final i18n = ref.read(i18nNotifierProvider.notifier);

    final isReplying = widget.replyingToName != null;
    final textColor = widget.darkStyle ? Colors.black : Colors.white;
    final hintColor = widget.darkStyle ? Colors.black54 : Colors.white70;

    final hintText = isReplying
        ? '${i18n.translate('reply')} ${widget.replyingToName}...'
        : '${i18n.translate('postComment')}...';

    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: widget.controller,
            enabled: !_isSending,
            style: TextStyle(color: textColor),
            cursorColor: textColor,
            decoration: InputDecoration(
              hintText: hintText,
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
            icon: const Icon(Icons.close, color: Colors.grey),
            onPressed: widget.onCancelReply,
          ),
      ],
    );
  }
}
