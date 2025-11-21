import 'package:flutter/material.dart';

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  final images = [
    "https://picsum.photos/id/237/400/600",
    "https://picsum.photos/id/238/400/600",
    "https://picsum.photos/id/239/400/600",
    "https://picsum.photos/id/240/400/600",
  ];

  int? _activeIndex; // 当前 detail page 切换回来的 index，也就是应该做动画的那张图

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Hero + PageView Demo")),
      body: GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
        ),
        itemCount: images.length,
        itemBuilder: (context, index) {
          final url = images[index];
          final tag = "img_$index";

          // 在 TestPage 的 GridView itemBuilder 部分：
          return GestureDetector(
            onTap: () {
              setState(() {
                _activeIndex = index;
              });
              Navigator.push(
                context,
                PageRouteBuilder(
                  opaque: false,
                  barrierColor: Colors.transparent,
                  transitionDuration: const Duration(milliseconds: 300),
                  pageBuilder: (_, __, ___) => DetailPage(
                    images: images,
                    initialIndex: index,
                    onPageChanged: (newIndex) {
                      setState(() {
                        _activeIndex = newIndex;
                      });
                    },
                  ),
                  transitionsBuilder: (_, animation, __, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                ),
              ).then((e) {
                setState(() {
                  _activeIndex = null;
                });
              });
            },
            child: Hero(
              tag: tag,
              placeholderBuilder: (context, heroSize, child) {
                return child;
              },
              child: _activeIndex == index
                  ? Container(color: Colors.transparent)
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(url, fit: BoxFit.cover),
                    ),
            ),
          );
        },
      ),
    );
  }
}

class DetailPage extends StatefulWidget {
  final List<String> images;
  final int initialIndex;
  final ValueChanged<int>? onPageChanged;

  const DetailPage({
    super.key,
    required this.images,
    required this.initialIndex,
    this.onPageChanged,
  });

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  int _currentIndex = 0;

  double _dragOffsetX = 0.0;
  double _dragOffsetY = 0.0;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
  }

  void _onDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffsetX += details.delta.dx;
      _dragOffsetY += details.delta.dy;
      if (_dragOffsetX < 0) _dragOffsetX = 0;
    });
  }

  void _onDragEnd(DragEndDetails details) {
    if (_dragOffsetX > 150) {
      Navigator.pop(context);
    } else {
      _controller.forward(from: 0).then((_) {
        setState(() {
          _dragOffsetX = 0;
          _dragOffsetY = 0;
          _controller.reset();
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dragDistance = _dragOffsetX.abs();
    final scale = 1.0 - (dragDistance / 600).clamp(0.0, 0.4);
    final opacity = (1.0 - dragDistance / 300).clamp(0.0, 1.0);

    return GestureDetector(
      onPanUpdate: _onDragUpdate,
      onPanEnd: _onDragEnd,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(
              _dragOffsetX * (1 - _animation.value),
              _dragOffsetY * (1 - _animation.value),
            ),
            child: Transform.scale(
              scale: scale + (1 - scale) * _animation.value,
              child: child,
            ),
          );
        },
        child: Scaffold(
          backgroundColor: Colors.black.withValues(alpha: opacity),
          body: PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
              widget.onPageChanged?.call(index);
            },
            itemCount: widget.images.length,
            itemBuilder: (context, index) {
              final url = widget.images[index];
              return Center(
                child: index == _currentIndex
                    ? Hero(
                        tag: "img_$index",
                        transitionOnUserGestures: true,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(url, fit: BoxFit.contain),
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(url, fit: BoxFit.contain),
                      ),
              );
            },
          ),
        ),
      ),
    );
  }
}
