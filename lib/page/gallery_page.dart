import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/models/ad_video.dart';
import 'package:live_app/models/vip.dart';
import 'package:live_app/provider/ad_video_provider.dart';
import 'package:live_app/provider/api_provider.dart';
import 'package:live_app/provider/app_config_provider.dart';
import 'package:live_app/provider/current_tab_provider.dart';
import 'package:live_app/provider/i18n_provider.dart';
import 'package:live_app/provider/my_user_provider.dart';
import 'package:live_app/provider/purchased_contents_provider.dart';
import 'package:live_app/provider/post_detail_provider.dart';
import 'package:live_app/provider/selected_post_provider.dart';
import 'package:live_app/provider/timer_provider.dart';
import 'package:live_app/provider/video_preview_provider.dart';
import 'package:live_app/provider/vip_provider.dart';
import 'package:live_app/provider/wallet_provider.dart';
import 'package:live_app/services/ad_video_preload_service.dart';
import 'package:live_app/services/payment_orchestrator.dart';
import 'package:live_app/utils/app_lang_version_utils.dart';
import 'package:live_app/utils/json_utils.dart';
import 'package:live_app/utils/toast_util.dart';
import 'package:live_app/widgets/ad_cover_image_screen.dart';
import 'package:live_app/widgets/ad_video_player_screen.dart';
import 'package:live_app/widgets/encrypted_image.dart';
import 'package:live_app/widgets/payment/OptionCard.dart';
import 'package:live_app/widgets/payment/payment_channel_popup.dart';
import 'package:live_app/widgets/video/deposit_promo_overlay.dart';
import 'package:live_app/widgets/video_screen.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class GalleryPage extends ConsumerStatefulWidget {
  final List<GalleryItem> items;
  final int initialIndex;
  final VoidCallback? onPurchaseSuccess;

  const GalleryPage({
    super.key,
    required this.items,
    this.initialIndex = 0,
    this.onPurchaseSuccess,
  });

  @override
  ConsumerState<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends ConsumerState<GalleryPage> {
  late PageController _pageController;
  late int _currentIndex;

  String translate(String key) =>
      ref.read(i18nNotifierProvider.notifier).translate(key);

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);

    _pageController.addListener(() {
      final page = _pageController.page?.round() ?? 0;
      if (page != _currentIndex) {
        setState(() => _currentIndex = page);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedPost = ref.watch(selectedPostProvider);

    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          ref.read(selectedPostProvider.notifier).state = null;
          debugPrint(
            "selectedPostProvider retour — valeur après: ${ref.read(selectedPostProvider)}",
          );
        }
      },
      child: SafeArea(
        top: true,
        child: Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              PhotoViewGallery.builder(
                itemCount: widget.items.length,
                pageController: _pageController,
                builder: (ctx, index) {
                  final item = widget.items[index];
                  final isPostContent = item.contentType == 'posts';
                  final isPostPurchased =
                      isPostContent &&
                      selectedPost?.id == item.contentId &&
                      (selectedPost?.isBought ?? false);
                  final isLocked = item.isLocked && !isPostPurchased;
                  if (item.isVideo) {
                    if (isLocked) {
                      return PhotoViewGalleryPageOptions.customChild(
                        child: _LockedVideoView(
                          thumbnailUrl: item.thumbnailUrl,
                          item: item,
                          onPurchaseSuccess: widget.onPurchaseSuccess,
                        ),
                      );
                    }
                    return PhotoViewGalleryPageOptions.customChild(
                      child: _VideoPlayerView(
                        videoId: item.contentId?.toString() ?? '',
                        url: item.url,
                        encryptionKey: item.encryptionKey,
                      ),
                    );
                  }
                  return PhotoViewGalleryPageOptions.customChild(
                    child: PhotoView.customChild(
                      minScale: PhotoViewComputedScale.contained,
                      maxScale: PhotoViewComputedScale.covered * 2.5,
                      child: EncryptedImage(url: item.url, fit: BoxFit.contain),
                    ),
                  );
                },
                onPageChanged: (i) => setState(() => _currentIndex = i),
              ),

              // 返回按钮
              Positioned(
                left: 5,
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    color: Colors.white,
                    size: 25,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),

              // ---------- 页面指示器 ----------
              Positioned(
                right: 10,
                top: 5,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 6,
                    horizontal: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.35), // 透明白色
                    borderRadius: BorderRadius.circular(20), // 更圆的胶囊
                  ),
                  child: Text(
                    "${_currentIndex + 1} / ${widget.items.length}",
                    style: const TextStyle(
                      color: Colors.black, // 白底用黑字更清晰
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GalleryItem {
  final String url;
  final bool isVideo;
  final String? encryptionKey;
  final bool isLocked;
  final String? thumbnailUrl;
  final double? price;
  final int? contentId;
  final String? contentTitle;
  final String? contentType;

  GalleryItem({
    required this.url,
    this.isVideo = false,
    this.encryptionKey,
    this.isLocked = false,
    this.thumbnailUrl,
    this.price,
    this.contentId,
    this.contentTitle,
    this.contentType,
  });
}

/// ---------- 视频播放 UI ----------
class _VideoPlayerView extends ConsumerStatefulWidget {
  final String url;
  final String? encryptionKey;
  final String videoId;

  const _VideoPlayerView({
    required this.url,
    this.encryptionKey,
    required this.videoId,
  });

  @override
  ConsumerState<_VideoPlayerView> createState() => _VideoPlayerViewState();
}

class _VideoPlayerViewState extends ConsumerState<_VideoPlayerView> {
  bool _isAdPlaying = false;
  AdVideoPreloadService? _preloadService;
  final Set<int> _processedAdDurations = {};
  bool _allAdsProcessed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!kIsWeb) {
        _preloadService = ref.read(adVideoPreloadServiceProvider);
      }
      _processedAdDurations.clear();
      ref.read(timerProvider.notifier).reset();
      ref.read(timerProvider.notifier).start();
      await _getAdVideoList();
    });
  }

  @override
  void dispose() {
    ref.read(timerProvider.notifier).stop();
    if (!kIsWeb) {
      _preloadService?.clearAll();
    }
    super.dispose();
  }

  Future<void> _getAdVideoList() async {
    final adVideoState = ref.read(adVideoListProvider);
    if (adVideoState.adVideoConfigs.isEmpty) {
      await ref.read(adVideoListProvider.notifier).loadAdVideos();
    }

    if (!kIsWeb) {
      _preloadAdVideos();
    }
  }

  Future<void> _preloadAdVideos() async {
    if (_preloadService == null) return;
    final adVideoState = ref.read(adVideoListProvider);

    for (final config in adVideoState.adVideoConfigs) {
      final ads = config.adVideos;
      if (ads != null && ads.isNotEmpty) {
        for (final ad in ads) {
          if (ad.videoUrl != null) {
            await _preloadService!.preloadVideo(ad.videoUrl!, 'xokey');
          }
        }
      }
    }
  }

  Future<void> _checkTimerEvents() async {
    final timerState = ref.read(timerProvider);
    final adVideoState = ref.read(adVideoListProvider);

    if (adVideoState.adVideoConfigs.isEmpty) {
      return;
    }

    if (_isAdPlaying) {
      return;
    }

    final adDurations =
        adVideoState.adVideoConfigs
            .map((config) => config.durationSeconds)
            .toSet()
            .toList()
          ..sort();

    final missedDurations = adDurations
        .where(
          (duration) =>
              timerState.seconds >= duration &&
              !_processedAdDurations.contains(duration),
        )
        .toList();

    if (_processedAdDurations.length >= adDurations.length) {
      if (!_allAdsProcessed) {
        _allAdsProcessed = true;
      }
      return;
    }

    if (missedDurations.isEmpty) {
      return;
    }

    final currentDuration = missedDurations.first;
    _processedAdDurations.add(currentDuration);

    final matchingConfigs = adVideoState.adVideoConfigs.where(
      (config) => config.durationSeconds == currentDuration,
    );

    final hasAdsToPlay = matchingConfigs.any(
      (config) => config.adVideos != null && config.adVideos!.isNotEmpty,
    );

    if (!hasAdsToPlay) {
      return;
    }

    _isAdPlaying = true;

    for (final config in matchingConfigs) {
      final ads = config.adVideos;
      if (ads != null && ads.isNotEmpty) {
        for (final ad in ads) {
          ref.read(timerProvider.notifier).pause();
          if (ad.videoUrl != null && ad.videoUrl!.isNotEmpty) {
            await _playAdVideoFullscreen(ad.videoUrl!, ad.duration);
          } else if (ad.coverImage != null && ad.coverImage!.isNotEmpty) {
            await _showAdCoverImageFullscreen(
              ad.coverImage!,
              ad.duration,
              targetType: ad.targetType,
              jumpUrl: ad.jumpUrl,
              claimUrl: ad.claimUrl,
            );
          }
        }
      }
    }

    if (mounted) {
      ref.read(timerProvider.notifier).resume();
    }

    _isAdPlaying = false;
  }

  Future<void> _playAdVideoFullscreen(String videoUrl, int duration) async {
    String? preloadedProxyUrl;
    String? preloadedSessionId;
    if (!kIsWeb) {
      final preloaded = _preloadService?.getPreloaded(videoUrl);
      if (preloaded != null) {
        preloadedProxyUrl = preloaded.proxyUrl;
        preloadedSessionId = preloaded.sessionId;
      }
    }

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AdVideoPlayerScreen(
          videoUrl: videoUrl,
          encryptionKey: 'xokey',
          duration: duration,
          preloadedProxyUrl: preloadedProxyUrl,
          preloadedSessionId: preloadedSessionId,
          onVideoFinished: () {},
        ),
      ),
    );
  }

  Future<void> _showAdCoverImageFullscreen(
    String coverImageUrl,
    int duration, {
    AdTargetType? targetType,
    String? jumpUrl,
    String? claimUrl,
  }) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AdCoverImageScreen(
          coverImageUrl: coverImageUrl,
          duration: duration,
          targetType: targetType,
          jumpUrl: jumpUrl,
          claimUrl: claimUrl,
          onAdFinished: () {},
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(timerProvider, (previous, next) {
      final isCurrent = ModalRoute.of(context)?.isCurrent ?? false;
      if (mounted && isCurrent) {
        _checkTimerEvents();
      }
    });

    return VideoScreen(
      videoId: widget.videoId,
      videoUrl: widget.url,
      controller: null,
      encryptionKey: widget.encryptionKey,
    );
  }
}

class _LockedVideoView extends ConsumerStatefulWidget {
  final String? thumbnailUrl;
  final GalleryItem item;
  final VoidCallback? onPurchaseSuccess;

  const _LockedVideoView({
    this.thumbnailUrl,
    required this.item,
    this.onPurchaseSuccess,
  });

  @override
  ConsumerState<_LockedVideoView> createState() => _LockedVideoViewState();
}

class _LockedVideoViewState extends ConsumerState<_LockedVideoView> {
  bool _previewEnded = false;
  bool _isUnlocked = false;
  final ValueNotifier<bool> _videoPlayingNotifier = ValueNotifier<bool>(false);
  int _remainingSeconds = 0;
  Timer? _timer;
  bool _hasStarted = false;

  String translate(String key) =>
      ref.read(i18nNotifierProvider.notifier).translate(key);

  void _navigateToGame(BuildContext context) {
    Navigator.of(context).pop();
    final gameTabIndex = ref.read(gameTabIndexProvider);
    ref.read(switchTabRequestProvider.notifier).state = gameTabIndex;
  }

  void _handlePurchaseSuccess() {
    final contentId = widget.item.contentId?.toString();
    final contentType = widget.item.contentType ?? 'posts';
    if (mounted && contentId != null && contentId.isNotEmpty) {
      ref
          .read(purchasedContentProvider.notifier)
          .markAsPurchased(contentType, contentId);

      if (contentType == 'posts') {
        final selectedPost = ref.read(selectedPostProvider);
        if (selectedPost != null && selectedPost.id == widget.item.contentId) {
          ref.read(selectedPostProvider.notifier).state = selectedPost.copyWith(
            isBought: true,
          );
        }

        final postId = widget.item.contentId;
        if (postId != null) {
          ref.read(postDetailProvider(postId).notifier).markAsPurchased();
        }
      }

      setState(() {
        _isUnlocked = true;
        _previewEnded = false;
      });
    }
    widget.onPurchaseSuccess?.call();
  }

  Future<void> _handleDirectPayment() async {
    if (!mounted) return;

    final orchestrator = PaymentOrchestrator(ref, context);
    await orchestrator.purchaseContentDirectly(
      contentType: widget.item.contentType ?? 'posts',
      contentId: (widget.item.contentId ?? 0).toString(),
      price: widget.item.price ?? 0.0,
      contentTitle: widget.item.contentTitle ?? '',
      onPurchased: _handlePurchaseSuccess,
    );
  }

  Future<void> _handleVipSelection(Vip vip) async {
    final walletState = ref.read(walletProvider);
    final balance = walletState.balance?.balance ?? 0.0;
    final price = double.tryParse(vip.basePrice) ?? 0.0;

    if (!mounted) return;

    final result = await PaymentChannelPopup.showWithWalletOption(
      context: context,
      amount: price,
      paymentType: 'vip_purchase',
      walletBalance: balance,
    );

    if (result == null || !mounted) return;

    if (result.useWallet) {
      final i18n = ref.read(i18nNotifierProvider.notifier);
      final success = await ref
          .read(userProvider.notifier)
          .buyVip(int.parse(vip.id));

      if (!mounted) return;

      if (success) {
        ref.read(walletProvider.notifier).refresh();
        ToastUtil.success(i18n.translate('vipPurchasedSuccessfully'));
        _handlePurchaseSuccess();
      } else {
        ToastUtil.error(i18n.translate('failedToPurchaseVip'));
      }
    } else if (result.channel != null) {
      if (!context.mounted) return;
      final rootContext = Navigator.of(context, rootNavigator: true).context;

      final orchestrator = PaymentOrchestrator(ref, rootContext);
      await orchestrator.purchaseVipWithChannel(
        vipId: parseInt(vip.id),
        price: price,
        vipName: vip.translations.name,
        channel: result.channel!,
        contentId: (widget.item.contentId ?? 0).toString(),
        contentType: widget.item.contentType ?? 'posts',
        onPurchased: _handlePurchaseSuccess,
      );
    }
  }

  void _onPreviewEnd() {
    if (!mounted) return;
    setState(() {
      _previewEnded = true;
    });
    ref
        .read(videoPreviewProvider.notifier)
        .recordPreview(widget.item.contentId?.toString() ?? '');
  }

  void _onVideoPlayingChanged() {
    if (!mounted) return;
    final isPlaying = _videoPlayingNotifier.value;
    if (!_hasStarted && isPlaying) {
      _startTimer();
    }
  }

  void _startTimer() {
    if (_hasStarted) return;
    _hasStarted = true;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        _remainingSeconds--;
      });

      if (_remainingSeconds <= 0) {
        _timer?.cancel();
        _onPreviewEnd();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    final appConfig = ref.read(appConfigProvider);
    _remainingSeconds =
        appConfig.data?.paymentFeatureFlags?.previewDurationSeconds ?? 120;
    _videoPlayingNotifier.addListener(_onVideoPlayingChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(vipProvider.notifier).loadVips();
    });
  }

  @override
  void dispose() {
    _videoPlayingNotifier.removeListener(_onVideoPlayingChanged);
    _timer?.cancel();
    _videoPlayingNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isUnlocked) {
      return _VideoPlayerView(
        videoId: widget.item.contentId?.toString() ?? '',
        url: widget.item.url,
        encryptionKey: widget.item.encryptionKey,
      );
    }

    final vipState = ref.watch(vipProvider);
    final userVip = ref.watch(userProvider).user;
    final userVipId = userVip?.vip?.id;
    final appConfig = ref.read(appConfigProvider);
    final showPricing = appConfig.data?.showPricing ?? false;

    final previewState = ref.watch(videoPreviewProvider);
    final videoPreviewEnabled =
        appConfig.data?.paymentFeatureFlags?.videoPreviewEnabled ?? true;

    final showPreview =
        videoPreviewEnabled &&
        previewState.hasQuotaRemaining &&
        !previewState.isLoading &&
        !_previewEnded;

    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;

    final sortedVips = [...vipState.vips]
      ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const Spacer(),
        SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (showPreview) ...[
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(14),
                        ),
                        child: AspectRatio(
                          aspectRatio: 16 / 9,
                          child: Stack(
                            children: [
                              VideoScreen(
                                encryptionKey: widget.item.encryptionKey,
                                videoUrl: widget.item.url,
                                videoId:
                                    widget.item.contentId?.toString() ?? '',
                                playingNotifier: _videoPlayingNotifier,
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.7),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (!_hasStarted)
                                        const SizedBox(
                                          width: 14,
                                          height: 14,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Colors.white,
                                                ),
                                          ),
                                        )
                                      else
                                        const Icon(
                                          Icons.preview,
                                          color: Colors.white,
                                          size: 14,
                                        ),
                                      const SizedBox(width: 6),
                                      Text(
                                        _hasStarted
                                            ? '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}'
                                            : translate("loadingVideo"),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.play_circle_outline,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                translate("freePreviewAvailable"),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Text(
                              '${previewState.remaining} ${translate("previewsLeft")}',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ] else if (_previewEnded) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Stack(
                      children: [
                        Container(
                          color: Colors.black,
                          child:
                              widget.thumbnailUrl != null &&
                                  widget.thumbnailUrl!.isNotEmpty
                              ? EncryptedImage(
                                  url: widget.thumbnailUrl!,
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                )
                              : Container(color: Colors.black),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.lock,
                                  color: Colors.white,
                                  size: 14,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  translate("previewEnded"),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ] else if (videoPreviewEnabled && previewState.isLoading) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white54,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          translate("loadingPreviewInfo"),
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Stack(
                      children: [
                        if (widget.thumbnailUrl != null &&
                            widget.thumbnailUrl!.isNotEmpty)
                          EncryptedImage(
                            url: widget.thumbnailUrl!,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                            errorWidget: Container(color: Colors.black),
                          )
                        else
                          Container(color: Colors.black),
                        Container(
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              center: Alignment.center,
                              radius: 1.2,
                              colors: [
                                Colors.black.withValues(alpha: 0.3),
                                Colors.black.withValues(alpha: 0.7),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.lock,
                                  color: Colors.white,
                                  size: 14,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  translate("premiumContent"),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  const Color(
                                    0xFFD4AF37,
                                  ).withValues(alpha: 0.3),
                                  const Color(
                                    0xFFD4AF37,
                                  ).withValues(alpha: 0.1),
                                ],
                              ),
                              border: Border.all(
                                color: const Color(
                                  0xFFD4AF37,
                                ).withValues(alpha: 0.5),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFFD4AF37,
                                  ).withValues(alpha: 0.3),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.lock_rounded,
                              color: Color(0xFFD4AF37),
                              size: 48,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              if (AppLangVersionUtils.isYd() || AppLangVersionUtils.isTk()) ...[
                const SizedBox(height: 12),
                DepositPromoOverlay(
                  displayMode: DepositPromoDisplayMode.compact,
                  onDepositPressed: () => _navigateToGame(context),
                ),
              ],
              const SizedBox(height: 16),
              if (showPricing) ...[
                Padding(
                  padding: const EdgeInsets.only(
                    left: 10,
                    right: 10,
                    bottom: 10,
                  ),
                  child: Column(
                    children: [
                      buildDirectBuyOptionCard(
                        translate("payDirectly"),
                        widget.item.price ?? 0.0,
                        ref,
                        _handleDirectPayment,
                      ),
                      if (vipState.loading)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(
                              color: Color(0xFFFFD700),
                              strokeWidth: 2,
                            ),
                          ),
                        )
                      else if (sortedVips.isNotEmpty)
                        ...sortedVips.map(
                          (vip) => buildVipCard(
                            vip,
                            userVipId,
                            ref,
                            () => _handleVipSelection(vip),
                          ),
                        ),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 6,
                                ),
                                minimumSize: const Size(0, 36),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () async {
                                final forumService = ref.read(
                                  forumServiceProvider,
                                );
                                final i18n = ref.read(
                                  i18nNotifierProvider.notifier,
                                );
                                if (widget.item.contentId != null) {
                                  final res = await forumService.favorite(
                                    widget.item.contentId!,
                                  );
                                  if (res.code == 1) {
                                    ToastUtil.success(
                                      i18n.translate('videoAddedToFavorites'),
                                    );
                                  } else {
                                    ToastUtil.error(
                                      i18n.translate('failedToAddToFavorites'),
                                    );
                                  }
                                } else {
                                  ToastUtil.error(
                                    i18n.translate('failedToAddToFavorites'),
                                  );
                                }
                              },
                              child: SizedBox(
                                height: 16,
                                child: Text(
                                  translate("collectVideo"),
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 6,
                                ),
                                minimumSize: const Size(0, 36),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () async {
                                final profileIdx = ref.read(
                                  profileTabIndexProvider,
                                );
                                final profileTabSection = ref.read(
                                  profileTabSectionProvider.notifier,
                                );
                                final switchTab = ref.read(
                                  switchTabRequestProvider.notifier,
                                );
                                if (profileIdx >= 0) {
                                  switchTab.state = profileIdx;
                                }
                                Navigator.of(context).pop();
                                Navigator.of(context).pop();
                                await Future.delayed(
                                  const Duration(milliseconds: 300),
                                );
                                profileTabSection.state = 4;
                              },
                              child: SizedBox(
                                height: 16,
                                child: Text(
                                  translate("goToPurchased"),
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor: const Color(0xFFFF4C4C),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 6,
                                ),
                                minimumSize: const Size(0, 36),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () => Navigator.pop(context),
                              child: Text(
                                translate("close"),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
