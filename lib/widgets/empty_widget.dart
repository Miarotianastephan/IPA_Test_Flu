import 'package:flutter/material.dart';
import 'package:live_app/l10n/app_localizations.dart';

class EmptyWidget extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final localMessage = message ?? AppLocalizations.of(context)!.noData;

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
