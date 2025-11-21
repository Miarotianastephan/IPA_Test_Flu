import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/l10n/app_localizations.dart';
import 'package:live_app/page/version_page.dart';
import 'package:live_app/provider/locale_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.settings)),
      body: ListView(
        children: [
          ListTile(
            title: Text(AppLocalizations.of(context)!.language),
            trailing: DropdownButton<Locale>(
              value: currentLocale,
              items: const [
                DropdownMenuItem(value: Locale('en'), child: Text('English')),
                DropdownMenuItem(value: Locale('es'), child: Text('Espanol')),
                DropdownMenuItem(value: Locale('zh'), child: Text('中文')),
              ],
              onChanged: (locale) {
                if (locale != null) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    ref.read(localeProvider.notifier).state = locale;
                  });
                }
              },
            ),
          ),
          ListTile(
            title: Text(AppLocalizations.of(context)!.about),
            onTap: () {
              showDialog(
                context: context,
                builder: (ctx) {
                  return Dialog(
                    child: SizedBox(
                      width: 400,
                      child:
                          const VersionPage(),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
