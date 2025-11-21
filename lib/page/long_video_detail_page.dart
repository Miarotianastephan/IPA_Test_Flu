import 'package:chewie/chewie.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/l10n/app_localizations.dart';
import 'package:live_app/models/video_info.dart';
import 'package:video_player/video_player.dart';

import '../provider/video_detail_provider.dart';
import '../widgets/encrypted_image.dart';
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
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializeVideoPlayer();

    // 自动加载视频详情
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(videoDetailProvider(widget.video.id).notifier)
          .loadVideoDetail(widget.video.id);
      // 自动标记已看
      //TODO 这里应该在播放器的回调上面调用
      ref.read(videoDetailProvider(widget.video.id).notifier).markSeen();
    });
  }

  void _initializeVideoPlayer() {
    _videoPlayerController = VideoPlayerController.networkUrl(
      Uri.parse(widget.video.url),
    );

    _videoPlayerController
        .initialize()
        .then((_) {
          _chewieController = ChewieController(
            videoPlayerController: _videoPlayerController,
            showControls: true,
            autoPlay: kIsWeb,
            looping: true,
          );
          setState(() {
            _isVideoInitialized = true;
          });
        })
        .catchError((error) {
          debugPrint("Error initializing video player: $error");
        });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _videoPlayerController.pause();
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  void _pauseAndNavigate(VideoInfo video) {
    _videoPlayerController.pause();

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => LongVideoDetailPage(video: video)),
    ).then((_) {
      _videoPlayerController.play();
    });
  }

  @override
  Widget build(BuildContext context) {
    final videoState = ref.watch(videoDetailProvider(widget.video.id));
    final videoNotifier = ref.read(
      videoDetailProvider(widget.video.id).notifier,
    );
    final video = videoState.video;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // 🎬 上半部分：视频播放器
            AspectRatio(
              aspectRatio: 16 / 9,
              child: _isVideoInitialized && _chewieController != null
                  ? Chewie(controller: _chewieController!)
                  : Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned.fill(
                          child: EncryptedImage(
                            url: widget.video.cover,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const CircularProgressIndicator(),
                      ],
                    ),
            ),

            Expanded(
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
                          Tab(text: AppLocalizations.of(context)!.intro),
                          Tab(text: AppLocalizations.of(context)!.comment),
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
                            onRecommendedVideoTap: _pauseAndNavigate,
                            onFavorite: (v) => videoNotifier.toggleFavorite(),
                            onLike: (v) async {
                              videoNotifier.toggleLike();
                            },
                            onFollowPressed: (v) async {
                              videoNotifier.toggleFollow();
                            },
                            onShare: () => videoNotifier.shareVideo(),
                          ),

                          // 评论页
                          CommentSection(videoId: widget.video.id),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
