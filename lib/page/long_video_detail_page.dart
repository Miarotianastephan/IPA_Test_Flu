import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/l10n/app_localizations.dart';
import 'package:live_app/models/video_info.dart';
import 'package:live_app/widgets/video_screen.dart';

import '../provider/video_detail_provider.dart';
import '../widgets/video/comment_section.dart';
import '../widgets/video/video_description_section.dart';

class LongVideoDetailPage extends ConsumerStatefulWidget {
  final VideoInfo video;

  const LongVideoDetailPage({super.key, required this.video});

  @override
  ConsumerState<LongVideoDetailPage> createState() =>
      _LongVideoDetailPageState();
}

class _LongVideoDetailPageState extends ConsumerState<LongVideoDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      markSeen();
    });
  }

  Future<void> markSeen() async {
    await ref
        .read(videoDetailProvider(widget.video.id).notifier)
        .loadVideoDetail(widget.video.id);
    ref.read(videoDetailProvider(widget.video.id).notifier).markSeen();
  }

  @override
  void dispose() {
    _tabController.dispose();

    super.dispose();
  }

  void _pauseAndNavigate(VideoInfo video) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => LongVideoDetailPage(video: video)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final videoState = ref.watch(videoDetailProvider(widget.video.id));
    final videoNotifier = ref.read(
      videoDetailProvider(widget.video.id).notifier,
    );
    final video = videoState.video;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          ref.read(fullscreenProvider.notifier).state = false;
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.97,
              child: Center(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isFullscreen = ref.read(fullscreenProvider);
                    final ratio = isFullscreen
                        ? constraints.maxWidth / constraints.maxHeight
                        : 16 / 9;

                    return Column(
                      children: [
                        // 🎬 上半部分：视频播放器
                        Stack(
                          children: [
                            AspectRatio(
                              aspectRatio: ratio,
                              child: Center(
                                child: VideoScreen(videoUrl: widget.video.url),
                              ),
                            ),
                            Positioned(
                              top: MediaQuery.of(context).padding.top,
                              left: 0,
                              child: TextButton(
                                onPressed: Navigator.of(context).pop,
                                child: Icon(
                                  Icons.arrow_back,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),

                        ref.read(fullscreenProvider) == true
                            ? SizedBox()
                            : Expanded(
                                child: Container(
                                  color: const Color(0xFF111111),
                                  child: Column(
                                    children: [
                                      // TabBar
                                      Container(
                                        color: const Color(0xFF111111),
                                        child: TabBar(
                                          controller: _tabController,
                                          labelColor: Colors.white,
                                          unselectedLabelColor: Colors.grey,
                                          indicatorColor: Colors.white,
                                          tabs: [
                                            Tab(
                                              text: AppLocalizations.of(
                                                context,
                                              )!.intro,
                                            ),
                                            Tab(
                                              text: AppLocalizations.of(
                                                context,
                                              )!.comment,
                                            ),
                                          ],
                                        ),
                                      ),

                                      // TabBarView 内容
                                      Expanded(
                                        child: TabBarView(
                                          controller: _tabController,
                                          children: [
                                            // 简介页
                                            VideoDescriptionSection(
                                              videoInfo: video ?? widget.video,
                                              onRecommendedVideoTap:
                                                  _pauseAndNavigate,
                                              onFavorite: (v) => videoNotifier
                                                  .toggleFavorite(),
                                              onLike: (v) async {
                                                videoNotifier.toggleLike();
                                              },
                                              onFollowPressed: (v) async {
                                                videoNotifier.toggleFollow();
                                              },
                                              onShare: () =>
                                                  videoNotifier.shareVideo(),
                                            ),

                                            // 评论页
                                            CommentSection(
                                              videoId: widget.video.id,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
