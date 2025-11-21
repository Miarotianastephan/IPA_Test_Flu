import 'package:flutter/material.dart';

class VideoOverlayIcon extends StatelessWidget {
  final bool visible;
  final IconData icon;

  const VideoOverlayIcon({super.key, required this.visible, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(color: Colors.transparent),
        if (visible)
          Center(
            child: Icon(icon, size: 60, color: Colors.white),
          ),
      ],
    );
  }
}
