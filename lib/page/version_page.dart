import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:live_app/l10n/app_localizations.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class VersionPage extends StatefulWidget {
  const VersionPage({super.key});

  @override
  State<VersionPage> createState() => _VersionPageState();
}

class _VersionPageState extends State<VersionPage> {
  late Future<Map<String, dynamic>> versionFuture;

  @override
  void initState() {
    super.initState();
    versionFuture = fetchVersion();
  }

  Future<Map<String, dynamic>> fetchVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      final currentVersion = info.version;
      final dio = Dio();
      final response = await dio.get("http://localhost/api/user/getAllVersion");

      if (response.statusCode == 200) {
        final data = response.data;
        final latestData = data["data"];

        final latestVersion = latestData["version_number"].toString();
        final description = latestData["description"] ?? "N/A";
        final releaseDate = latestData["date_release"] ?? "N/A";
        final urlAndroid = latestData["url_android"] ?? "";
        final urlIos = latestData["url_ios"] ?? "";
        final isUpdateAvailable = latestVersion != currentVersion;

        return {
          "latestVersion": latestVersion,
          "description": description,
          "releaseDate": releaseDate,
          "urlAndroid": urlAndroid,
          "urlIos": urlIos,
          "updateAvailable": isUpdateAvailable,
        };
      } else {
        throw Exception("Erreur serveur: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Erreur réseau: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.about),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.cancel_outlined),
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: versionFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Erreur: ${snapshot.error}"));
          } else if (!snapshot.hasData) {
            return const Center(child: Text("Aucune donnée"));
          }

          final data = snapshot.data!;
          final latestVersion = data["latestVersion"];
          final description = data["description"];
          final releaseDate = data["releaseDate"];
          final urlAndroid = data["urlAndroid"];
          final urlIos = data["urlIos"];
          final updateAvailable = data["updateAvailable"] as bool;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InfoField(
                  label: AppLocalizations.of(context)!.versionName,
                  value: latestVersion,
                ),
                const SizedBox(height: 12),
                InfoField(
                  label: AppLocalizations.of(context)!.description,
                  value: description,
                ),
                const SizedBox(height: 12),
                InfoField(
                  label: AppLocalizations.of(context)!.releaseDate,
                  value: releaseDate,
                ),
                const SizedBox(height: 24),
                if (updateAvailable)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      const Text(
                        "An update is available :",
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          launchUrl(
                            Uri.parse(urlAndroid),
                          );
                        },
                        child: const Text("Update on Android"),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          launchUrl(Uri.parse(urlIos));
                        },
                        child: const Text("Update on iOS"),
                      ),
                    ],
                  )
                else
                  const Text(
                    "Your application is up to date.",
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
