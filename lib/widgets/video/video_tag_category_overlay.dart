import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/l10n/app_localizations.dart';
import 'package:live_app/widgets/video/video_tag_category_wrap.dart';

import '../../provider/category_tag_provider.dart';

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

  // 分类
  late final categoryProvider = videoCategoryListProvider(false);
  late final VideoCategoryListNotifier categoryNotifier;

  // 标签
  late final tagNotifier = ref.read(videoTagListProvider.notifier);

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
      await Future.wait([
        categoryNotifier.fetch(refresh: true, limit: 999),
        tagNotifier.fetch(refresh: true, limit: 999),
      ]);
    } catch (e) {
      debugPrint('加载分类或标签失败: $e');
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
    } else {
      _heightCtrl.forward();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final categoryState = ref.watch(categoryProvider);
    final tagState = ref.watch(videoTagListProvider);
    final size = MediaQuery.of(context).size;
    final full =
        size.height - (MediaQuery.of(context).padding.top + kToolbarHeight);
    final half = 300;

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
                                    localizations.allCategories,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: VideoTagCategoryWrap(
                                    tags: [],
                                    categories: categoryState.list,
                                    categoryColor: Colors.white,
                                    fontSize: 15,
                                    onBeforeNavigate: widget.onClose,
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(12),
                                  child: Text(
                                    localizations.allTags,
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
