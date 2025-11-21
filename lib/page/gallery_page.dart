import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:video_player/video_player.dart';

class GalleryPage extends StatefulWidget {
  final List<GalleryItem> items;
  final int initialIndex;

  const GalleryPage({super.key, required this.items, this.initialIndex = 0});

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);

    // 监听 PageView 滑动
    _pageController.addListener(() {
      final page = _pageController.page?.round() ?? 0;
      if (page != _currentIndex) {
        setState(() => _currentIndex = page);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: true,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: widget.items.length,
              itemBuilder: (_, index) {
                final item = widget.items[index];

                return PhotoViewGallery.builder(
                  itemCount: widget.items.length,
                  pageController: _pageController,
                  builder: (ctx, index) {
                    final item = widget.items[index];

                    if (item.isVideo) {
                      return PhotoViewGalleryPageOptions.customChild(
                        child: _VideoPlayerView(url: item.url),
                      );
                    }

                    return PhotoViewGalleryPageOptions(
                      imageProvider: NetworkImage(item.url),
                      minScale: PhotoViewComputedScale.contained,
                      maxScale: PhotoViewComputedScale.covered * 2.5,
                    );
                  },
                  onPageChanged: (i) => setState(() => _currentIndex = i),
                );
              },
            ),

            // 返回按钮
            Positioned(
              left: 5,
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                  size: 25,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),

            // ---------- 页面指示器 ----------
            Positioned(
              right: 10,
              top: 5,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 6,
                  horizontal: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.35), // 透明白色
                  borderRadius: BorderRadius.circular(20), // 更圆的胶囊
                  // backdropFilter: ImageFilter.blur(sigmaX: 5, sigmaY: 5), // 毛玻璃效果（可选）
                ),
                child: Text(
                  "${_currentIndex + 1} / ${widget.items.length}",
                  style: const TextStyle(
                    color: Colors.black, // 白底用黑字更清晰
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GalleryItem {
  final String url;
  final bool isVideo;

  GalleryItem({required this.url, this.isVideo = false});
}

/// ---------- 视频播放 UI ----------
class _VideoPlayerView extends StatefulWidget {
  final String url;

  const _VideoPlayerView({required this.url});

  @override
  State<_VideoPlayerView> createState() => _VideoPlayerViewState();
}

class _VideoPlayerViewState extends State<_VideoPlayerView> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.url)
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _controller.value.isInitialized
          ? AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            )
          : const CircularProgressIndicator(color: Colors.white),
    );
  }
}
