import 'dart:math';

import 'package:flutter/material.dart';

class FollowSplashAnimation extends StatefulWidget {
  final VoidCallback onFinish;

  const FollowSplashAnimation({super.key, required this.onFinish});

  @override
  State<FollowSplashAnimation> createState() => _FollowSplashAnimationState();
}

class _FollowSplashAnimationState extends State<FollowSplashAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward().whenComplete(widget.onFinish);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SplashPainter(_controller),
      child: const SizedBox(width: 40, height: 40),
    );
  }
}

class _SplashPainter extends CustomPainter {
  final Animation<double> animation;

  _SplashPainter(this.animation) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = 20.0 * animation.value; // 扩散半径
    final paint = Paint()
      ..color = Colors.red.withValues(alpha: (1 - animation.value))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (int i = 0; i < 6; i++) {
      final circleSize = 4.0 * (1 - animation.value) + 2.0;
      final rotation = animation.value * pi / 6; // rotate pattern as it expands
      final angle = (2 * pi / 6) * i + rotation;
      final offset = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );
      canvas.drawCircle(offset, circleSize, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SplashPainter oldDelegate) => true;
}
