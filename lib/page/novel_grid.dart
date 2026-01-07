import 'package:flutter/material.dart';

import 'package:live_app/page/audio_novel_card.dart';
import 'package:live_app/page/novel_card..dart';
import 'package:live_app/widgets/empty_widget.dart';

class NovelGrid extends StatelessWidget {
  final List<dynamic> items;
  final bool isAudio;
  final bool showCreatorInfo;
  const NovelGrid({
    super.key,
    required this.items,
    this.isAudio = false,
    this.showCreatorInfo = true,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const EmptyWidget();
    }
    return GridView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.all(8),
      itemCount: items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: isAudio
            ? 1.0
            : showCreatorInfo
            ? 0.5
            : 0.55,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemBuilder: (context, index) {
        if (isAudio) {
          return AudioNovelCard(item: items[index]);
        }
        return NovelCard(item: items[index], showCreatorInfo: showCreatorInfo);
      },
    );
  }
}
