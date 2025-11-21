

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

  const BannerCarousel({super.key, required this.items});

  @override
  BannerCarouselState createState() => BannerCarouselState();
}

class BannerCarouselState extends State<BannerCarousel> {
  late final PageController _pageController;
  late int _currentPage;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _currentPage = 0;
    _pageController = PageController(initialPage: _currentPage, viewportFraction: 1.0);
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_pageController.hasClients) {
        final currentPage = _pageController.page ?? _currentPage.toDouble();
        int nextPage = currentPage.toInt() + 1;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _pageController,
      itemCount: null,
      onPageChanged: (index) {
        setState(() {
          _currentPage = index;
        });
      },
      itemBuilder: (context, i) {
        final index = i % widget.items.length;
        final item = widget.items[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: GestureDetector(
              onTap: () => {
               
              },
              child: EncryptedImage(url: item.img, fit: BoxFit.cover),
            ),
          ),
        );
      },
    );
  }
}
