import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:live_app/api/services/version_component.dart';
import 'package:live_app/l10n/app_localizations.dart';
import 'package:live_app/models/version.dart';

import 'package:url_launcher/url_launcher.dart';

class VersionPage extends StatefulWidget {
  const VersionPage({super.key});

  @override
  State<VersionPage> createState() => _VersionPageState();
}

class _VersionPageState extends State<VersionPage> {
  late Future<Version?> versionFuture;
  late Future<String> currentVersionFuture;

  @override
  void initState() {
    versionFuture = VersionComponent.fetchVersion();
    currentVersionFuture = VersionComponent.getCurrentVersion();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final localisations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localisations.about),
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
              child: Text("${localisations.error}: ${snapshot.error}"),
            );
          } else if (!snapshot.hasData) {
            return Center(child: Text(localisations.noData));
          }

          final results = snapshot.data!;
          final version = results[0] as Version?;
          final currentVersion = results[1] as String;
          debugPrint("version $version");
          debugPrint("currentVersion $currentVersion");
          if (version == null) {
            return Center(child: Text(localisations.noData));
          }

          final updateAvailable = VersionComponent.isUpdateAvailable(
            version.versionNumber,
            currentVersion,
          );

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                InfoField(
                  label: localisations.currentVersion,
                  value: currentVersion,
                ),
                const SizedBox(height: 12),
                InfoField(
                  label: localisations.latestVersion,
                  value: version.versionNumber,
                ),
                const SizedBox(height: 12),
                InfoField(
                  label: localisations.description,
                  value: version.description ?? "N/A",
                ),
                const SizedBox(height: 12),
                InfoField(
                  label: localisations.releaseDate,
                  value: version.dateRelease ?? "N/A",
                ),
                const SizedBox(height: 30),
                if (updateAvailable)
                  Column(
                    children: [
                      Text(
                        localisations.newVersionAvailable,
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (Platform.isAndroid &&
                          version.urlAndroid != null &&
                          version.urlAndroid!.isNotEmpty)
                        DownloadButton(
                          label: localisations.download,
                          icon: const Icon(Icons.android, color: Colors.green),
                          url: version.urlAndroid,
                        ),

                      if (Platform.isIOS &&
                          version.urlIos != null &&
                          version.urlIos!.isNotEmpty)
                        DownloadButton(
                          label: localisations.download,
                          icon: const Icon(Icons.apple, color: Colors.white),
                          url: version.urlIos,
                        ),
                    ],
                  )
                else
                  Text(
                    localisations.appUpToDate,
                    style: TextStyle(
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

class DownloadButton extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.colorScheme.onSecondary,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      onPressed: () async {
        if (url != null && url!.isNotEmpty) {
          final baseUrl = dotenv.env['R2_URL'];
          final uri = Uri.parse("$baseUrl$url");

          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          } else {
            debugPrint("error URL : $uri");
          }
        }
      },
      icon: icon,
      label: Text(label),
    );
  }
}
