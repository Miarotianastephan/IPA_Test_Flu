import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/page/video_tag_category_page.dart';
import 'package:live_app/provider/category_tag_provider.dart';
import 'package:live_app/utils/app_lang_version_utils.dart';

class CategorySpecificTags extends ConsumerWidget {
  final int categoryId;
  final String categoryName;
  final bool showTitle;

  const CategorySpecificTags({
    super.key,
    required this.categoryId,
    required this.categoryName,
    this.showTitle = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryTagState = ref.watch(
      videoCategoryTagProvider(categoryId.toString()),
    );

    if (categoryTagState.list.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          child: AppLangVersionUtils.isCn() || AppLangVersionUtils.isTk()
              ? _buildGridLayout(context, categoryTagState.list)
              : _buildWrapLayout(context, categoryTagState.list),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildGridLayout(BuildContext context, List<dynamic> tags) {
    const int tagsPerRow = 4;
    const double spacing = 4.0;

    final List<List<dynamic>> rows = [];
    for (int i = 0; i < tags.length; i += tagsPerRow) {
      rows.add(
        tags.sublist(
          i,
          i + tagsPerRow > tags.length ? tags.length : i + tagsPerRow,
        ),
      );
    }

    return Column(
      children: rows.map((row) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 4.0),
          child: Row(
            children: List.generate(tagsPerRow, (index) {
              if (index < row.length) {
                final tag = row[index];
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: index < tagsPerRow - 1 ? spacing : 0,
                    ),
                    child: _buildTagItem(context, tag),
                  ),
                );
              } else {
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: index < tagsPerRow - 1 ? spacing : 0,
                    ),
                    child: const SizedBox.shrink(),
                  ),
                );
              }
            }),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildWrapLayout(BuildContext context, List<dynamic> tags) {
    return Wrap(
      alignment: WrapAlignment.start,
      crossAxisAlignment: WrapCrossAlignment.start,
      spacing: 4,
      runSpacing: 8,
      children: tags.map((tag) => _buildTagItem(context, tag)).toList(),
    );
  }

  Widget _buildTagItem(BuildContext context, dynamic tag) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VideoTagCategoryPage(
              title: tag.name,
              type: VideoTagCategoryType.tag,
              id: tag.id,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Color(0xFF202222),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          tag.name,
          style: const TextStyle(color: Colors.white, fontSize: 12),
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
