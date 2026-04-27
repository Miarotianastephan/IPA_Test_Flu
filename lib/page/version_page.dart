import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/api/services/version_service.dart';
import 'package:live_app/models/version.dart';
import 'package:live_app/provider/api_provider.dart';
import 'package:live_app/provider/domain_provider.dart';
import 'package:live_app/provider/i18n_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class VersionPage extends ConsumerStatefulWidget {
  const VersionPage({super.key});

  @override
  ConsumerState<VersionPage> createState() => _VersionPageState();
}

class _VersionPageState extends ConsumerState<VersionPage> {
  late Future<Version?> versionFuture;
  late Future<String> currentVersionFuture;

  @override
  void initState() {
    super.initState();
    currentVersionFuture = VersionService.getCurrentVersion();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final versionService = ref.read(versionServiceProvider);
    versionFuture = versionService.fetchVersion();
  }

  @override
  Widget build(BuildContext context) {
    final i18n = ref.read(i18nNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(i18n.translate('about')),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.cancel_outlined),
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: Future.wait([versionFuture, currentVersionFuture]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('${i18n.translate('error')}: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData) {
            return Center(child: Text(i18n.translate('noData')));
          }

          final results = snapshot.data!;
          final version = results[0] as Version?;
          final currentVersion = results[1] as String;

          if (version == null) {
            return Center(child: Text(i18n.translate('noData')));
          }

          final updateAvailable = VersionService.isUpdateAvailable(
            version.versionNumber,
            currentVersion,
          );

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                InfoField(
                  label: i18n.translate('currentVersion'),
                  value: currentVersion,
                ),
                const SizedBox(height: 12),
                InfoField(
                  label: i18n.translate('latestVersion'),
                  value: version.versionNumber,
                ),
                const SizedBox(height: 12),
                InfoField(
                  label: i18n.translate('description'),
                  value: version.description ?? 'N/A',
                ),
                const SizedBox(height: 12),
                InfoField(
                  label: i18n.translate('releaseDate'),
                  value: version.dateRelease ?? 'N/A',
                ),
                const SizedBox(height: 30),
                if (updateAvailable)
                  Column(
                    children: [
                      Text(
                        i18n.translate('newVersionAvailable'),
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (Platform.isAndroid &&
                          version.urlAndroid?.isNotEmpty == true)
                        DownloadButton(
                          label: i18n.translate('download'),
                          icon: const Icon(Icons.android, color: Colors.green),
                          url: version.urlAndroid,
                        ),
                      if (Platform.isIOS && version.urlIos?.isNotEmpty == true)
                        DownloadButton(
                          label: i18n.translate('download'),
                          icon: const Icon(Icons.apple, color: Colors.white),
                          url: version.urlIos,
                        ),
                    ],
                  )
                else
                  Text(
                    i18n.translate('appUpToDate'),
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class InfoField extends StatelessWidget {
  final String label;
  final String value;

  const InfoField({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}

class DownloadButton extends ConsumerWidget {
  final String label;
  final Icon icon;
  final String? url;

  const DownloadButton({
    super.key,
    required this.label,
    required this.icon,
    required this.url,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.colorScheme.onSecondary,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      onPressed: () async {
        if (url?.isNotEmpty == true) {
          final baseUrl = ref.read(domainProvider).domain?.storage;
          final uri = Uri.parse('$baseUrl$url');

          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          } else {
            debugPrint('error URL : $uri');
          }
        }
      },
      icon: icon,
      label: Text(label),
    );
  }
}
