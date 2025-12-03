import 'package:flutter/material.dart';
import 'package:live_app/l10n/app_localizations.dart';

import '../widgets/empty_widget.dart';

class SystemNotificationPage extends StatelessWidget {
  const SystemNotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final localisations = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(localisations.systemNotification),
      ),
      body: const Center(child: EmptyWidget()),
    );
  }
}
