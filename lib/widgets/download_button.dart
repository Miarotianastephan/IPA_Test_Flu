import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/database/download_database.dart';
import 'package:live_app/models/forum_attachment.dart';
import 'package:live_app/models/forum_post.dart';
import 'package:live_app/models/video_info.dart';
import 'package:live_app/provider/api_provider.dart';
import 'package:live_app/provider/download_video_provider.dart';
import 'package:live_app/provider/i18n_provider.dart';
import 'package:live_app/services/hls_proxy_server.dart';
import 'package:uuid/uuid.dart';

class DownloadButton extends ConsumerStatefulWidget {
  final String filename;
  final VideoInfo? videoInfo;
  final ForumAttachment? attachment;
  final ForumPost? forumPost;
  const DownloadButton({
    super.key,
    required this.filename,
    this.videoInfo,
    this.attachment,
    this.forumPost,
  });

  @override
  ConsumerState<DownloadButton> createState() => _DownloadButtonState();
}

class _DownloadButtonState extends ConsumerState<DownloadButton> {
  String get _id => widget.videoInfo?.id ?? widget.attachment!.id.toString();
  String get _url => widget.videoInfo?.url ?? widget.attachment!.fileUrl;
  String get _cover =>
      widget.videoInfo?.cover ?? widget.attachment?.thumbnailUrl ?? "";
  String get _title => widget.videoInfo?.title ?? widget.forumPost?.title ?? "";
  String get _type => widget.videoInfo?.type == null
      ? "forum"
      : widget.videoInfo?.type == 1
      ? "short"
      : "long";
  int get _duration => widget.videoInfo?.duration ?? 0;
  String get _encryptionKey => widget.videoInfo?.encryptionKey ?? '';

  String? _downloadSessionId;
  bool _isPreparing = false;

  @override
  void dispose() {
    _cleanupProxy();
    super.dispose();
  }

  void _cleanupProxy() {
    if (_downloadSessionId != null) {
      HlsProxyServer.instance.unregisterPlaylist(_downloadSessionId!);
      HlsProxyServer.instance.release();
      _downloadSessionId = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final i18nNotifier = ref.read(i18nNotifierProvider.notifier);
    String translate(String key) => i18nNotifier.translate(key);

    return StreamBuilder<Download?>(
      stream: ref.watch(offlineRepoProvider).db.watchById(_id),
      builder: (context, snapshot) {
        final existing = snapshot.data;

        if (_url.isEmpty) {
          return const CircularProgressIndicator(color: Colors.white);
        }

        return IconButton(
          icon: _isPreparing
              ? const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: Colors.white,
                  ),
                )
              : Stack(
                  alignment: Alignment.center,
                  children: [
                    if (existing?.status == "downloading")
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                          value: (existing?.progress ?? 0) > 0
                              ? (existing!.progress / 100.0)
                              : null,
                          strokeWidth: 3,
                          color: (existing?.progress ?? 0) > 0
                              ? Colors.blue
                              : Colors.blueGrey,
                          backgroundColor: Colors.white,
                        ),
                      ),
                    existing?.status == "completed"
                        ? const Icon(
                            Icons.check_circle,
                            color: Colors.blue,
                            size: 28.0,
                          )
                        : existing?.status == "downloading"
                        ? Text(
                            "${existing?.progress ?? 0}%",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          )
                        : const Icon(
                            Icons.download,
                            color: Colors.white,
                            size: 28.0,
                          ),
                  ],
                ),
          onPressed: _isPreparing || existing?.status == "downloading"
              ? null
              : () => _startDownload(translate),
          // : () => ref.checkPermission(
          //     context,
          //     Permission.downloadResources,
          //     () => _startDownload(translate),
          //   ),
        );
      },
    );
  }

  Future<void> _startDownload(String Function(String) translate) async {
    setState(() => _isPreparing = true);

    final repo = ref.read(offlineRepoProvider);

    try {
      String downloadUrl = _url;

      if (_url.endsWith('.m3u8')) {
        HlsProxyServer.instance.acquire();
        await HlsProxyServer.instance.start();

        final videoService = ref.read(videoServiceProvider);
        final playbackInfo = await videoService.playVideo(
          videoUrl: _url,
          key: _encryptionKey,
        );

        _downloadSessionId = const Uuid().v4();

        downloadUrl = HlsProxyServer.instance.registerPlaylist(
          _downloadSessionId!,
          playbackInfo.m3u8Content,
          baseUrl: _url,
        );
      }

      final existingDownload = await repo.db.getById(_id);

      if (existingDownload == null) {
        await repo.addResource(
          id: _id,
          coverUrl: _cover,
          title: _title,
          type: _type,
          url: downloadUrl,
          durationSeconds: _duration,
        );
      } else if (existingDownload.status == "completed") {
        _cleanupProxy();
        if (mounted) setState(() => _isPreparing = false);
        return;
      } else {
        if (_url.endsWith('.m3u8')) {
          await repo.db.updateFields(
            _id,
            DownloadsCompanion(url: Value(downloadUrl)),
          );
        }
      }

      if (mounted) setState(() => _isPreparing = false);

      final i18nNotifier = ref.read(i18nNotifierProvider.notifier);

      await repo.downloadResource(
        id: _id,
        filename: widget.filename,
        translate: i18nNotifier.translate,
      );

      _cleanupProxy();

      final saturated = await repo.isStorageSaturated();
      if (saturated && mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(translate("storageWarning")),
              content: Text(translate("storageAlmostFull")),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    "OK",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      }
    } catch (e, _) {
      _cleanupProxy();
      if (mounted) setState(() => _isPreparing = false);
    }
  }
}
