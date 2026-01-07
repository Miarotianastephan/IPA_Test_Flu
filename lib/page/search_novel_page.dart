import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/page/search_novel_detail_page.dart';

import 'package:live_app/provider/i18n_provider.dart';

import '../config/storage_config.dart';
import '../widgets/empty_widget.dart';

class NovelSearchPage extends ConsumerStatefulWidget {
  final SearchType type;
  const NovelSearchPage({super.key, required this.type});

  @override
  ConsumerState<NovelSearchPage> createState() => _NovelSearchPageState();
}

class _NovelSearchPageState extends ConsumerState<NovelSearchPage> {
  final TextEditingController _controller = TextEditingController();
  List<String> _history = [];
  String translate(String key) =>
      ref.read(i18nNotifierProvider.notifier).translate(key);
  String get _historyKey {
    switch (widget.type) {
      case SearchType.manga:
        return "search_history_manga";
      case SearchType.roman:
        return "search_history_roman";
      case SearchType.audio:
        return "search_history_audio";
    }
  }

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final list = StorageService.instance.getValue<List<String>>(_historyKey);
    setState(() {
      _history = list ?? [];
    });
  }

  void _removeSingleHistory(int index) async {
    _history.removeAt(index);
    await StorageService.instance.setValue(_historyKey, _history);
    setState(() {});
  }

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

  Future<void> _clearHistory() async {
    await StorageService.instance.setValue(_historyKey, []);
    setState(() => _history.clear());
  }

  void _onSearch(String keyword) {
    keyword = keyword.trim();
    if (keyword.isEmpty) return;
    _saveHistory(keyword);
    _openResultPage(keyword);
  }

  void _openResultPage(String keyword) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            NovelSearchDetailPage(keyword: keyword, type: widget.type),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const background = Colors.black;

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
        child: _buildHistoryList(context),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            autofocus: true,
            textInputAction: TextInputAction.search,
            onSubmitted: _onSearch,
            decoration: InputDecoration(
              hintText: widget.type == SearchType.manga
                  ? translate("searchManga")
                  : widget.type == SearchType.roman
                  ? translate("searchRoman")
                  : translate("searchAudio"),
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
