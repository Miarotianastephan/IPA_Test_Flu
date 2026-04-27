import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/models/ad.dart';
import 'package:live_app/utils/ad_utils.dart';
import 'ad_badge.dart';
import 'encrypted_image.dart';

class AdBannerCarousel extends ConsumerStatefulWidget {
  final List<Ad> ads;
  final double height;
  final VoidCallback? onClose;

  const AdBannerCarousel({
    super.key,
    required this.ads,
    this.height = 100,
    this.onClose,
  });

  @override
  ConsumerState<AdBannerCarousel> createState() => AdBannerCarouselState();
}

class AdBannerCarouselState extends ConsumerState<AdBannerCarousel> {
  late final PageController _pageController;
  int _currentIndex = 0;
  Timer? _autoScrollTimer;

  static const _infiniteCenter = 10000;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _infiniteCenter);
    _startAutoScroll();
  }

  @override
  void didUpdateWidget(AdBannerCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.ads.length <= 1 && widget.ads.length > 1) {
      _startAutoScroll();
    }
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    if (widget.ads.length <= 1 || _autoScrollTimer != null) return;
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (mounted && _pageController.hasClients) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 750),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  String? _getAdImageUrl(Ad ad) {
    return ad.imageLargeUrl ?? ad.imageMediumUrl ?? ad.imageSmallUrl;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.ads.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: widget.height,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (page) {
              setState(() {
                _currentIndex = page % widget.ads.length;
              });
            },
            itemBuilder: (context, index) {
              final ad = widget.ads[index % widget.ads.length];
              final imageUrl = _getAdImageUrl(ad);

              if (imageUrl == null) {
                return const SizedBox.shrink();
              }

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: GestureDetector(
                  onTap: () => onAdRedirection(ad, ref),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: EncryptedImage(
                          url: imageUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
                      const Positioned(top: 6, left: 6, child: AdBadge()),
                    ],
                  ),
                ),
              );
            },
          ),
          if (widget.onClose != null)
            Positioned(
              top: 4,
              right: 8,
              child: GestureDetector(
                onTap: widget.onClose,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 13),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
