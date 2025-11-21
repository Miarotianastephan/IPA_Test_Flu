import 'package:flutter/material.dart';

class ImageSequencePlayer extends StatefulWidget {
  final String directory;
  final String prefix;
  final int frameCount;
  final int fps;
  final bool loop;
  final double? width;
  final double? height;

  const ImageSequencePlayer({
    super.key,
    required this.directory,
    required this.prefix,
    required this.frameCount,
    this.fps = 24,
    this.loop = true,
    this.width,
    this.height,
  });

  @override
  State<ImageSequencePlayer> createState() => _ImageSequencePlayerState();
}

class _ImageSequencePlayerState extends State<ImageSequencePlayer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<int> _animation;
  bool _isPrecached = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: (1000 ~/ widget.fps) * widget.frameCount,
      ),
    );

    if (widget.loop) {
      _controller.repeat();
    } else {
      _controller.forward();
    }

    _animation = IntTween(begin: 0, end: widget.frameCount - 1).animate(_controller);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isPrecached) {
      for (int i = 0; i < widget.frameCount; i++) {
        precacheImage(
          AssetImage("${widget.directory}${widget.prefix}$i.jpg"),
          context,
        );
      }
      _isPrecached = true;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _pathFor(int index) => "${widget.directory}${widget.prefix}$index.jpg";

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Image.asset(
          _pathFor(_animation.value),
          width: widget.width,
          height: widget.height,
          fit: BoxFit.cover,
          gaplessPlayback: true,
        );
      },
    );
  }
}
