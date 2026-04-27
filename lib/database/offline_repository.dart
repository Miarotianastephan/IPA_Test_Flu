import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:ffmpeg_kit_flutter_new/session.dart';
import 'package:flutter/material.dart';
import 'package:live_app/api/services/notification_service.dart';
import 'package:live_app/database/download_database.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:live_app/services/hls_proxy_server.dart';

class OfflineRepository {
  static final OfflineRepository instance = OfflineRepository._internal();

  final AppDatabaseDownload db;
  final Dio _dio;

  final int storageAlertThresholdBytes;

  final Map<String, CancelToken> cancelTokens = {};
  final Map<String, Future<Session>> ffmpegSessions = {};
  final Map<String, bool> paused = {};
  final Map<String, String> activeSavePaths = {};
  OfflineRepository(
    this.db, {
    Dio? dio,
    this.storageAlertThresholdBytes = 500 * 1024 * 1024,
  }) : _dio = dio ?? Dio();
  OfflineRepository._internal()
    : db = AppDatabaseDownload(),
      _dio = Dio(),
      storageAlertThresholdBytes = 500 * 1024 * 1024;
  Future<int> addResource({
    required String id,
    required String title,
    required String type,
    required String url,
    int? durationSeconds,
    required String coverUrl,
  }) async {
    return db.insertDownload(
      DownloadsCompanion(
        id: Value(id),
        title: Value(title),
        type: Value(type),
        url: Value(url),
        durationSeconds: Value(durationSeconds),
        status: const Value("pending"),
        coverUrl: Value(coverUrl),
      ),
    );
  }

  Future<String> _defaultSavePath(String id) async {
    final appDir = await getApplicationDocumentsDirectory();
    return p.join(appDir.path, 'downloads', "video_$id.mp4");
  }

  Future<void> _deletePathIfExists(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {}
  }

  Future<void> _cleanupDownloadFiles(String id, {Download? item}) async {
    final candidates = <String>{};
    final localPath = item?.localPath;
    if (localPath != null && localPath.isNotEmpty) {
      candidates.add(localPath);
    }

    final activePath = activeSavePaths[id];
    if (activePath != null && activePath.isNotEmpty) {
      candidates.add(activePath);
    }

    candidates.add(await _defaultSavePath(id));

    for (final path in candidates) {
      await _deletePathIfExists(path);
    }

    activeSavePaths.remove(id);
  }

  String _formatNotificationWithTitle(String template, String title) {
    final placeholderPattern = RegExp(r'\{\s*title\s*\}');
    if (placeholderPattern.hasMatch(template)) {
      return template.replaceAll(placeholderPattern, title);
    }
    return '$template : $title';
  }

  Future<void> downloadResource({
    required String id,
    required String filename,
    required String Function(String key) translate,
  }) async {
    final item = await db.getById(id);
    if (item == null) {
      throw Exception('Resource not found');
    }

    final appDir = await getApplicationDocumentsDirectory();
    final savePath = p.join(appDir.path, 'downloads', filename);
    activeSavePaths[id] = savePath;
    final dir = Directory(p.dirname(savePath));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    await db.updateFields(
      id,
      DownloadsCompanion(status: const Value("downloading")),
    );
    DateTime? lastNotifUpdate;
    try {
      if (item.url.endsWith(".m3u8") || item.url.contains("/playlist/")) {
        final command =
            '-protocol_whitelist file,http,https,tcp,tls,crypto '
            '-allowed_extensions ALL '
            '-i "${item.url}" '
            '-c copy '
            '-bsf:a aac_adtstoasc '
            '"$savePath"';

        final completer = Completer<void>();

        final timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
          if (paused[id] == true) return;
          try {
            final file = File(savePath);
            if (await file.exists()) {
              if (item.url.contains("/playlist/") &&
                  item.url.contains("127.0.0.1")) {
                final match = RegExp(
                  r'/playlist/([^/]+)\.m3u8',
                ).firstMatch(item.url);
                if (match != null) {
                  final sessionId = match.group(1)!;
                  final progress = HlsProxyServer.instance.getProgress(
                    sessionId,
                  );

                  if (progress > 0) {
                    await db.updateFields(
                      id,
                      DownloadsCompanion(
                        progress: Value(progress.floor()),
                        status: const Value("downloading"),
                      ),
                    );
                  }
                }
              } else {
                await db.updateFields(
                  id,
                  DownloadsCompanion(status: const Value("downloading")),
                );
              }
            }
          } catch (e) {
            debugPrint("Erreur lors de la lecture du fichier: $e");
          }
        });

        ffmpegSessions[id] = FFmpegKit.executeAsync(
          command,
          (session) async {
            timer.cancel();
            if (paused[id] == true) {
              if (!completer.isCompleted) completer.complete();
              return;
            }
            final returnCode = await session.getReturnCode();

            if (ReturnCode.isSuccess(returnCode)) {
              final file = File(savePath);
              if (await file.exists()) {
                final size = await file.length();
                await db.updateFields(
                  id,
                  DownloadsCompanion(
                    localPath: Value(savePath),
                    status: const Value("completed"),
                    sizeBytes: Value(size),
                    progress: const Value(100),
                  ),
                );
                activeSavePaths.remove(id);
                final safeId = id.hashCode.abs() % 2147483647;
                await NotificationService.localNotifications.cancel(safeId);
                final completedBody = _formatNotificationWithTitle(
                  translate("videoReady"),
                  item.title,
                );
                NotificationService.showCustomLocalNotification(
                  translate("downloadComplete"),
                  completedBody,
                  "route:/video?path=$savePath",
                );
              }
            } else {
              await db.updateFields(
                id,
                DownloadsCompanion(status: const Value("failed")),
              );
            }
            if (!completer.isCompleted) completer.complete();
          },

          (log) async {
            final message = log.getMessage();
            if (message.contains("Error") ||
                message.contains("error") ||
                message.contains("failed") ||
                message.contains("Invalid")) {
              debugPrint("[DL] FFmpeg LOG: $message");
            }
            if (message.contains("time=")) {
              if (item.url.contains("/playlist/") &&
                  item.url.contains("127.0.0.1")) {
                return;
              }

              final regex = RegExp(r'time=(\d+):(\d+):(\d+)\.(\d+)');
              final match = regex.firstMatch(message);

              if (match != null) {
                final h = int.parse(match.group(1)!);
                final m = int.parse(match.group(2)!);
                final s = int.parse(match.group(3)!);
                final currentSeconds = h * 3600 + m * 60 + s;

                final totalSeconds = item.durationSeconds ?? 0;
                if (totalSeconds > 0) {
                  var progress = (currentSeconds / totalSeconds * 100).floor();
                  progress = progress.clamp(0, 100);
                  await db.updateFields(
                    id,
                    DownloadsCompanion(
                      progress: Value(progress.clamp(0, 100)),
                      status: const Value("downloading"),
                    ),
                  );

                  final now = DateTime.now();
                  if (lastNotifUpdate == null ||
                      now.difference(lastNotifUpdate!).inSeconds >= 3) {
                    lastNotifUpdate = now;

                    final safeId = id.hashCode.abs() % 2147483647;
                    NotificationService.showDownloadProgressNotification(
                      notifId: safeId,
                      title: translate("downloadInProgress"),
                      body: item.title,

                      payload: "route:/DownloadsPage?id=$id",
                    );
                  }
                }
              }
            }
          },
        );

        await completer.future;
        return;
      } else {
        final token = CancelToken();
        cancelTokens[id] = token;
        DateTime? lastNotifUpdate;
        await _dio.download(
          item.url,
          savePath,

          onReceiveProgress: (received, total) async {
            if (paused[id] == true) return;
            if (total > 0) {
              int progress = 0;

              final file = File(savePath);

              if (await file.exists() &&
                  item.sizeBytes != null &&
                  item.sizeBytes! > 0) {
                final size = await file.length();

                progress = (size / item.sizeBytes! * 100).floor();
                progress = progress.clamp(0, 100);
              }
              await db.updateFields(
                id,
                DownloadsCompanion(
                  progress: Value(progress.clamp(0, 100)),
                  status: const Value("downloading"),
                ),
              );
              final now = DateTime.now();
              if (lastNotifUpdate == null ||
                  now.difference(lastNotifUpdate!).inSeconds >= 3) {
                lastNotifUpdate = now;

                final safeId = id.hashCode.abs() % 2147483647;

                NotificationService.showDownloadProgressNotification(
                  notifId: safeId,
                  title: translate("downloadInProgress"),
                  body: item.title,
                  payload: "route:/DownloadsPage?id=$id",
                );
              }
            }
          },
        );
        cancelTokens.remove(id);
      }
      final file = File(savePath);
      if (await file.exists()) {
        final size = await file.length();
        final expectedSize = item.sizeBytes ?? 0;

        if (expectedSize > 0 && size >= expectedSize) {
          await db.updateFields(
            id,
            DownloadsCompanion(
              localPath: Value(savePath),
              status: const Value("completed"),
              sizeBytes: Value(size),
              progress: const Value(100),
            ),
          );
          activeSavePaths.remove(id);
        } else {
          await db.updateFields(
            id,
            DownloadsCompanion(
              localPath: const Value(null),
              status: const Value("pending"),
              sizeBytes: const Value(null),
              progress: const Value(0),
            ),
          );
          await file.delete();
          activeSavePaths.remove(id);
        }
      }
    } catch (e) {
      if (e is DioException && CancelToken.isCancel(e)) {
        final reason = e.message ?? e.error?.toString();
        if (reason == "paused") {
          await db.updateFields(
            id,
            DownloadsCompanion(status: const Value("paused")),
          );
          return;
        } else {
          await db.updateFields(
            id,
            DownloadsCompanion(status: const Value("cancelled")),
          );
          return;
        }
      } else {
        await db.updateFields(
          id,
          DownloadsCompanion(status: const Value("failed")),
        );
      }
    }
  }

  Future<void> cancelDownload(String id) async {
    try {
      if (cancelTokens.containsKey(id)) {
        cancelTokens[id]?.cancel("cancelled");
        cancelTokens.remove(id);
      }
      if (ffmpegSessions.containsKey(id)) {
        final sessionFuture = ffmpegSessions[id];
        if (sessionFuture != null) {
          final session = await sessionFuture;
          await session.cancel();
        }
        ffmpegSessions.remove(id);
      }
      await deleteResource(id);
      final safeId = id.hashCode.abs() % 2147483647;
      await NotificationService.localNotifications.cancel(safeId);

      debugPrint("Téléchargement $id annulé avec succès");
    } catch (e) {
      debugPrint("Erreur lors de l'annulation du téléchargement $id : $e");
    }
  }

  Stream<List<Download>> watchAll() => db.watchAll();
  Stream<List<Download>> watchByType(String type) => db.watchByType(type);

  Future<void> deleteResource(String id) async {
    final item = await db.getById(id);
    await _cleanupDownloadFiles(id, item: item);
    await db.deleteById(id);
    cancelTokens.remove(id);
    ffmpegSessions.remove(id);
    paused.remove(id);
  }

  Future<void> deleteAll() async {
    final items = await db.all();
    for (final token in cancelTokens.values) {
      token.cancel("deleteAll");
    }
    cancelTokens.clear();

    for (final sessionFuture in ffmpegSessions.values) {
      final session = await sessionFuture;
      await session.cancel();
    }
    ffmpegSessions.clear();

    for (final item in items) {
      await _cleanupDownloadFiles(item.id, item: item);
    }
    await db.deleteAll();
    paused.clear();
    activeSavePaths.clear();
  }

  Future<void> pauseDownload(String id) async {
    final item = await db.getById(id);
    if (item == null) return;
    if (cancelTokens.containsKey(id)) {
      cancelTokens[id]?.cancel("paused");
      cancelTokens.remove(id);
    }
    if (ffmpegSessions.containsKey(id)) {
      final sessionFuture = ffmpegSessions[id];
      if (sessionFuture != null) {
        final session = await sessionFuture;
        await session.cancel();
      }
      ffmpegSessions.remove(id);
    }
    paused[id] = true;
    await db.updateFields(
      id,
      DownloadsCompanion(status: const Value("paused")),
    );
  }

  Future<void> resumeDownload({
    required String id,
    required String Function(String key) translate,
  }) async {
    final item = await db.getById(id);
    if (item == null) return;

    paused[id] = false;

    if (item.url.endsWith(".m3u8")) {
      await downloadResource(
        id: id,
        filename: p.basename(item.localPath ?? "video_$id.mp4"),
        translate: translate,
      );
    } else {
      int existingBytes = 0;
      String savePath =
          item.localPath ??
          p.join(
            (await getApplicationDocumentsDirectory()).path,
            'downloads',
            "video_$id.mp4",
          );

      final file = File(savePath);
      if (await file.exists()) {
        existingBytes = await file.length();
      }
      activeSavePaths[id] = savePath;

      final token = CancelToken();
      cancelTokens[id] = token;
      await db.updateFields(
        id,
        DownloadsCompanion(status: const Value("downloading")),
      );

      await _dio.download(
        item.url,
        savePath,
        options: Options(
          headers: existingBytes > 0
              ? {"Range": "bytes=$existingBytes-"}
              : null,
        ),
        cancelToken: token,
        onReceiveProgress: (received, total) async {
          if (paused[id] == true) return;
          final file = File(savePath);
          final size = await file.exists() ? await file.length() : received;
          final newProgress = total > 0 ? (size * 100 ~/ total) : 0;
          final current = await db.getById(id);
          final safeProgress = current != null
              ? newProgress.clamp(current.progress, 100)
              : newProgress;
          await db.updateFields(
            id,
            DownloadsCompanion(
              progress: Value(safeProgress),
              status: const Value("downloading"),
            ),
          );
        },
      );
    }
  }

  Future<void> resetResource(String id) async {
    await db.updateFields(
      id,
      DownloadsCompanion(
        localPath: const Value(null),
        progress: const Value(0),
        status: const Value("pending"),
        sizeBytes: const Value(null),
      ),
    );
  }

  Future<int> getUsedSpaceBytes() async {
    final items = await db.all();
    return items.fold<int>(0, (sum, x) => sum + (x.sizeBytes ?? 0));
  }

  Future<bool> isStorageSaturated() async {
    final used = await getUsedSpaceBytes();
    return used >= storageAlertThresholdBytes;
  }
}
