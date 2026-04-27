import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/provider/download_video_provider.dart';
import 'package:live_app/provider/i18n_provider.dart';
import 'package:live_app/utils/text_util.dart';
import 'package:live_app/widgets/empty_widget.dart';
import 'package:live_app/widgets/encrypted_image.dart';
import 'package:live_app/widgets/video_screen.dart';

class DownloadsPage extends ConsumerStatefulWidget {
  const DownloadsPage({super.key});

  @override
  ConsumerState<DownloadsPage> createState() => _DownloadsPageState();
}

class _DownloadsPageState extends ConsumerState<DownloadsPage> {
  bool isDeleteOne = false;
  String currentType = "short";

  @override
  Widget build(BuildContext context) {
    final i18nNotifier = ref.read(i18nNotifierProvider.notifier);
    final downloadsStream = ref.watch(downloadsStreamProvider);
    final usedSpace = ref.watch(usedSpaceProvider);
    final saturated = ref.watch(isStorageSaturatedProvider);
    String translate(String key) => i18nNotifier.translate(key);
    return downloadsStream.when(
      data: (items) {
        final filteredItems = items
            .where((item) => item.type == currentType)
            .toList();

        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            title: Text(translate("downloadedContent")),
            actions: [
              VideoTypeToggleButtonDonwload(
                currentType: currentType,
                onToggle: (nextType) {
                  setState(() {
                    currentType = nextType;
                  });
                },
              ),
              filteredItems.isEmpty
                  ? SizedBox.shrink()
                  : PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert),
                      tooltip: "Options",
                      onSelected: (value) async {
                        if (value == "delete_all") {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text(translate("confirmation")),
                                content: Text(translate("confirmDeleteAll")),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    child: Text(
                                      translate("cancel"),
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      final repo = ref.read(
                                        offlineRepoProvider,
                                      );
                                      await repo.deleteAll();
                                      ref.invalidate(preparedProvider);
                                      ref.invalidate(preparingProvider);
                                      ref.invalidate(progressProvider);
                                      ref.invalidate(
                                        isStorageSaturatedProvider,
                                      );
                                      if (context.mounted) {
                                        Navigator.of(context).pop();
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              translate("allContentDeleted"),
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                    child: Text(
                                      translate("delete"),
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              );
                            },
                          );
                        } else if (value == "delete_one") {
                          setState(() {
                            isDeleteOne = !isDeleteOne;
                          });
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: "delete_all",
                          child: Text(translate("deleteAll")),
                        ),
                        PopupMenuItem(
                          value: "delete_one",
                          child: Text(
                            isDeleteOne
                                ? translate("cancelDeletion")
                                : translate("deleteVideo"),
                          ),
                        ),
                      ],
                    ),
            ],
          ),
          body: filteredItems.isEmpty
              ? CustomScrollView(
                  slivers: [
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: EmptyWidget(
                          message:
                              "${translate("noContent")} ${currentType.toLowerCase()}",
                        ),
                      ),
                    ),
                  ],
                )
              : CustomScrollView(
                  slivers: [
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _SimpleHeaderDelegate(
                        height: 60,
                        child: Container(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Expanded(
                                child: usedSpace.when(
                                  data: (bytes) => Text(
                                    "${translate("usedSpace")}: ${(bytes / (1024 * 1024)).toStringAsFixed(1)} Mo",
                                  ),
                                  loading: () => Text(
                                    "${translate("calculatingSpace")}...",
                                  ),
                                  error: (_, _) =>
                                      Text(translate("spaceUnavailable")),
                                ),
                              ),
                              saturated.when(
                                data: (isSat) => isSat
                                    ? IconButton(
                                        icon: const Icon(Icons.warning_amber),
                                        color: Colors.orange,
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: Text(
                                                  translate("storageWarning"),
                                                ),
                                                content: Text(
                                                  "⚠️ ${translate("storageAlmostFull")}",
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.of(
                                                          context,
                                                        ).pop(),
                                                    child: const Text(
                                                      "OK",
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        },
                                      )
                                    : const SizedBox.shrink(),
                                loading: () => const SizedBox.shrink(),
                                error: (_, _) => const SizedBox.shrink(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final item = filteredItems[index];
                        return _DownloadTile(
                          key: ValueKey(item.id),
                          item: item,
                          ref: ref,
                          isDeleteOneTile: isDeleteOne,
                        );
                      }, childCount: filteredItems.length),
                    ),
                  ],
                ),
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, _) =>
          Scaffold(body: Center(child: Text(translate("loadingError")))),
    );
  }
}

class _SimpleHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;

  _SimpleHeaderDelegate({required this.child, required this.height});

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox.expand(child: child);
  }

  @override
  double get maxExtent => height;
  @override
  double get minExtent => height;
  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      false;
}

class _DownloadTile extends StatefulWidget {
  final dynamic item;
  final WidgetRef ref;
  final bool isDeleteOneTile;
  const _DownloadTile({
    super.key,
    required this.item,
    required this.ref,
    required this.isDeleteOneTile,
  });

  @override
  State<_DownloadTile> createState() => _DownloadTileState();
}

class _DownloadTileState extends State<_DownloadTile> {
  int _lastProgress = 0;
  String? isPaused;
  @override
  Widget build(BuildContext context) {
    var item = widget.item;
    final ref = widget.ref;
    final i18nNotifier = ref.read(i18nNotifierProvider.notifier);
    final int itemId = item.id is int ? item.id : int.parse(item.id.toString());
    final progress = ref.watch(progressProvider(itemId));
    if (item.progress > 0) {
      _lastProgress = item.progress.clamp(
        progress > item.progress ? progress : 1,
        100,
      );
    }
    String translate(String key) => i18nNotifier.translate(key);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      elevation: 6,

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          if (item.localPath != null && File(item.localPath).existsSync()) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => VideoScreen(localPath: item.localPath!),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  item.status == "completed"
                      ? translate("fileNotFound")
                      : translate("downloadNotComplete"),
                ),
              ),
            );
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                item.status == "downloading" || item.status == "paused"
                    ? const SizedBox.shrink()
                    : widget.isDeleteOneTile
                    ? IconButton(
                        icon: const Icon(Icons.delete, color: Colors.white),
                        onPressed: () async {
                          final repo = ref.read(offlineRepoProvider);
                          await repo.deleteResource(item.id);
                          ref.read(preparedProvider(itemId).notifier).state =
                              false;
                          ref.read(preparingProvider(itemId).notifier).state =
                              false;
                          ref.read(progressProvider(itemId).notifier).state = 0;
                          ref.invalidate(isStorageSaturatedProvider);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(translate("contentDeleted")),
                            ),
                          );
                        },
                      )
                    : const SizedBox.shrink(),
                if (widget.isDeleteOneTile) const SizedBox(width: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: (item.coverUrl != null && item.coverUrl.isNotEmpty)
                      ? EncryptedImage(
                          url: item.coverUrl,
                          height: 120,
                          width: 180,
                          fit: BoxFit.cover,
                          errorWidget: const Icon(Icons.broken_image, size: 40),
                        )
                      : const SizedBox(
                          height: 120,
                          width: 180,
                          child: Center(
                            child: Icon(Icons.video_file, size: 40),
                          ),
                        ),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: Theme.of(context).textTheme.titleMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      item.durationSeconds == 0
                          ? Text(
                              "Type: ${item.type}",
                              style: Theme.of(context).textTheme.bodySmall,
                            )
                          : Text(
                              "Type: ${item.type} • ${translate("duration")}: ${formatDuration(item.durationSeconds)}",
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),

            if (item.status == "downloading" || item.status == "paused")
              const SizedBox(height: 8),
            if (item.status == "downloading" || item.status == "paused") ...[
              Row(
                children: [
                  Flexible(
                    flex: 5,
                    child: LinearProgressIndicator(
                      value: _lastProgress / 100,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.blue,
                      ),
                    ),
                  ),

                  IconButton(
                    icon: Icon(
                      isPaused == "paused" ? Icons.play_arrow : Icons.pause,
                      color: Colors.white,
                    ),
                    onPressed: () async {
                      final repo = ref.read(offlineRepoProvider);
                      if (isPaused == "paused") {
                        final i18nNotifier = ref.read(
                          i18nNotifierProvider.notifier,
                        );
                        await repo.resumeDownload(
                          id: item.id,
                          translate: i18nNotifier.translate,
                        );
                        item = item.copyWith(status: "downloading");
                        setState(() {
                          isPaused = item.status;
                        });
                      } else {
                        await repo.pauseDownload(item.id);
                        item = item.copyWith(status: "paused");
                        ref.read(progressProvider(itemId).notifier).state =
                            _lastProgress;
                        setState(() {
                          isPaused = item.status;
                        });
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.cancel, color: Colors.red),
                    onPressed: () async {
                      final repo = ref.read(offlineRepoProvider);
                      await repo.cancelDownload(item.id);
                      ref.read(preparedProvider(itemId).notifier).state = false;
                      ref.read(preparingProvider(itemId).notifier).state =
                          false;
                      ref.read(progressProvider(itemId).notifier).state = 0;
                    },
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text("$_lastProgress%"),
            ],
            if (widget.isDeleteOneTile) const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class VideoTypeToggleButtonDonwload extends StatefulWidget {
  final String currentType;
  final ValueChanged<String> onToggle;

  const VideoTypeToggleButtonDonwload({
    super.key,
    required this.currentType,
    required this.onToggle,
  });

  @override
  State<VideoTypeToggleButtonDonwload> createState() =>
      _VideoTypeToggleButtonDonwloadState();
}

class _VideoTypeToggleButtonDonwloadState
    extends State<VideoTypeToggleButtonDonwload> {
  void _toggleType() {
    String next;
    switch (widget.currentType) {
      case 'short':
        next = 'long';
        break;
      case 'long':
        next = 'forum';
        break;
      default:
        next = 'short';
    }
    widget.onToggle(next);
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: _toggleType,
      child: Row(
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween<double>(
              begin: 0,
              end: widget.currentType == "long" ? 1.25 : 1.0,
            ),
            duration: const Duration(milliseconds: 450),
            curve: Curves.easeInOut,
            builder: (context, value, child) {
              return Transform.rotate(
                angle: value * 3.1415926 * 2,
                child: child,
              );
            },
            child: Icon(
              widget.currentType == "forum"
                  ? Icons.forum
                  : Icons.stay_current_portrait,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
