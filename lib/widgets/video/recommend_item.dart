import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:live_app/provider/currency_provider.dart';
import 'package:live_app/provider/i18n_provider.dart';
import 'package:live_app/provider/purchased_contents_provider.dart';
import 'package:live_app/services/payment_orchestrator.dart';
import 'package:live_app/utils/utils.dart';
import 'package:live_app/widgets/payment/price_bottom_sheet.dart';

import '../../models/video_info.dart';
import '../../utils/text_util.dart';
import '../encrypted_image.dart';
import '../vip_badge.dart';

class RecommendedVideoItem extends ConsumerStatefulWidget {
  final VideoInfo video;
  final void Function(VideoInfo)? onTap;

  const RecommendedVideoItem({super.key, required this.video, this.onTap});

  @override
  ConsumerState<RecommendedVideoItem> createState() =>
      _RecommendedVideoItemState();
}

class _RecommendedVideoItemState extends ConsumerState<RecommendedVideoItem> {
  VideoInfo get video => widget.video;
  void Function(VideoInfo)? get onTap => widget.onTap;

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
  void didUpdateWidget(covariant RecommendedVideoItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.video.isBought && widget.video.isBought) {
      ref
          .read(purchasedContentProvider.notifier)
          .markAsPurchased('video', widget.video.id);
    }
  }

  void _handlePurchaseSuccess(VideoInfo video) {
    if (!mounted) return;
    ref
        .read(purchasedContentProvider.notifier)
        .markAsPurchased('video', video.id);
    onTap?.call(video);
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
    final currencyState = ref.watch(currencyProvider);
    final translate = ref.read(i18nNotifierProvider.notifier).translate;
    final isPurchased = ref.watch(
      isContentPurchasedProvider(('video', video.id)),
    );
    final hasPurchased = video.isBought || isPurchased;

    final publishDate = DateFormat(
      'yyyy-MM-dd',
    ).format(video.createdAt); // 格式化发布日期

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (video.price == 0.0 ||
            hasPurchased ||
            ref.hasPermission(Permission.accessLongFree)) {
          onTap?.call(video);
        } else {
          _showPricePopup(video);
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                children: [
                  // 封面
                  Container(
                    width: 140,
                    height: 90,
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: EncryptedImage(
                      url: video.cover,
                      width: video.type == 2 ? 140 : null,
                      height: video.type == 2 ? 90 : null,
                      fit: video.type == 2 ? BoxFit.cover : BoxFit.contain,
                    ),
                  ),

                  if (hasPurchased)
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

                  /// 底部阴影层
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
                    bottom: 4,
                    left: 6,
                    right: 6,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (!ref.hasPermission(Permission.accessLongFree) &&
                            !hasPurchased &&
                            widget.video.price > 0) ...[
                          Text(
                            currencyState
                                .convertFromBase(widget.video.price)
                                .toStringAsFixed(2),
                            style: TextStyle(color: Colors.white, fontSize: 11),
                          ),
                        ],
                        Text(
                          formatDuration(video.duration),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),
            // 标题、头像和信息
            Expanded(
              child: SizedBox(
                height: 90,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 标题
                    Text(
                      video.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis, // 超出显示省略号
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    // 用户信息和发布日期
                    Row(
                      children: [
                        const Icon(
                          Icons.play_arrow,
                          size: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${video.viewCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Icon(
                          Icons.comment,
                          size: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${video.commentCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),
                    Row(
                      children: [
                        UserAvatar(
                          userId: video.userId,
                          url: video.user.avatar ?? "https://i.pravatar.cc/350",
                          nickname: video.user.nickname,
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Row(
                            children: [
                              Flexible(
                                child: Text(
                                  video.user.nickname ?? "",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              VipBadge(vip: video.user.vip, size: 14),
                            ],
                          ),
                        ),
                        // 发布时间
                        Text(
                          publishDate,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
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

class RecommendedVideoSkeleton extends StatelessWidget {
  const RecommendedVideoSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // 封面骨架
          Container(
            width: 140,
            height: 90,
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(width: 12),
          // 右侧文本骨架
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 14,
                  width: double.infinity,
                  color: Colors.grey[800],
                ),
                const SizedBox(height: 6),
                Container(height: 12, width: 100, color: Colors.grey[800]),
                const SizedBox(height: 6),
                Container(height: 12, width: 60, color: Colors.grey[800]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
