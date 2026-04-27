import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/database/download_database.dart';
import 'package:live_app/models/video_info.dart';
import 'package:live_app/provider/download_video_provider.dart';
import 'package:live_app/provider/i18n_provider.dart';
import 'package:live_app/widgets/download_button.dart';

class VideoActionRow extends ConsumerWidget {
  final int likes;
  final int favorites;
  final int shares;
  final bool isLiked;
  final bool isFavorited;
  final Future<void> Function(bool) onLike;
  final Future<void> Function(bool) onFavorite;
  final VoidCallback onShare;
  final VideoInfo videoInfo;

  const VideoActionRow({
    super.key,
    required this.likes,
    required this.favorites,
    required this.shares,
    required this.onLike,
    required this.onFavorite,
    required this.onShare,
    this.isLiked = false,
    this.isFavorited = false,
    required this.videoInfo,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultColor = isDark ? Colors.white : Colors.black;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        // 点赞
        _ActionItem(
          icon: isLiked ? Icons.favorite : Icons.favorite_border,
          label: likes.toString(),
          onTap: () {
            onLike(!isLiked);
          },
          color: isLiked ? Colors.redAccent : defaultColor,
        ),

        //收藏
        _ActionItem(
          icon: isFavorited ? Icons.bookmark : Icons.bookmark_border,
          label: favorites.toString(),
          onTap: () {
            onFavorite(!isFavorited);
          },
          color: isFavorited ? Colors.amber : defaultColor,
        ),

        //分享
        _ActionItem(
          icon: Icons.share,
          label: shares.toString(),
          onTap: onShare,
          showLabel: false,
          color: defaultColor,
        ),

        if (!kIsWeb)
          StreamBuilder<Download?>(
            stream: ref.watch(offlineRepoProvider).db.watchById(videoInfo.id),
            builder: (context, snapshot) {
              final existing = snapshot.data;
              final localPath = existing?.localPath;
              final fileExists = localPath != null
                  ? File(localPath).existsSync()
                  : false;

              if (existing == null) {
                return DownloadButton(
                  videoInfo: videoInfo,
                  filename: "video_${videoInfo.id}.mp4",
                );
              }

              switch (existing.status) {
                case "completed":
                  if (fileExists) {
                    return const Icon(
                      Icons.download_done,
                      color: Colors.white,
                      size: 28.0,
                    );
                  } else {
                    return DownloadButton(
                      videoInfo: videoInfo,
                      filename: "video_${videoInfo.id}.mp4",
                    );
                  }

                case "paused":
                  return IconButton(
                    icon: const Icon(Icons.play_arrow, color: Colors.white),
                    onPressed: () async {
                      final repo = ref.read(offlineRepoProvider);
                      final i18nNotifier = ref.read(
                        i18nNotifierProvider.notifier,
                      );
                      await repo.resumeDownload(
                        id: videoInfo.id,
                        translate: i18nNotifier.translate,
                      );
                    },
                  );

                case "failed":
                  return IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.red),
                    onPressed: () async {
                      final repo = ref.read(offlineRepoProvider);
                      final i18nNotifier = ref.read(
                        i18nNotifierProvider.notifier,
                      );
                      await repo.downloadResource(
                        id: videoInfo.id,
                        filename: "video_${videoInfo.id}.mp4",
                        translate: i18nNotifier.translate,
                      );
                    },
                  );

                case "cancelled":
                  return DownloadButton(
                    videoInfo: videoInfo,
                    filename: "video_${videoInfo.id}.mp4",
                  );

                default:
                  return DownloadButton(
                    videoInfo: videoInfo,
                    filename: "video_${videoInfo.id}.mp4",
                  );
              }
            },
          ),
      ],
    );
  }
}

class _ActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool showLabel;
  final Color color;

  const _ActionItem({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 28, color: color),
          const SizedBox(height: 4),
          if (showLabel)
            Text(label, style: TextStyle(fontSize: 12, color: color))
          else
            const SizedBox(height: 16),
        ],
      ),
    );
  }
}
