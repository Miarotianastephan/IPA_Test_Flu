import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/provider/i18n_provider.dart';

class LiveTabPage extends ConsumerWidget {
  const LiveTabPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final i18n = ref.read(i18nNotifierProvider.notifier);

    return Center(
      child: Text(
        i18n.translate('live'),
        style: const TextStyle(fontSize: 24),
      ),
    );
  }
}
