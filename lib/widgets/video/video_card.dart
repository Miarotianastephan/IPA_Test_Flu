import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/page/short_video_page.dart';
import 'package:live_app/provider/currency_provider.dart';
import 'package:live_app/provider/i18n_provider.dart';
import 'package:live_app/provider/purchased_contents_provider.dart';
import 'package:live_app/widgets/payment/price_bottom_sheet.dart';
import 'package:live_app/widgets/video/video_card_cover_slot.dart';
import 'package:live_app/widgets/vip_badge.dart';

import '../../models/video_info.dart';
import '../../page/long_video_detail_page.dart';
import '../../services/payment_orchestrator.dart';
import '../../utils/responsive_utils.dart';
import '../../utils/text_util.dart';
import '../../utils/utils.dart';
import '../encrypted_image.dart';

class VideoCard extends ConsumerStatefulWidget {
  const VideoCard({
    super.key,
    required this.video,
    this.onUserTap,
    this.preloadCoverUrls = const [],
    this.fixedCoverAspectRatio,
  });

  final VideoInfo video;
  final Function(VideoInfo videoInfo)? onUserTap;
  final List<String> preloadCoverUrls;
  final double? fixedCoverAspectRatio;

  @override
  ConsumerState<VideoCard> createState() => _VideoCardState();
}

class _VideoCardState extends ConsumerState<VideoCard> {
  void _handlePurchaseSuccess(VideoInfo video) {
    if (!mounted) return;
    ref
        .read(purchasedContentProvider.notifier)
        .markAsPurchased('video', video.id);
    _openVideoDetail(video);
  }

  void _openVideoDetail(VideoInfo video) {
    widget.video.type == 2
        ? Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LongVideoDetailPage(video: widget.video),
            ),
          )
        : Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ShortVideoPage(videoId: video.id),
            ),
          );
  }

  String translate(String key) =>
      ref.read(i18nNotifierProvider.notifier).translate(key);

  @override
  void initState() {
    super.initState();
    if (widget.video.isBought) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(purchasedContentProvider.notifier)
            .markAsPurchased('video', widget.video.id);
      });
    }
  }

  @override
  void didUpdateWidget(VideoCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.video.isBought != widget.video.isBought) {
      if (widget.video.isBought) {
        ref
            .read(purchasedContentProvider.notifier)
            .markAsPurchased('video', widget.video.id);
      }
    }
  }

  void _handleUserTap() {
    toUserDetailPage(
      context: context,
      ref: ref,
      userId: widget.video.user.id,
      url: widget.video.user.avatar,
      nickname: widget.video.user.nickname,
      vip: widget.video.user.vip,
    );
  }

  Future<void> _showPricePopup(VideoInfo video) async {
    final action = await PriceBottomSheet.show(
      context: context,
      ref: ref,
      video: video,
      contentId: video.id,
      contentType: 'video',
      onVipPurchased: () => _handlePurchaseSuccess(video),
    );

    if (!mounted) return;

    switch (action) {
      case PriceBottomSheetAction.walletPayment:
        await _handleWalletPayment(video);
        break;
      case PriceBottomSheetAction.directPayment:
        await _handleDirectPayment(video);
        break;
      case PriceBottomSheetAction.dismissed:
        break;
    }
  }

  Future<void> _handleWalletPayment(VideoInfo video) async {
    if (!mounted) return;

    final orchestrator = PaymentOrchestrator(ref, context);
    final success = await orchestrator.purchaseContent(
      contentType: 'video',
      contentId: video.id,
      price: video.price,
      contentTitle: video.title,
    );

    if (success && mounted) {
      _handlePurchaseSuccess(video);
    }
  }

  Future<void> _handleDirectPayment(VideoInfo video) async {
    if (!mounted) return;

    final orchestrator = PaymentOrchestrator(ref, context);
    await orchestrator.purchaseContentDirectly(
      contentType: 'video',
      contentId: video.id,
      price: video.price,
      contentTitle: video.title,
      onPurchased: () => _handlePurchaseSuccess(video),
    );
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveDimensions(context);
    final currencyState = ref.watch(currencyProvider);

    final isPurchased = ref.watch(
      isContentPurchasedProvider(('video', widget.video.id)),
    );

    return GestureDetector(
      onTap: () {
        if (widget.video.price == 0.0 ||
            isPurchased ||
            ref.hasPermission(Permission.accessLongFree)) {
          _openVideoDetail(widget.video);
        } else {
          _showPricePopup(widget.video);
        }
      },
      child: Card(
        color: Colors.black,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,

          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(5),
              ),
              child: Stack(
                children: [
                  RepaintBoundary(
                    child: VideoCardCoverSlot(
                      videoId: widget.video.id.toString(),
                      coverUrl: widget.video.cover,
                      videoType: widget.video.type,
                      preloadCoverUrls: widget.preloadCoverUrls,
                      fixedCoverAspectRatio: widget.fixedCoverAspectRatio,
                      placeholder: const SizedBox.expand(
                        child: ColoredBox(color: Colors.black),
                      ),
                      errorWidget: const Center(
                        child: Icon(Icons.broken_image, color: Colors.grey),
                      ),
                    ),
                  ),
                  if (isPurchased)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black87,
                              blurRadius: 4,
                              spreadRadius: 1,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          translate("bought"),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 30,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Color(0xAF000000)],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 3,
                    left: 3,
                    right: 3,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.play_arrow,
                              size: 20,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '${widget.video.viewCount}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: responsive.videoCardInfoFontSize,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Icon(
                              Icons.comment,
                              size: responsive.videoCardIconSize,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '${widget.video.commentCount}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: responsive.videoCardInfoFontSize,
                              ),
                            ),
                            if (!ref.hasPermission(Permission.accessLongFree) &&
                                !isPurchased &&
                                widget.video.price > 0) ...[
                              const SizedBox(width: 10),
                              Text(
                                currencyState
                                    .convertFromBase(widget.video.price)
                                    .toStringAsFixed(2),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: responsive.videoCardInfoFontSize,
                                ),
                              ),
                            ],
                          ],
                        ),
                        Text(
                          formatDuration(widget.video.duration),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: responsive.videoCardInfoFontSize,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 0,
                vertical: responsive.videoCardVerticalPadding,
              ),
              child: Text(
                widget.video.title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: responsive.videoCardTitleFontSize,
                  color: Colors.white,
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                left: 0,
                right: 0,
                top: responsive.videoCardVerticalPadding,
                bottom: responsive.videoCardVerticalPadding,
              ),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _handleUserTap,
                child: Row(
                  children: [
                    RepaintBoundary(
                      child: UserAvatar(
                        userId: widget.video.userId,
                        url: widget.video.user.avatar,
                        nickname: widget.video.user.nickname,
                        vip: widget.video.user.vip,
                        size: responsive.videoCardAvatarSize,
                        onTap: _handleUserTap,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              widget.video.user.nickname ?? "",
                              style: TextStyle(
                                fontSize: responsive.videoCardNicknameFontSize,
                                color: Colors.white,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          VipBadge(vip: widget.video.user.vip),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
