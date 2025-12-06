import 'dart:async';
import 'package:flutter/material.dart';
import 'encrypted_image.dart';

class BannerItem {
  final String img;
  final String action;

  BannerItem({required this.img, required this.action});
}

class BannerCarousel extends StatefulWidget {
  final List<BannerItem> items;

  const BannerCarousel({
    super.key,
    required this.items,
  });

  @override
  BannerCarouselState createState() => BannerCarouselState();
}

class BannerCarouselState extends State<BannerCarousel> {
  late final PageController _pageController;
  int _currentIndex = 0;
  bool _loadingNext = false;

  static const _infiniteCenter = 10000;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _infiniteCenter);
    _preloadNextImage();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _preloadNextImage() {
    if (_loadingNext) return;
    _loadingNext = true;

    final nextIndex = (_currentIndex + 1) % widget.items.length;
    final nextUrl = widget.items[nextIndex].img;

    final imageProvider = NetworkImage(nextUrl);
    final stream = imageProvider.resolve(const ImageConfiguration());

    late ImageStreamListener listener;
    listener = ImageStreamListener((_, __) {
      stream.removeListener(listener);
      _loadingNext = false;

      if (mounted && _pageController.hasClients) {
        Future.delayed(const Duration(seconds: 3), () {
          if (!mounted) return;
          _pageController.nextPage(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOut,
          );
        });
      }
    });

    stream.addListener(listener);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return const SizedBox.shrink();
    }

    return PageView.builder(
      controller: _pageController,
      itemCount: null,
      onPageChanged: (page) {
        setState(() {
          _currentIndex = page % widget.items.length;
        });
        _preloadNextImage();
      },
      itemBuilder: (context, index) {
        final item = widget.items[index % widget.items.length];

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: GestureDetector(
              onTap: () => {},
              child: EncryptedImage(
                url: item.img,
                fit: BoxFit.cover,
              ),
            ),
          ),
        );
      },
    );
  }
}
