import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/filter_tab.dart';
import '../../models/video_info.dart';
import '../../page/home_tab/home_page.dart';
import '../../provider/home_video_list_provider.dart';
import 'video_grid_tab_view.dart';

class ShortVideoGridPage extends ConsumerStatefulWidget {
  final int type;
  final Function(VideoInfo videoInfo) onUserTap; // 新增：点击头像回调

  const ShortVideoGridPage({
    super.key,
    required this.type,
    required this.onUserTap,
  });

  @override
  ConsumerState<ShortVideoGridPage> createState() => ShortVideoGridPageState();
}

//精选
class ShortVideoGridPageState extends ConsumerState<ShortVideoGridPage>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  final List<int> items = List.generate(20, (i) => i);
  bool _loaded = false;
  late TabController _tabController;
  bool _isDraggingOuter = false;

  Future<void> refresh() async {
    debugPrint("精选刷新中...");
    final currentTab = getFilterTabs(context)[_tabController.index];
    final provider = homeVideoListProvider((widget.type, currentTab.type));
    final notifier = ref.read(provider.notifier);
    await notifier.fetch(refresh: true);
  }

  @override
  bool get wantKeepAlive => true;

  late List<FilterTab> _filterTabs;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
    _filterTabs = getFilterTabs(context);
    _tabController = TabController(length: _filterTabs.length, vsync: this);
  }

  Future<void> _loadData() async {
    if (_loaded) return;
    _loaded = true;
    await refresh();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final padding = MediaQuery.of(context).padding;

    return DefaultTabController(
      length: 5,
      child: Container(
        padding: EdgeInsets.only(top: padding.top + 40),
        child: Column(
          children: [
            getFilterTabBar(_tabController, context),
            Expanded(
              //用 NotificationListener + GestureDetector 组合控制
              child: NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (notification is OverscrollNotification &&
                      notification.metrics.axis == Axis.horizontal &&
                      !_isDraggingOuter) {
                    final isLastTab =
                        _tabController.index == _tabController.length - 1;
                    final isFirstTab = _tabController.index == 0;

                    if (isLastTab && notification.overscroll > 0) {
                      _isDraggingOuter = true;
                      final targetIndex = (_tabController.index + 1).clamp(
                        0,
                        _tabController.length - 1,
                      );
                      _deferOuterTabChange(context, targetIndex);
                      return true;
                    }

                    if (isFirstTab && notification.overscroll < 0) {
                      _isDraggingOuter = true;
                      final targetIndex = (_tabController.index - 1).clamp(
                        0,
                        _tabController.length - 1,
                      );
                      _deferOuterTabChange(context, targetIndex);
                      return true;
                    }
                  }

                  if (notification is ScrollEndNotification) {
                    _isDraggingOuter = false;
                  }

                  return false;
                },

                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onHorizontalDragStart: (_) {},
                  onHorizontalDragUpdate: (_) {},
                  onHorizontalDragEnd: (_) {
                    _isDraggingOuter = false;
                  },
                  child: TabBarView(
                    controller: _tabController,
                    physics: const ClampingScrollPhysics(),
                    children: getFilterTabs(context).map((tab) {
                      return VideoGridTabView(
                        videoType: widget.type,
                        filterType: tab.type,
                        onUserTap: widget.onUserTap,
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
            SizedBox(height: padding.bottom + 10),
          ],
        ),
      ),
    );
  }

  void _deferOuterTabChange(BuildContext context, int targetIndex) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final parent = context.findAncestorStateOfType<HomeTabPageState>();
      if (parent == null) return;
      final outerController = parent.tabController;
      outerController.animateTo(targetIndex);
    });
  }
}
