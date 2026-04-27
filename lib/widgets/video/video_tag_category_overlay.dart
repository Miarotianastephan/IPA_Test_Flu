import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/provider/category_tag_provider.dart';
import 'package:live_app/provider/i18n_provider.dart';
import 'package:live_app/widgets/video/video_tag_category_wrap.dart';

import '../../page/video_tag_category_page.dart';

class VideoTagCategoryOverlay extends ConsumerStatefulWidget {
  final VoidCallback onClose;

  const VideoTagCategoryOverlay({super.key, required this.onClose});

  @override
  ConsumerState<VideoTagCategoryOverlay> createState() =>
      TagCategoryOverlayPanelState();
}

class TagCategoryOverlayPanelState
    extends ConsumerState<VideoTagCategoryOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _heightCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 200),
    value: 0.0,
  );

  bool _loading = true;
  bool _showAllCategories = false;

  // 分类
  late final categoryProvider = videoCategoryListProvider(false);
  late final VideoCategoryListNotifier categoryNotifier;

  // 标签
  late final tagNotifier = ref.read(videoTagListProvider.notifier);

  // 分类特定标签
  late final categoryTagNotifier = ref.read(
    videoCategoryTagProvider("0").notifier,
  );

  @override
  void initState() {
    super.initState();
    categoryNotifier = ref.read(categoryProvider.notifier);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    try {
      // First, load initial page to get total count
      await Future.wait([
        categoryNotifier.fetch(refresh: true, limit: 999),
        tagNotifier.fetch(refresh: true, limit: 999),
      ]);

      while (true) {
        final categoryState = ref.read(categoryProvider);
        final tagState = ref.read(videoTagListProvider);

        final categoryFinished =
            categoryState.finished ||
            categoryState.list.length >= categoryState.total;
        final tagFinished =
            tagState.finished || tagState.list.length >= tagState.total;

        if (categoryFinished && tagFinished) {
          break;
        }

        final futures = <Future>[];

        if (!categoryFinished) {
          futures.add(categoryNotifier.fetch(refresh: false, limit: 999));
        }

        if (!tagFinished) {
          futures.add(tagNotifier.fetch(refresh: false, limit: 999));
        }

        if (futures.isNotEmpty) {
          await Future.wait(futures);
        } else {
          break;
        }
      }
    } catch (e) {
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  void dispose() {
    _heightCtrl.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    if (_heightCtrl.value >= 0.999) {
      _heightCtrl.reverse();
      setState(() {
        _showAllCategories = false;
      });
    } else {
      _heightCtrl.forward();
      setState(() {
        _showAllCategories = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final i18n = ref.read(i18nNotifierProvider.notifier);
    final categoryState = ref.watch(categoryProvider);
    final tagState = ref.watch(videoTagListProvider);

    final size = MediaQuery.of(context).size;
    final full =
        size.height - (MediaQuery.of(context).padding.top + kToolbarHeight);
    final half = 300;

    // Show only 6 categories when not expanded, all when expanded
    final displayedCategories = _showAllCategories
        ? categoryState.list
        : categoryState.list.take(6).toList();

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onVerticalDragUpdate: (d) {
        final delta = d.delta.dy / 200;
        final next = (_heightCtrl.value + delta).clamp(0.0, 1.0);
        if (next != _heightCtrl.value) {
          _heightCtrl.value = next;
          setState(() {});
        }
      },
      onVerticalDragEnd: (d) {
        final expandedNow = _heightCtrl.value >= 0.999;
        if (!expandedNow && _heightCtrl.value < 0.05) {
          widget.onClose();
          return;
        }
        final snapToFull = _heightCtrl.value >= 0.5;
        if (snapToFull) {
          _heightCtrl.forward();
        } else {
          _heightCtrl.reverse();
        }
      },
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
                        SafeArea(
                          top: false,
                          child: NotificationListener<ScrollNotification>(
                            onNotification: (ScrollNotification notification) {
                              if (notification is ScrollUpdateNotification) {
                                final pixels = notification.metrics.pixels;
                                final max =
                                    notification.metrics.maxScrollExtent + 200;
                                final delta = notification.scrollDelta ?? 0;

                                const threshold = 50.0; // 允许的误差范围，可以根据实际调整

                                // 判断是否到达底部（允许有一点误差）
                                final isAtBottom =
                                    (max - pixels).abs() <= threshold;

                                if (isAtBottom && delta > 0) {
                                  // 用户确实滑到底部，并且继续向上滑动
                                  widget.onClose();
                                  return true;
                                }
                              }
                              return false;
                            },
                            child: ListView(
                              padding: EdgeInsets.zero,
                              physics: expanded
                                  ? const BouncingScrollPhysics(
                                      parent: AlwaysScrollableScrollPhysics(),
                                    )
                                  : const NeverScrollableScrollPhysics(),
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(12),
                                  child: Text(
                                    i18n.translate("allCategories"),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Wrap(
                                      alignment: WrapAlignment.start,
                                      crossAxisAlignment:
                                          WrapCrossAlignment.start,
                                      spacing: 4,
                                      runSpacing: 10,
                                      children: [
                                        // Display categories
                                        ...displayedCategories.map(
                                          (category) => GestureDetector(
                                            onTap: () {
                                              widget.onClose();
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      VideoTagCategoryPage(
                                                        title: category.name,
                                                        type:
                                                            VideoTagCategoryType
                                                                .category,
                                                        id: category.id,
                                                      ),
                                                ),
                                              );
                                            },
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 6,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.white24,
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                category.name,
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 15,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        if (!_showAllCategories &&
                                            categoryState.list.length > 6)
                                          GestureDetector(
                                            onTap: _toggleExpand,
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 6,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.white24,
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                '... +${categoryState.list.length - 6}',
                                                style: TextStyle(
                                                  color: Colors.white
                                                      .withOpacity(0.8),
                                                  fontSize: 15,
                                                  fontStyle: FontStyle.italic,
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),

                                Padding(
                                  padding: EdgeInsets.all(12),
                                  child: Text(
                                    i18n.translate("allTags"),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: VideoTagCategoryWrap(
                                    tags: tagState.list,
                                    categories: [],
                                    categoryColor: Colors.white,
                                    fontSize: 15,
                                    onBeforeNavigate: widget.onClose,
                                  ),
                                ),
                              ],
                            ),
                          ),
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

class TagCategoryOverlay {
  static OverlayEntry? _entry;
  static late AnimationController _ctrl;

  static bool get isShown => _entry != null;

  static void show({
    required BuildContext context,
    required VoidCallback onClose,
    required TickerProvider vsync,
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
                  child: VideoTagCategoryOverlay(onClose: hide),
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
