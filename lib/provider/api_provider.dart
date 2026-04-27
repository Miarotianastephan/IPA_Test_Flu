import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/api/services/ad_service.dart';
import 'package:live_app/api/services/ad_video_service.dart';
import 'package:live_app/api/services/campaign_service.dart';
import 'package:live_app/api/services/forum_service.dart';
import 'package:live_app/api/services/i18n_service.dart';
import 'package:live_app/api/services/message_service.dart';
import 'package:live_app/api/services/payment_service.dart';
import 'package:live_app/api/services/support_service.dart';
import 'package:live_app/api/services/vip_service.dart';
import 'package:live_app/api/services/video_service.dart';
import 'package:live_app/provider/domain_provider.dart';
import 'package:live_app/provider/user_progress_provider.dart';
import 'package:live_app/services/hls_proxy_server.dart';

import '../api/api_client.dart';
import '../api/services/app_service.dart';
import '../api/services/user_service.dart';
import '../api/services/version_service.dart';
import '../services/currency_service.dart';
import '../services/emoji_file_service.dart';
import '../services/installation_tracking_service.dart';

/// 提供 ApiClient 单例
final apiClientProvider = Provider<ApiClient>((ref) {
  final domainState = ref.watch(domainProvider);

  final client = ApiClient.instance;

  if (domainState.domain?.back != null) {
    client.setBaseUrl(domainState.domain!.back!);
  }

  return client;
});

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

/// PaymentService
final paymentServiceProvider = Provider<PaymentService>((ref) {
  final client = ref.watch(apiClientProvider);
  return PaymentService(client);
});

/// HlsProxyServer
final hlsProxyServerProvider = Provider<HlsProxyServer>((ref) {
  return HlsProxyServer.instance;
});

/// VipService
final vipServiceProvider = Provider<VipService>((ref) {
  final client = ref.watch(apiClientProvider);
  return VipService(client);
});

/// CurrencyService
final currencyServiceProvider = Provider<CurrencyService>((ref) {
  final client = ref.watch(apiClientProvider);
  return CurrencyService(client);
});

/// InstallationTrackingService
final installationTrackingServiceProvider =
    Provider<InstallationTrackingService>((ref) {
      final client = ref.watch(apiClientProvider);
      return InstallationTrackingService(client);
    });

/// VersionService
final versionServiceProvider = Provider<VersionService>((ref) {
  final client = ref.watch(apiClientProvider);
  return VersionService(client);
});

final adServiceProvider = Provider<AdService>((ref) {
  final client = ref.watch(apiClientProvider);
  return AdService(client);
});

/// AdVideoService
final adVideoServiceProvider = Provider<AdVideoService>((ref) {
  final client = ref.watch(apiClientProvider);
  return AdVideoService(client);
});
/// CampaignService
final campaignServiceProvider = Provider<CampaignService>((ref) {
  final client = ref.watch(apiClientProvider);
  return CampaignService(client);
});

/// SupportService
final supportServiceProvider = Provider<SupportService>((ref) {
  final client = ref.watch(apiClientProvider);
  return SupportService(client);
});

/// UserProgress Provider
final userProgressProvider =
    StateNotifierProvider<UserProgressNotifier, UserProgressState>((ref) {
  final service = ref.watch(campaignServiceProvider);
  return UserProgressNotifier(service);
});
