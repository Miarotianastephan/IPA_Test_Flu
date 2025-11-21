import 'package:flutter/material.dart';

class VideoActionRow extends StatelessWidget {
  final int likes;
  final int favorites;
  final int shares;
  final bool isLiked;
  final bool isFavorited;
  final Future<void> Function(bool) onLike;
  final Future<void> Function(bool) onFavorite;
  final VoidCallback onShare;

  const VideoActionRow({
    super.key,
    required this.likes,
    required this.favorites,
    required this.shares,
    required this.onLike,
    required this.onFavorite,
    required this.onShare,
    this.isLiked = false,
    this.isFavorited = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultColor = isDark ? Colors.white : Colors.black;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        // 点赞
        _ActionItem(
          icon: isLiked ? Icons.favorite : Icons.favorite_border,
          label: likes.toString(),
          onTap: () {
            onLike(!isLiked);
          },
          color: isLiked ? Colors.redAccent : defaultColor,
        ),

        //收藏
        _ActionItem(
          icon: isFavorited ? Icons.bookmark : Icons.bookmark_border,
          label: favorites.toString(),
          onTap: () {
            onFavorite(!isFavorited);
          },
          color: isFavorited ? Colors.amber : defaultColor,
        ),

        //分享
        _ActionItem(
          icon: Icons.share,
          label: shares.toString(),
          onTap: onShare,
          showLabel: false,
          color: defaultColor,
        ),
      ],
    );
  }
}

class _ActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool showLabel;
  final Color color;

  const _ActionItem({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 28, color: color),
          const SizedBox(height: 4),
          if (showLabel)
            Text(label, style: TextStyle(fontSize: 12, color: color))
          else
            const SizedBox(height: 16),
        ],
      ),
    );
  }
}
