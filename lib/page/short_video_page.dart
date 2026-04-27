import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/page/search_page.dart';
import 'package:live_app/provider/cumulative_watch_time_provider.dart';
import 'package:live_app/provider/i18n_provider.dart';
import 'package:live_app/widgets/comment/comment_input_bar.dart';

import '../provider/api_provider.dart';
import '../provider/video_detail_provider.dart';
import '../provider/web_video_mute_provider.dart';
import '../widgets/video/short_video_item.dart';
import 'user_detail_page.dart';

class ShortVideoPage extends ConsumerStatefulWidget {
  final String videoId;
  final String? heroTagPrefix;
  final bool isUserDetailPop;

  const ShortVideoPage({
    super.key,
    required this.videoId,
    this.heroTagPrefix,
    this.isUserDetailPop = false,
  });

  @override
  ConsumerState<ShortVideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends ConsumerState<ShortVideoPage>
    with AutomaticKeepAliveClientMixin {
  bool isHideHeader = false;
  final ShortVideoItemController _controller = ShortVideoItemController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      ref
          .read(videoDetailProvider(widget.videoId).notifier)
          .loadVideoDetail(widget.videoId);
    });
  }

  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    ref.read(cumulativeWatchTimeProvider.notifier).stopTracking();
    _controller.dispose();
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final state = ref.watch(videoDetailProvider(widget.videoId));
    final notifier = ref.read(videoDetailProvider(widget.videoId).notifier);
    final videoService = ref.read(videoServiceProvider);
    final i18n = ref.read(i18nNotifierProvider.notifier);
    String translate(String key) => i18n.translate(key);

    if (state.loading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    if (state.error != null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: Text("${translate("error")}: ${state.error}")),
      );
    }

    final video = state.video;
    if (video == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: Text(translate("noVideoContent"))),
      );
    }

    final heroTag = widget.heroTagPrefix != null
        ? "${widget.heroTagPrefix}_${video.id}"
        : "video_${video.id}";

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            Positioned.fill(
              child: Column(
                children: [
                  Expanded(
                    child: Hero(
                      tag: heroTag,
                      child: ShortVideoItem(
                        pageKey: "ShortVideoPage",
                        videoInfo: video,
                        isFirstItem: true,
                        controller: _controller,
                        onUserTap: (_) {
                          if (!widget.isUserDetailPop) {
                            Navigator.pop(context);
                            return;
                          }
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => UserDetailPage(user: video.user),
                            ),
                          );
                        },
                        onVideoInfoChange: (updated) {
                          if (video.isFollow != updated.isFollow) {
                            notifier.toggleFollow();
                          }
                          if (video.commentCount != updated.commentCount) {
                            notifier.incrementCommentCount();
                          }
                        },
                        onShowComment: () => setState(() {
                          isHideHeader = true;
                        }),
                        onHideComment: () => setState(() {
                          isHideHeader = false;
                        }),
                      ),
                    ),
                  ),
                  Container(
                    color: Theme.of(context).colorScheme.primary,
                    child: CommentInputBar(
                      controller: _commentController,
                      darkStyle: false,
                      onSend: (content) async {
                        await videoService.commentVideo(
                          widget.videoId,
                          content,
                        );
                        notifier.incrementCommentCount();
                        _controller.updateCommentCount(
                          (video.commentCount + 1),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            if (!isHideHeader)
              Positioned(
                top: MediaQuery.of(context).padding.top + 8,
                left: 8,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),

            if (!isHideHeader)
              Positioned(
                top: MediaQuery.of(context).padding.top + 8,
                right: 8,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (kIsWeb)
                      Consumer(
                        builder: (context, ref, child) {
                          final muteState = ref.watch(webVideoMuteProvider);
                          if (!muteState.isMuted) {
                            return const SizedBox.shrink();
                          }
                          return GestureDetector(
                            onTap: () {
                              ref
                                  .read(webVideoMuteProvider.notifier)
                                  .setMuted(false);
                            },
                            child: const Padding(
                              padding: EdgeInsets.only(right: 8.0),
                              child: Icon(
                                Icons.volume_off_rounded,
                                color: Colors.white,
                              ),
                            ),
                          );
                        },
                      ),
                    IconButton(
                      icon: const Icon(Icons.search, color: Colors.white),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SearchPage()),
                        );
                      },
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
