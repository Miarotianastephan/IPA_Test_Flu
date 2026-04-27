import 'package:flutter/material.dart';

class BWProgress extends StatefulWidget {
  const BWProgress({super.key});

  @override
  State<BWProgress> createState() => _BWProgressState();
}

class _BWProgressState extends State<BWProgress>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _color;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _color = ColorTween(
      begin: Colors.white,
      end: Colors.black,
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CircularProgressIndicator(
      strokeWidth: 3,
      valueColor: _color,
    );
  }
}