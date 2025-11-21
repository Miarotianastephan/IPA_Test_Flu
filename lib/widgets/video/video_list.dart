import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/video_info.dart';
import '../empty_retry.dart';
import '../loading_widget.dart';
import 'package:live_app/widgets/video/video_card.dart';

class VideoListSliver extends ConsumerWidget {
  final ProviderListenable provider;
  final Future<void> Function() onRefresh;
  final Function(VideoInfo videoInfo)? onUserTap;

  const VideoListSliver({
    super.key,
    required this.provider,
    required this.onRefresh,
    this.onUserTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(provider);
    final list = state.list;
    if ((!state.finished || state.loading) && list.isEmpty) {
      return SliverFillRemaining(child: LoadingWidget(message: "正在加载中..."));
    }
    if (state.finished && !state.loading && list.isEmpty) {
      return SliverFillRemaining(child: EmptyWithRetry(onRetry: onRefresh));
    }
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: .95,
      ),
      delegate: SliverChildBuilderDelegate(
        (c, i) => VideoCard(video: list[i], onUserTap: onUserTap),
        childCount: list.length,
      ),
    );
  }
}
