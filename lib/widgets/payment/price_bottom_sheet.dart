import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/provider/api_provider.dart';
import 'package:live_app/utils/json_utils.dart';

import '../../models/video_info.dart';
import '../../models/vip.dart';
import '../../provider/app_config_provider.dart';
import '../../provider/current_tab_provider.dart';
import '../../provider/i18n_provider.dart';
import '../../provider/my_user_provider.dart';
import '../../provider/video_preview_provider.dart';
import '../../provider/vip_provider.dart';
import '../../provider/wallet_provider.dart';
import '../../services/payment_orchestrator.dart';
import '../../utils/app_lang_version_utils.dart';
import '../../utils/toast_util.dart';
import '../encrypted_image.dart';
import '../video/deposit_promo_overlay.dart';
import 'OptionCard.dart';
import 'payment_channel_popup.dart';
import 'video_preview_card.dart';

enum PriceBottomSheetAction { directPayment, walletPayment, dismissed }

class PriceBottomSheet extends ConsumerStatefulWidget {
  final VideoInfo video;
  final String contentId;
  final String contentType;
  final VoidCallback? onVipPurchased;

  const PriceBottomSheet({
    super.key,
    required this.video,
    required this.contentId,
    required this.contentType,
    this.onVipPurchased,
  });

  static Future<PriceBottomSheetAction> show({
    required BuildContext context,
    required WidgetRef ref,
    required VideoInfo video,
    required String contentId,
    required String contentType,
    VoidCallback? onVipPurchased,
  }) async {
    ref.read(vipProvider.notifier).loadVips();

    final result = await showModalBottomSheet<PriceBottomSheetAction>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (_) => PriceBottomSheet(
        video: video,
        contentId: contentId,
        contentType: contentType,
        onVipPurchased: onVipPurchased,
      ),
    );

    return result ?? PriceBottomSheetAction.dismissed;
  }

  @override
  ConsumerState<PriceBottomSheet> createState() => _PriceBottomSheetState();
}

class _PriceBottomSheetState extends ConsumerState<PriceBottomSheet> {
  bool _previewEnded = false;

  String translate(String key) =>
      ref.read(i18nNotifierProvider.notifier).translate(key);

  void _onPreviewEnd() {
    if (!mounted) return;
    setState(() {
      _previewEnded = true;
    });
    ref.read(videoPreviewProvider.notifier).recordPreview(widget.video.id);
  }

  @override
  Widget build(BuildContext context) {
    final vipState = ref.watch(vipProvider);
    final userVip = ref.watch(userProvider).user;
    final userVipId = userVip?.vip?.id;

    final previewState = ref.watch(videoPreviewProvider);
    final appConfig = ref.read(appConfigProvider);
    final videoPreviewEnabled =
        appConfig.data?.paymentFeatureFlags?.videoPreviewEnabled ?? true;
    final previewDuration =
        appConfig.data?.paymentFeatureFlags?.previewDurationSeconds ?? 120;

    final showPreview =
        videoPreviewEnabled &&
        previewState.hasQuotaRemaining &&
        !previewState.isLoading &&
        !_previewEnded;

    final sortedVips = [...vipState.vips]
      ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

    final showPricing = appConfig.data?.showPricing ?? false;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF121212),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showPreview) ...[
                  VideoPreviewCard(
                    price: widget.video.price,
                    video: widget.video,
                    previewDuration: previewDuration,
                    previewsRemaining: previewState.remaining,
                    onPreviewEnd: _onPreviewEnd,
                    translate: translate,
                  ),
                  const SizedBox(height: 16),
                ] else if (_previewEnded) ...[
                  _PreviewEndedCover(
                    video: widget.video,
                    previewsRemaining: previewState.remaining,
                    translate: translate,
                  ),
                  const SizedBox(height: 16),
                ] else if (videoPreviewEnabled && previewState.isLoading) ...[
                  _PreviewLoadingPlaceholder(translate: translate),
                  const SizedBox(height: 16),
                ],

                Padding(
                  padding: const EdgeInsets.only(
                    left: 10,
                    right: 10,
                    bottom: 10,
                  ),
                  child: Column(
                    children: [
                      if (showPricing) ...[
                        buildSingleBuyCard(
                          widget.video,
                          ref,
                          () => Navigator.of(
                            context,
                          ).pop(PriceBottomSheetAction.directPayment),
                        ),
                        if (sortedVips.isNotEmpty) ...[
                          if (vipState.loading)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: CircularProgressIndicator(
                                  color: Color.fromARGB(255, 255, 255, 255),
                                  strokeWidth: 2,
                                ),
                              ),
                            )
                          else
                            ...sortedVips.map(
                              (vip) => buildVipCard(
                                vip,
                                userVipId,
                                ref,
                                () => _handleVipSelection(vip),
                              ),
                            ),
                        ],
                        Row(
                          children: [
                            Expanded(
                              flex: 4,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  backgroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 6,
                                  ),
                                  minimumSize: const Size(0, 43),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () async {
                                  final videoService = ref.read(
                                    videoServiceProvider,
                                  );
                                  final i18n = ref.read(
                                    i18nNotifierProvider.notifier,
                                  );
                                  final res = await videoService.favoriteVideo(
                                    widget.video.id,
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
                                  Navigator.of(context).pop();
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
                              flex: 4,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  backgroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 6,
                                  ),
                                  minimumSize: const Size(0, 43),
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
                                  Navigator.of(context).pop();
                                  if (profileIdx >= 0) {
                                    switchTab.state = profileIdx;
                                  }
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
                              flex: 2,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  backgroundColor: const Color(0xFFFF4C4C),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 6,
                                  ),
                                  minimumSize: const Size(0, 43),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () => Navigator.of(
                                  context,
                                ).pop(PriceBottomSheetAction.dismissed),
                                child: Text(
                                  translate("close"),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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
        if (mounted) {
          Navigator.of(context).pop();
        }
        widget.onVipPurchased?.call();
      } else {
        ToastUtil.error(i18n.translate('failedToPurchaseVip'));
      }
    } else if (result.channel != null) {
      final rootContext = Navigator.of(context, rootNavigator: true).context;
      Navigator.of(context).pop();

      final orchestrator = PaymentOrchestrator(ref, rootContext);
      await orchestrator.purchaseVipWithChannel(
        vipId: parseInt(vip.id),
        price: price,
        vipName: vip.translations.name,
        channel: result.channel!,
        contentId: widget.contentId,
        contentType: widget.contentType,
        onPurchased: widget.onVipPurchased,
      );
    }
  }
}

class _PreviewEndedCover extends ConsumerWidget {
  final VideoInfo video;
  final int previewsRemaining;
  final String Function(String) translate;

  const _PreviewEndedCover({
    required this.video,
    required this.previewsRemaining,
    required this.translate,
  });

  void _navigateToGame(BuildContext context, WidgetRef ref) {
    Navigator.of(context).pop();
    final gameTabIndex = ref.read(gameTabIndexProvider);
    ref.read(switchTabRequestProvider.notifier).state = gameTabIndex;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              children: [
                Container(
                  color: Colors.black,
                  child: EncryptedImage(
                    url: video.cover,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
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
                        const Icon(Icons.lock, color: Colors.white, size: 14),
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
        if (AppLangVersionUtils.isYd() || AppLangVersionUtils.isTk()) ...[
          const SizedBox(height: 12),
          DepositPromoOverlay(
            displayMode: DepositPromoDisplayMode.compact,
            onDepositPressed: () => _navigateToGame(context, ref),
          ),
        ],
      ],
    );
  }
}

class _PreviewLoadingPlaceholder extends StatelessWidget {
  final String Function(String) translate;

  const _PreviewLoadingPlaceholder({required this.translate});

  @override
  Widget build(BuildContext context) {
    return Container(
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
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white54),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              translate("loadingPreviewInfo"),
              style: const TextStyle(color: Colors.white54, fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
