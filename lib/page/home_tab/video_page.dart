import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/provider/i18n_provider.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../models/video_category.dart';
import '../../provider/category_tag_provider.dart';
import '../../provider/cureent_video_user_provider.dart';
import '../../widgets/empty_retry.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/tiktok_scaffold.dart';
import '../../widgets/video/video_inner_tab_section.dart';
import '../../widgets/video/video_tag_category_overlay.dart';
import '../search_page.dart';

class VideoTabPage extends ConsumerStatefulWidget {
  final TikTokScaffoldController? tkcontroller;

  const VideoTabPage({super.key, this.tkcontroller});

  @override
  ConsumerState<VideoTabPage> createState() => _VideoTabPageState();
}

class _VideoTabPageState extends ConsumerState<VideoTabPage>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  List<VideoCategory> _categories = [];
  bool _hasLoaded = false;
  final Map<int, String> _sortTypeByCategory = {};
  bool _isShortVideoCategoryAt(int index) {
    if (_categories.isEmpty || index >= _categories.length) {
      return false;
    }
    final i18n = ref.read(i18nNotifierProvider.notifier);
    final categoryName = _categories[index].name.toLowerCase();
    final shortTranslation = i18n.translate('short').toLowerCase();
    return categoryName.contains(shortTranslation);
  }

  Future<void> _loadHomeTags() async {
    if (_hasLoaded) {
      return;
    }
    final notifier = ref.read(videoCategoryListProvider(true).notifier);

    await notifier.fetch(refresh: true, limit: 999);

    while (true) {
      var state = ref.read(videoCategoryListProvider(true));

      if (state.finished || state.list.length >= state.total) {
        break;
      }

      await notifier.fetch(refresh: false, limit: 999);
    }

    if (mounted) {
      final state = ref.read(videoCategoryListProvider(true));
      setState(() {
        _categories = state.list;
        _hasLoaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final state = ref.watch(videoCategoryListProvider(true));
    return VisibilityDetector(
      key: const Key('video_tab_visibility'),
      onVisibilityChanged: (info) {
        // 页面真正可见时加载
        if (!_hasLoaded && info.visibleFraction > 0.5) {
          _loadHomeTags();
        }
      },
      child: _buildContent(context, state),
    );
  }

  Widget _buildContent(BuildContext context, dynamic state) {
    if (state.loading && !_hasLoaded) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: LoadingWidget()),
      );
    }

    if (state.finished && _categories.isEmpty) {
      return EmptyWithRetry(onRetry: _loadHomeTags);
    }

    if (_categories.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: LoadingWidget()),
      );
    }

    return DefaultTabController(
      length: _categories.length,
      child: Builder(
        builder: (context) {
          final outerController = DefaultTabController.of(context);
          outerController.addListener(() {
            if (TagCategoryOverlay.isShown) {
              TagCategoryOverlay.hide();
            }
            if (!outerController.indexIsChanging) {
              ref.read(selectedCategoryIdProvider.notifier).state =
                  _categories[outerController.index].id;
            }
          });
          return Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              backgroundColor: Colors.black,
              title: Row(
                children: [
                  Expanded(
                    child: TabBar(
                      controller: DefaultTabController.of(context),
                      isScrollable: true,
                      tabAlignment: TabAlignment.start,
                      tabs: _categories.map((t) => Tab(text: t.name)).toList(),
                      indicatorSize: TabBarIndicatorSize.label,
                      indicator: const BoxDecoration(),
                      labelColor: Colors.white,
                      labelStyle: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      unselectedLabelStyle: TextStyle(
                        fontSize: 14,
                        color: Color.fromRGBO(255, 255, 255, 0.8),
                      ),
                    ),
                  ),

                  IconButton(
                    icon: const Icon(Icons.more_horiz, color: Colors.white),
                    onPressed: () {
                      if (TagCategoryOverlay.isShown) {
                        TagCategoryOverlay.hide();
                      } else {
                        TagCategoryOverlay.show(
                          context: context,
                          onClose: TagCategoryOverlay.hide,
                          vsync: this,
                        );
                      }
                    },
                  ),

                  IconButton(
                    icon: const Icon(Icons.search, color: Colors.white),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SearchPage()),
                      );
                    },
                  ),
                ],
              ),
            ),
            body: TabBarView(
              controller: outerController,
              children: List.generate(
                _categories.length,
                (index) => VideoInnerTabSection(
                  onUserTap: (info) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      ref.read(currentVideoUserProvider.notifier).state =
                          info.user;
                    });
                    widget.tkcontroller?.animateToRightWithTempGesture();
                  },
                  categoryId: _categories[index].id,
                  outerController: outerController,
                  sortTypeByCategory: _sortTypeByCategory,
                  videoType: _isShortVideoCategoryAt(index) ? 1 : null,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
