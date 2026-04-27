import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/models/vip.dart';
import 'package:live_app/provider/i18n_provider.dart';
import 'package:live_app/widgets/html_text_field.dart';
import '../vip_badge.dart';

class CommentInputBar extends ConsumerStatefulWidget {
  final TextEditingController controller;
  final String? replyingToName;
  final Vip? replyingToVip;
  final VoidCallback? onCancelReply;
  final Future<void> Function(String content) onSend;
  final bool darkStyle;

  const CommentInputBar({
    super.key,
    required this.controller,
    required this.onSend,
    this.replyingToName,
    this.replyingToVip,
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

    final hintText = '${i18n.translate('postComment')}...';

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isReplying && !_isSending)
          Padding(
            padding: const EdgeInsets.only(left: 12, bottom: 4, right: 8),
            child: Row(
              children: [
                Text(
                  '${i18n.translate('reply')} ',
                  style: TextStyle(color: hintColor, fontSize: 13),
                ),
                Flexible(
                  child: Text(
                    widget.replyingToName!,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                VipBadge(
                  vip: widget.replyingToVip,
                  size: 14,
                  padding: const EdgeInsets.only(left: 2),
                ),
                const SizedBox(width: 8),
                if (widget.onCancelReply != null)
                  InkWell(
                    onTap: widget.onCancelReply,
                    child: const Icon(
                      Icons.close,
                      color: Colors.grey,
                      size: 16,
                    ),
                  ),
              ],
            ),
          ),
        Row(
          children: [
            Expanded(
              child: HtmlTextField(
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
          ],
        ),
      ],
    );
  }
}
