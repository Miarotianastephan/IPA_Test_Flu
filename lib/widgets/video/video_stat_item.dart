import 'package:flutter/material.dart';

class VideoStatItem extends StatelessWidget {
  final IconData icon;
  final int count;
  final Color color;
  final double size;
  final double fontSize;
  final bool hasColor;

  const VideoStatItem({
    super.key,
    required this.icon,
    required this.count,
    this.color = Colors.white70,
    this.size = 15,
    this.fontSize = 14,
    this.hasColor = false,
  });

  @override
  Widget build(BuildContext context) {
    final displayColor = hasColor ? color : Colors.white70;
    return Row(
      children: [
        Icon(icon, color: displayColor, size: size),
        const SizedBox(width: 2),
        Text(
          "$count",
          style: TextStyle(color: displayColor, fontSize: fontSize),
        ),
      ],
    );
  }
}
