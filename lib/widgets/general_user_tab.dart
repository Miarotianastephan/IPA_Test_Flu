import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/provider/i18n_provider.dart';

import '../models/userinfo.dart';
import 'empty_retry.dart';
import 'user_list_item.dart';

class GeneralUserTab extends ConsumerWidget {
  final bool loading;
  final List<UserInfo> results;
  final bool isLoaded;
  final VoidCallback onRefresh;
  final VoidCallback onLoadMore;
  final bool finished;
  final String? scrollStorageKey;
  final Function(UserInfo user)? onTap;
  final VoidCallback? onFollowTap;

  const GeneralUserTab({
    super.key,
    required this.loading,
    required this.results,
    required this.isLoaded,
    required this.onRefresh,
    required this.onLoadMore,
    required this.finished,
    this.scrollStorageKey,
    this.onTap,
    this.onFollowTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      color: Colors.white,
      onRefresh: () async => onRefresh(),
      child: !isLoaded
          ? _buildFirstLoading()
          : loading && results.isEmpty
          ? _buildFirstLoading()
          : NotificationListener<ScrollNotification>(
              onNotification: _handleScroll,
              child: results.isEmpty ? _buildEmpty() : _buildList(context, ref),
            ),
    );
  }

  Widget _buildFirstLoading() {
    return const Center(child: CircularProgressIndicator(color: Colors.white));
  }

  Widget _buildEmpty() {
    return Center(child: EmptyWithRetry(onRetry: onRefresh));
  }

  Widget _buildList(BuildContext context, WidgetRef ref) {
    final i18n = ref.read(i18nNotifierProvider.notifier);
    return ListView.separated(
      key: scrollStorageKey == null
          ? null
          : PageStorageKey<String>(scrollStorageKey!),
      itemCount: results.length + (loading ? 1 : 0) + (finished ? 1 : 0),
      separatorBuilder: (_, index) => const Divider(color: Colors.white12),
      itemBuilder: (context, index) {
        if (loading && index == results.length) {
          return _buildLoadMoreIndicator();
        }

        if (finished && index == results.length + (loading ? 1 : 0)) {
          return Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: Text(
                i18n.translate('noMore'),
                style: TextStyle(color: Colors.white),
              ),
            ),
          );
        }

        final item = results[index];
        return UserListItem(user: item, onTap: onTap, onFollowTap: onFollowTap);
      },
    );
  }

  Widget _buildLoadMoreIndicator() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Center(child: CircularProgressIndicator()),
    );
  }

  bool _handleScroll(ScrollNotification scroll) {
    if (isLoaded &&
        !loading &&
        results.isNotEmpty &&
        scroll.metrics.pixels >= scroll.metrics.maxScrollExtent - 300) {
      onLoadMore();
    }
    return false;
  }
}
