// 标签 + 分类组件
import 'package:flutter/material.dart';

import '../../models/video_category.dart';
import '../../models/video_tag.dart';
import '../../page/video_tag_category_page.dart';
import '../selectable_item.dart';

class VideoTagCategoryWrap extends StatelessWidget {
  final List<VideoTag> tags;
  final List<VideoCategory> categories;
  final Color tagColor;
  final Color categoryColor;
  final double fontSize;
  final VoidCallback? onBeforeNavigate;

  const VideoTagCategoryWrap({
    super.key,
    required this.tags,
    required this.categories,
    this.tagColor = Colors.white,
    this.categoryColor = Colors.white70,
    this.fontSize = 12,
    this.onBeforeNavigate,
  });

  List<Widget> _buildItemList<T>(
    List<T> items,
    Color textColor,
    Color backgroundColor,
    VideoTagCategoryType type,
    BuildContext context,
  ) {
    return items
        .map(
          (item) => SelectableItem<T>(
            item: item,
            getName: (item) => (item as dynamic).name,
            onBeforeTap: onBeforeNavigate,
            onTap: (item) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => VideoTagCategoryPage(
                    title: (item as dynamic).name,
                    type: type,
                    id: (item as dynamic).id,
                  ),
                ),
              );
            },
            textColor: textColor,
            fontSize: fontSize,
            backgroundColor: backgroundColor,
            borderRadius: 4,
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Wrap(
        alignment: WrapAlignment.start,
        crossAxisAlignment: WrapCrossAlignment.start,
        spacing: 4,
        runSpacing: 10,
        children: [
          ..._buildItemList(
            tags,
            tagColor,
            Colors.white24,
            VideoTagCategoryType.tag,
            context,
          ),
          ..._buildItemList(
            categories,
            categoryColor,
            Colors.white24,
            VideoTagCategoryType.category,
            context,
          ),
        ],
      ),
    );
  }
}
