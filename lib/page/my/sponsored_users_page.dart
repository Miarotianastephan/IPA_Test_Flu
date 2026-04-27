import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/provider/i18n_provider.dart';
import 'package:live_app/provider/sponsored_users_provider.dart';

import '../../widgets/count_item.dart';
import '../../widgets/empty_widget.dart';
import '../../widgets/general_user_tab.dart';

class SponsoredUsersPage extends ConsumerStatefulWidget {
  const SponsoredUsersPage({super.key});

  @override
  ConsumerState<SponsoredUsersPage> createState() => _SponsoredUsersPageState();
}

class _SponsoredUsersPageState extends ConsumerState<SponsoredUsersPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(sponsoredUsersProvider.notifier).fetch(refresh: true),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(sponsoredUsersProvider);
    final i18n = ref.read(i18nNotifierProvider.notifier);
    String translate(String key) => i18n.translate(key);

    final isFirstLoad = state.list.isEmpty && state.loading;
    final isEmpty = state.list.isEmpty && !state.loading;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: Text(translate("sponsoredUsers"))),
      body: RefreshIndicator(
        color: Colors.white,
        onRefresh: () async =>
            ref.read(sponsoredUsersProvider.notifier).fetch(refresh: true),
        child: Column(
          children: [
            _buildStatsHeader(isEmpty ? 0 : state.total, translate),
            Expanded(
              child: isEmpty
                  ? ListView(
                      children: [
                        const SizedBox(height: 48),
                        EmptyWidget(
                          icon: Icons.people_outline,
                          message: translate("noSponsoredUserYet"),
                        ),
                      ],
                    )
                  : GeneralUserTab(
                      loading: state.loading,
                      results: state.list,
                      isLoaded: !isFirstLoad,
                      onRefresh: () => ref
                          .read(sponsoredUsersProvider.notifier)
                          .fetch(refresh: true),
                      onLoadMore: () =>
                          ref.read(sponsoredUsersProvider.notifier).fetch(),
                      finished: state.finished,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsHeader(int total, String Function(String) translate) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [buildCountItem(translate("totalSponsored"), total)],
      ),
    );
  }
}
