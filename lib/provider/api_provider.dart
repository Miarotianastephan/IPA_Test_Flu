import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/api/services/forum_service.dart';
import '../api/api_client.dart';
import '../api/services/app_service.dart';
import '../api/services/user_service.dart';
import '../api/services/video_service.dart';

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