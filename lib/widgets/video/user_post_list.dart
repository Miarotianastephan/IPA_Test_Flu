import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/base_list_state.dart';
import '../../models/forum_post.dart';
import '../../models/userinfo.dart';
import '../../provider/user_post_list_provider.dart';
import '../empty_retry.dart';
import '../forum/forum_post_card.dart';

class UserPostList extends ConsumerStatefulWidget {
  final UserInfo user;

  const UserPostList({super.key, required this.user});

  @override
  ConsumerState<UserPostList> createState() => _UserPostListState();
}

class _UserPostListState extends ConsumerState<UserPostList>
    with AutomaticKeepAliveClientMixin {
  late final StateNotifierProvider<
    UserPostListNotifier,
    BaseListState<ForumPost>
  >
  provider;
  late final UserPostListNotifier notifier;

  @override
  void initState() {
    super.initState();
    provider = userPostListProvider(widget.user.id);
    notifier = ref.read(provider.notifier);
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final state = ref.watch(provider);

    if (state.total == 0 && !state.loading) {
      return EmptyWithRetry(onRetry: () => notifier.fetch(refresh: true));
    }

    return RefreshIndicator(
      onRefresh: () => notifier.fetch(refresh: true),
      color: Colors.white,
      child: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (scrollInfo.metrics.pixels >=
                  scrollInfo.metrics.maxScrollExtent -
                      scrollInfo.metrics.viewportDimension &&
              !state.loading &&
              !state.finished) {
            notifier.fetch(limit: 20);
          }
          return false;
        },
        child: CustomScrollView(
          slivers: [
            SliverList(
              delegate: SliverChildBuilderDelegate((_, index) {
                if (index == state.list.length) {
                  if (state.finished) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                        child: Text(
                          "没有更多了",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  }

                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  );
                }

                final post = state.list[index];
                return ForumPostCard(post: post);
              }, childCount: state.list.length + 1),
            ),
          ],
        ),
      ),
    );
  }
}
