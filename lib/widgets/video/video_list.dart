import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/provider/video_detail_provider.dart';
import 'package:live_app/widgets/empty_widget.dart';

import '../../models/video_info.dart';
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

    final videoType = ref.watch(videoTypeProvider);

    if ((!state.finished || state.loading) && list.isEmpty) {
      return const SliverFillRemaining(child: LoadingWidget());
    }
    if (state.finished && !state.loading && list.isEmpty) {
      return const SliverFillRemaining(child: EmptyWidget());
    }

    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: videoType == 2 ? 0.95 : 9 / 16,
      ),
      delegate: SliverChildBuilderDelegate((c, i) {
        final video = list[i];
        return VideoCard(video: video, onUserTap: onUserTap);
      }, childCount: list.length),
    );
  }
}
