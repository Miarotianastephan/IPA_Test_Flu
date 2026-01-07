import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/provider/i18n_provider.dart';

class SaveButtonEditUser extends ConsumerWidget {
  final VoidCallback onPressed;

  const SaveButtonEditUser({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final i18n = ref.read(i18nNotifierProvider.notifier);

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.colorScheme.onSecondary,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      onPressed: onPressed,
      child: Text(i18n.translate('save'), style: const TextStyle(fontSize: 18)),
    );
  }
}
