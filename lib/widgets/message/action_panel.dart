import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:live_app/provider/emoji_provider.dart';

class ActionPanel extends ConsumerStatefulWidget {
  final Function(String emojiKey, String emojiUrl)? onEmojiSelected;
  final Function(String gifUrl)? onGifSelected;

  const ActionPanel({super.key, this.onEmojiSelected, this.onGifSelected});

  @override
  ConsumerState<ActionPanel> createState() => _ActionPanelState();
}

class _ActionPanelState extends ConsumerState<ActionPanel> {
  String selectedTab = 'emoji';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (ref.read(emojiProvider(1)).emojis.isEmpty) {
        ref.read(emojiProvider(1).notifier).loadEmojis();
      }
      if (ref.read(emojiProvider(2)).emojis.isEmpty) {
        ref.read(emojiProvider(2).notifier).loadEmojis();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final emojiState = ref.watch(emojiProvider(1));
    final gifState = ref.watch(emojiProvider(2));
    final currentState = selectedTab == 'emoji' ? emojiState : gifState;

    return SafeArea(
      child: Column(
        children: [
          Container(
            color: const Color(0xFF222222),
            child: Row(
              children: [
                Expanded(
                  child: _panelTab(
                    icon: Icons.emoji_emotions,
                    label: 'Emoji',
                    isActive: selectedTab == 'emoji',
                    onTap: () {
                      setState(() => selectedTab = 'emoji');
                      final notifier = ref.read(emojiProvider(1).notifier);
                      if (notifier.state.emojis.isEmpty) {
                        notifier.loadEmojis(refresh: true);
                      }
                    },
                  ),
                ),
                Container(width: 1, color: Colors.white24),
                Expanded(
                  child: _panelTab(
                    icon: Icons.gif_box,
                    label: 'GIF',
                    isActive: selectedTab == 'gif',
                    onTap: () {
                      setState(() => selectedTab = 'gif');
                      final notifier = ref.read(emojiProvider(2).notifier);
                      if (notifier.state.emojis.isEmpty) {
                        notifier.loadEmojis(refresh: true);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: Container(
              width: double.infinity,
              color: const Color(0xFF1D1D1D),
              child: Column(
                children: [
                  Expanded(child: _buildGrid(currentState)),
                  if (currentState.hasMore)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: currentState.isLoading
                            ? null
                            : () => ref
                                  .read(
                                    emojiProvider(currentState.type).notifier,
                                  )
                                  .loadMore(),
                        child: currentState.isLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(
                                Icons.download,
                                color: Colors.white,
                                size: 28,
                              ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(EmojiState state) {
    if (state.isLoading && state.emojis.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.error != null) {
      return Center(
        child: Text(
          state.error!,
          style: const TextStyle(color: Colors.white70),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: state.type == 1 ? 7 : 3,
        crossAxisSpacing: 7,
        mainAxisSpacing: 7,
      ),
      itemCount: state.emojis.length,
      itemBuilder: (context, index) {
        final emoji = state.emojis[index];
        if (state.type == 1) {
          return InkWell(
            onTap: () => widget.onEmojiSelected?.call(emoji.code, emoji.url),
            child: Center(
              child: SvgPicture.network(emoji.url, width: 32, height: 32),
            ),
          );
        }
        return InkWell(
          onTap: () => widget.onGifSelected?.call(emoji.url),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(emoji.url, fit: BoxFit.cover),
          ),
        );
      },
    );
  }

  Widget _panelTab({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        color: isActive ? const Color(0xFF333333) : Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white70, size: 30),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}
