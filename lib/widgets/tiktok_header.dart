import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/provider/i18n_provider.dart';

import '../page/search_page.dart';

class TikTokHeader extends ConsumerWidget {
  final VoidCallback? onVideoCallPressed;
  final VoidCallback? onSearchPressed;
  final TabController controller;

  const TikTokHeader({
    super.key,
    required this.controller,
    this.onVideoCallPressed,
    this.onSearchPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final i18n = ref.read(i18nNotifierProvider.notifier);

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Row(
        children: [
          // Center TabBar
          Expanded(
            child: TabBar(
              controller: controller,
              indicator: const BoxDecoration(), // hide underline
              labelColor: Colors.white,
              labelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              unselectedLabelStyle: TextStyle(
                fontSize: 14,
                color: const Color.fromRGBO(255, 255, 255, 0.8),
              ),
              tabs: [
                Tab(text: i18n.translate('follow')),
                Tab(text: i18n.translate('recommend')),
                Tab(text: i18n.translate('verify')),
                Tab(text: i18n.translate('featured')),
              ],
            ),
          ),

          // Right action: search
          IconButton(
            onPressed:
                onSearchPressed ??
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SearchPage()),
                  );
                },
            icon: const Icon(Icons.search, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
