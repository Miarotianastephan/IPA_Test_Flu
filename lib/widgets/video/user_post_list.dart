import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/base_list_state.dart';
import '../../models/forum_post.dart';
import '../../models/userinfo.dart';
import '../../provider/user_post_list_provider.dart';
import '../general_post_tab.dart';

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
    final isLoaded =
        state.loading ||
        state.finished ||
        state.list.isNotEmpty ||
        state.total > 0 ||
        state.page > 1;

    return GeneralPostTab(
      loading: state.loading,
      results: state.list,
      isLoaded: isLoaded,
      onRefresh: () => notifier.fetch(refresh: true),
      onLoadMore: () {
        if (state.loading || state.finished) {
          return;
        }
        notifier.fetch(limit: 20);
      },
      finished: state.finished,
    );
  }
}
