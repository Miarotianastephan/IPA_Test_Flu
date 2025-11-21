import 'package:flutter/material.dart';
import 'package:live_app/l10n/app_localizations.dart';

class LiveTabPage extends StatelessWidget {
  const LiveTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Center(
      child: Text(
        localizations.live,
        style: const TextStyle(fontSize: 24),
      ),
    );
  }
}
