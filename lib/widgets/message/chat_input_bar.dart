import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/provider/i18n_provider.dart';
import 'package:live_app/widgets/message/emoji_text_input.dart';

class ChatInputBar extends ConsumerWidget {
  final EmojiTextController controller;
  final FocusNode focusNode;
  final bool isMenuExpanded;
  final VoidCallback onToggleMenu;
  final VoidCallback onToggleActionPanel;
  final VoidCallback onGalleryTap;
  final VoidCallback onCameraTap;
  final VoidCallback onMicTap;
  final VoidCallback onSend;

  const ChatInputBar({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.isMenuExpanded,
    required this.onToggleMenu,
    required this.onToggleActionPanel,
    required this.onGalleryTap,
    required this.onCameraTap,
    required this.onMicTap,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final i18n = ref.read(i18nNotifierProvider.notifier);
    String translate(String key) => i18n.translate(key);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      color: const Color(0xFF1A1A1A),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (isMenuExpanded) ...[
            _buildIconButton(Icons.emoji_emotions, onTap: onToggleActionPanel),
            _buildIconButton(Icons.image, onTap: onGalleryTap),
            _buildIconButton(Icons.camera_alt, onTap: onCameraTap),
            _buildIconButton(Icons.mic, onTap: onMicTap),
          ] else
            _buildIconButton(Icons.arrow_forward_ios, onTap: onToggleMenu),

          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(25),
              ),
              child: EmojiTextField(
                controller: controller,
                sharedFocusNode: focusNode,
                hintText: translate("enterMessage"),
                style: const TextStyle(color: Colors.white, fontSize: 16.0),
                hintStyle: const TextStyle(color: Colors.white54),
              ),
            ),
          ),

          _buildIconButton(Icons.send, onTap: onSend),
        ],
      ),
    );
  }

  Widget _buildIconButton(
    IconData icon, {
    Color color = Colors.white70,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: () {
          if (onTap != null) onTap();
        },
        child: Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.transparent,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Icon(icon, size: 24, color: color)],
          ),
        ),
      ),
    );
  }
}
