import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/api/services/forum_service.dart';
import 'package:live_app/api/services/i18n_service.dart';
import 'package:live_app/api/services/message_service.dart';
import 'package:live_app/services/hls_proxy_server.dart';

import '../api/api_client.dart';
import '../api/services/app_service.dart';
import '../api/services/user_service.dart';
import '../api/services/video_service.dart';
import '../services/emoji_file_service.dart';

/// 提供 ApiClient 单例
final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

/// AppService
final appServiceProvider = Provider<AppService>((ref) {
  final client = ref.watch(apiClientProvider);
  return AppService(client);
});

/// UserService
final userServiceProvider = Provider<UserService>((ref) {
  final client = ref.watch(apiClientProvider);
  return UserService(client);
});

/// VideoService
final videoServiceProvider = Provider<VideoService>((ref) {
  final client = ref.watch(apiClientProvider);
  return VideoService(client);
});

/// ForumService
final forumServiceProvider = Provider<ForumService>((ref) {
  final client = ref.watch(apiClientProvider);
  return ForumService(client);
});

/// MessageService
final messageServiceProvider = Provider<MessageService>((ref) {
  final client = ref.watch(apiClientProvider);
  return MessageService(client);
});

// I18nService
final i18nServiceProvider = Provider<I18nService>((ref) {
  final client = ref.watch(apiClientProvider);
  return I18nService(client);
});

/// EmojiFileService
final emojiFileServiceProvider = Provider<EmojiFileService>((ref) {
  final client = ref.watch(apiClientProvider);
  return EmojiFileService(client.dio);
});

/// HlsProxyServer
final hlsProxyServerProvider = Provider<HlsProxyServer>((ref) {
  return HlsProxyServer.instance;
});
