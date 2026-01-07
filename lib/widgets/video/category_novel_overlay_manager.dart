import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/models/manga.dart';
import 'package:live_app/models/novel_category.dart';
import 'package:live_app/models/roman.dart';
import 'package:live_app/page/novel_grid.dart';

import 'package:live_app/provider/i18n_provider.dart';
import 'package:live_app/provider/manga_provider.dart';
import 'package:live_app/provider/roman_provider.dart';
import 'package:live_app/widgets/empty_widget.dart';
import 'package:live_app/widgets/selectable_item.dart';

class CategoryOverlay extends ConsumerStatefulWidget {
  final VoidCallback onClose;
  final FutureProvider<List<NovelCategory>> categoryProvider;
  final Future<void> Function() loadCategories;

  const CategoryOverlay({
    super.key,
    required this.onClose,
    required this.categoryProvider,
    required this.loadCategories,
  });

  @override
  ConsumerState<CategoryOverlay> createState() => _CategoryOverlayState();
}

class _CategoryOverlayState extends ConsumerState<CategoryOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _heightCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 200),
    value: 0.0,
  );
  String translate(String key) =>
      ref.read(i18nNotifierProvider.notifier).translate(key);
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    try {
      await widget.loadCategories();
    } catch (e) {
      debugPrint('加载分类失败: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _toggleExpand() {
    if (_heightCtrl.value >= 0.999) {
      _heightCtrl.reverse();
    } else {
      _heightCtrl.forward();
    }
    setState(() {});
  }

  @override
  void dispose() {
    _heightCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final i18n = ref.read(i18nNotifierProvider.notifier);
    final categoryState = ref.watch(widget.categoryProvider);

    final size = MediaQuery.of(context).size;
    final full =
        size.height - (MediaQuery.of(context).padding.top + kToolbarHeight);
    final half = 300;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,

      child: AnimatedBuilder(
        animation: _heightCtrl,
        builder: (context, _) {
          final h = half + (full - half) * _heightCtrl.value;
          final expanded = _heightCtrl.value >= 0.999;
          return SizedBox(
            height: h,
            child: Material(
              color: Colors.black,
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  : Stack(
                      children: [
                        ListView(
                          padding: EdgeInsets.zero,
                          physics: expanded
                              ? const BouncingScrollPhysics(
                                  parent: AlwaysScrollableScrollPhysics(),
                                )
                              : const NeverScrollableScrollPhysics(),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Text(
                                i18n.translate("allCategories"),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: categoryState.when(
                                data: (categories) => NovelCategoryWrap(
                                  categories: categories,
                                  categoryColor: Colors.white,
                                  fontSize: 15,
                                  onBeforeNavigate: widget.onClose,
                                  translate: translate,
                                ),
                                loading: () => const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                ),
                                error: (err, stack) => Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Text(
                                    "${translate("loadError")} $err",
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Positioned(
                          right: 10,
                          top: 8,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: _toggleExpand,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                expanded
                                    ? Icons.fullscreen_exit
                                    : Icons.fullscreen,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          );
        },
      ),
    );
  }
}

class CategoryOverlayManager {
  static OverlayEntry? _entry;
  static late AnimationController _ctrl;

  static bool get isShown => _entry != null;

  static void show({
    required BuildContext context,
    required VoidCallback onClose,
    required TickerProvider vsync,
    required FutureProvider<List<NovelCategory>> categoryProvider,
    required Future<void> Function() loadCategories,
  }) {
    if (_entry != null) return;

    _ctrl = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 200),
    );

    final opacity = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    final offset = Tween(
      begin: const Offset(0, -0.03),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

    _entry = OverlayEntry(
      builder: (_) {
        final top = MediaQuery.of(context).padding.top + kToolbarHeight;
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: hide,
                child: Container(color: Colors.transparent),
              ),
            ),
            Positioned(
              top: top,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: opacity,
                child: SlideTransition(
                  position: offset,
                  child: CategoryOverlay(
                    onClose: hide,
                    categoryProvider: categoryProvider,
                    loadCategories: loadCategories,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    Overlay.of(context).insert(_entry!);
    _ctrl.forward();
  }

  static void hide() {
    if (_entry == null) return;
    _ctrl.reverse().whenComplete(() {
      _entry?.remove();
      _entry = null;
    });
  }
}

class NovelCategoryWrap extends StatelessWidget {
  final List<NovelCategory> categories;
  final Color categoryColor;
  final double fontSize;
  final VoidCallback? onBeforeNavigate;
  final String Function(String) translate;
  const NovelCategoryWrap({
    super.key,
    required this.categories,
    this.categoryColor = Colors.white70,
    this.fontSize = 12,
    this.onBeforeNavigate,
    required this.translate,
  });

  List<Widget> _buildCategoryList(
    List<NovelCategory> items,
    Color textColor,
    Color backgroundColor,
    BuildContext context,
  ) {
    return items
        .map(
          (item) => SelectableItem<NovelCategory>(
            item: item,
            getName: (c) => c.name,
            onBeforeTap: onBeforeNavigate,
            onTap: (c) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => NovelCategoryPage(
                    id: c.id,
                    title: c.name,
                    type: c.type,
                    translate: translate,
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
          ..._buildCategoryList(
            categories,
            categoryColor,
            Colors.white24,
            context,
          ),
        ],
      ),
    );
  }
}

class NovelCategoryPage extends ConsumerWidget {
  final String title;
  final int id;
  final NovelCategoryType type;
  final String Function(String) translate;
  const NovelCategoryPage({
    super.key,
    required this.title,
    required this.id,
    required this.type,
    required this.translate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = switch (type) {
      NovelCategoryType.roman => romanProvider,
      NovelCategoryType.manga => mangaProvider,
      _ => romanProvider,
    };
    final asyncValue = ref.watch(provider);
    return Scaffold(
      appBar: AppBar(title: Text(title), backgroundColor: Colors.black),
      backgroundColor: Colors.black,
      body: asyncValue.when(
        data: (items) {
          final filtered = items.where((item) {
            if (item is Manga) {
              return item.mangasCategory.id == id;
            }
            if (item is Roman) {
              return item.category.id == id;
            }
            return false;
          }).toList();

          if (filtered.isEmpty) {
            return const Center(child: EmptyWidget());
          }
          return NovelGrid(
            items: filtered,
            isAudio: false,
            showCreatorInfo: true,
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Text(
            "${translate("error")} : $err",
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ),
    );
  }
}
