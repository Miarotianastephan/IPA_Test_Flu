import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/page/search_detail_page.dart';
import 'package:live_app/constants/ad_placement.dart';
import 'package:live_app/provider/ad_provider.dart';
import 'package:live_app/provider/i18n_provider.dart';
import 'package:live_app/widgets/ad_banner_carousel.dart';
import 'package:live_app/widgets/html_text_field.dart';

import '../config/storage_config.dart';
import '../widgets/empty_widget.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final TextEditingController _controller = TextEditingController();

  List<String> _history = [];

  static const String _historyKey = "search_history";

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref
          .read(adListProvider(AdPlacement.videoFeedInFeed).notifier)
          .fetch(refresh: true);
    });
    _loadHistory();
  }

  /// 加载历史记录
  Future<void> _loadHistory() async {
    final list = StorageService.instance.getValue<List<dynamic>>(_historyKey);
    setState(() {
      _history = list?.cast<String>() ?? [];
    });
  }

  /// 删除单条记录
  void _removeSingleHistory(int index) async {
    _history.removeAt(index);
    await StorageService.instance.setValue(_historyKey, _history);
    setState(() {});
  }

  /// 保存历史记录
  Future<void> _saveHistory(String keyword) async {
    keyword = keyword.trim();
    if (keyword.isEmpty) return;

    if (!_history.contains(keyword)) {
      _history.insert(0, keyword);
      if (_history.length > 10) _history.removeLast();
    }

    await StorageService.instance.setValue(_historyKey, _history);
    setState(() {});
  }

  /// 清空历史
  Future<void> _clearHistory() async {
    await StorageService.instance.setValue(_historyKey, []);
    setState(() => _history.clear());
  }

  /// 执行搜索（跳到其他页面）
  void _onSearch(String keyword) {
    keyword = keyword.trim();
    if (keyword.isEmpty) return;

    _saveHistory(keyword);
    _openResultPage(keyword);
  }

  void _openResultPage(String keyword) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SearchDetailPage(keyword: keyword)),
    );
  }

  @override
  Widget build(BuildContext context) {
    const background = Colors.black;
    final adState = ref.watch(adListProvider(AdPlacement.videoFeedInFeed));

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        title: _buildSearchBar(),
      ),
      body: Container(
        color: background,
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            if (adState.list.isNotEmpty) ...[
              AdBannerCarousel(ads: adState.list),
              const SizedBox(height: 8),
            ],
            Expanded(child: _buildHistoryList(context)),
          ],
        ),
      ),
    );
  }

  /// 搜索栏 UI
  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: HtmlTextField(
            controller: _controller,
            autofocus: true,
            cursorColor: Colors.white,
            textInputAction: TextInputAction.search,
            onSubmitted: _onSearch,
            decoration: InputDecoration(
              hintText: ref
                  .read(i18nNotifierProvider.notifier)
                  .translate("searchPlaceholder"),
              filled: true,
              fillColor: Colors.white12,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.search, color: Colors.white),
          onPressed: () => _onSearch(_controller.text),
        ),
      ],
    );
  }

  /// 搜索历史 UI
  Widget _buildHistoryList(BuildContext context) {
    if (_history.isEmpty) {
      return EmptyWidget(
        message: ref
            .read(i18nNotifierProvider.notifier)
            .translate("noSearchHistory"),
        icon: Icons.history,
        color: Colors.white54,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// 标题 + 清空按钮 + 垃圾桶
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              ref.read(i18nNotifierProvider.notifier).translate("historyTitle"),
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),

            TextButton(
              onPressed: _clearHistory,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    ref.read(i18nNotifierProvider.notifier).translate("clear"),
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.delete, color: Colors.red),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        /// 历史记录 tag（每个带独立删除按钮）
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _history.asMap().entries.map((entry) {
            final index = entry.key;
            final text = entry.value;

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(50),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// 点击标签进行搜索
                  InkWell(
                    onTap: () {
                      _controller.text = text;
                      _onSearch(text);
                    },
                    borderRadius: BorderRadius.circular(50),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 4,
                      ),
                      child: Text(
                        text,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 4),

                  /// 单独删除按钮
                  InkWell(
                    borderRadius: BorderRadius.circular(50),
                    onTap: () => _removeSingleHistory(index),
                    child: const Padding(
                      padding: EdgeInsets.all(3),
                      child: Icon(Icons.close, size: 16, color: Colors.black54),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
