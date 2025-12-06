import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/l10n/app_localizations.dart';
import '../provider/video_detail_provider.dart';
import '../widgets/video/short_video_item.dart';
import 'user_detail_page.dart';

class ShortVideoPage extends ConsumerStatefulWidget {
  final int videoId;
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

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final state = ref.watch(videoDetailProvider(widget.videoId));
    final notifier = ref.read(videoDetailProvider(widget.videoId).notifier);

    if (state.loading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    if (state.error != null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text("${AppLocalizations.of(context)!.error}: ${state.error}"),
        ),
      );
    }

    final video = state.video;
    if (video == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: Text(AppLocalizations.of(context)!.noVideoContent)),
      );
    }

    final heroTag = widget.heroTagPrefix != null
        ? "${widget.heroTagPrefix}_${video.id}"
        : "video_${video.id}";

    return Scaffold(
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
                      videoInfo: video,
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
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
