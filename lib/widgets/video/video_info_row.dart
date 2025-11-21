import 'package:flutter/material.dart';

class VideoInfoRow extends StatelessWidget {
  final String title;
  final int views;
  final int comments;
  final String publishTime;
  final String description;
  final bool expanded;
  final VoidCallback onToggleExpanded;

  const VideoInfoRow({
    super.key,
    required this.title,
    required this.views,
    required this.comments,
    required this.publishTime,
    required this.description,
    required this.expanded,
    required this.onToggleExpanded,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque, // 点击整个区域都响应
      onTap: onToggleExpanded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 第一行：标题 + 右侧箭头
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Icon(
                expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                color: Colors.grey,
                size: 24,
              ),
            ],
          ),
          const SizedBox(height: 8),

          // 视频数据：播放量 / 评论数 / 发布时间
          Row(
            children: [
              Row(
                children: [
                  const Icon(Icons.play_arrow, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    '$views',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Row(
                children: [
                  const Icon(Icons.comment, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    '$comments',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                publishTime,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // 视频简介（可展开/收起）
          if (expanded) Text(description, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
