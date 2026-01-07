import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/provider/i18n_provider.dart';

class EmptyWidget extends ConsumerWidget {
  final String? message;
  final IconData icon;
  final Color color;

  const EmptyWidget({
    super.key,
    this.message,
    this.icon = Icons.inbox,
    this.color = Colors.grey,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final i18n = ref.read(i18nNotifierProvider.notifier);

    final localMessage = message ?? i18n.translate('noData');

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 64, color: color),
          const SizedBox(height: 12),
          Text(localMessage, style: TextStyle(fontSize: 16, color: color)),
        ],
      ),
    );
  }
}
