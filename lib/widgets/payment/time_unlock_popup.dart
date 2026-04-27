import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/time_package.dart';
import '../../models/video_info.dart';
import '../../models/vip.dart';
import '../../provider/api_provider.dart';
import '../../provider/i18n_provider.dart';
import '../../provider/my_user_provider.dart';
import '../../provider/purchased_contents_provider.dart';
import '../../provider/vip_provider.dart';
import '../../provider/wallet_provider.dart';
import '../../services/payment_orchestrator.dart';
import '../../utils/json_utils.dart';
import '../../utils/toast_util.dart';
import 'OptionCard.dart';
import 'payment_channel_popup.dart';

class TimeUnlockPopup {
  final VoidCallback? onSuccess;
  final VoidCallback? onCancel;
  final VideoInfo videoInfo;

  const TimeUnlockPopup({
    this.onSuccess,
    this.onCancel,
    required this.videoInfo,
  });

  static Future<bool> show({
    required BuildContext context,
    required VideoInfo videoInfo,
  }) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      isDismissible: true,
      enableDrag: true,
      builder: (context) => _TimeUnlockBottomSheet(
        onSuccess: () => Navigator.of(context).pop(true),
        onCancel: () => Navigator.of(context).pop(false),
        videoInfo: videoInfo,
      ),
    );
    return result ?? false;
  }
}

class _TimeUnlockBottomSheet extends ConsumerStatefulWidget {
  final VoidCallback? onSuccess;
  final VoidCallback? onCancel;
  final VideoInfo videoInfo;

  const _TimeUnlockBottomSheet({
    this.onSuccess,
    this.onCancel,
    required this.videoInfo,
  });

  @override
  ConsumerState<_TimeUnlockBottomSheet> createState() =>
      _TimeUnlockBottomSheetState();
}

class _TimeUnlockBottomSheetState
    extends ConsumerState<_TimeUnlockBottomSheet> {
  int? _selectedPackageId;
  List<TimePackage> _packages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTimePackages();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(vipProvider.notifier).loadVips();
    });
  }

  Future<void> _loadTimePackages() async {
    try {
      final userService = ref.read(userServiceProvider);
      final response = await userService.getTimePackages(page: 1, limit: 100);

      if (response.data != null) {
        setState(() {
          _packages = response.data!.list;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Column(
                    children: [
                      Text(
                        ref
                            .read(i18nNotifierProvider.notifier)
                            .translate('freeTimeUp'),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),

                  // const SizedBox(height: 20),
                  // _buildContent(),
                  const SizedBox(height: 20),
                  _buildVipSection(),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 35,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: const Color(0xFFFF4C4C),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed:
                                widget.onCancel ??
                                () => Navigator.of(context).pop(),
                            child: Text(
                              ref
                                  .read(i18nNotifierProvider.notifier)
                                  .translate('maybeLater'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handlePurchaseSuccess() {
    if (!mounted) return;
    ref
        .read(purchasedContentProvider.notifier)
        .markAsPurchased('video', widget.videoInfo.id);
    widget.onSuccess?.call();
  }

  Widget _buildVipSection() {
    final vipState = ref.watch(vipProvider);
    final userVip = ref.watch(userProvider).user;
    final userVipId = userVip?.vip?.id;

    final sortedVips = [...vipState.vips]
      ..sort((a, b) {
        if (a.isRecommended && !b.isRecommended) return -1;
        if (!a.isRecommended && b.isRecommended) return 1;
        return parseDouble(a.basePrice).compareTo(parseDouble(b.basePrice));
      });

    if (sortedVips.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        // OrUpdateVipDivider(),
        const SizedBox(height: 12),
        buildSingleBuyCard(widget.videoInfo, ref, handleDirectPayment),

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
    );
  }

  Future<void> handleDirectPayment() async {
    if (!mounted) return;
    final video = widget.videoInfo;
    final orchestrator = PaymentOrchestrator(ref, context);
    await orchestrator.purchaseContentDirectly(
      contentType: 'video',
      contentId: video.id,
      price: video.price,
      contentTitle: video.title,
      onPurchased: _handlePurchaseSuccess,
    );
  }

  Future<void> _handleVipSelection(Vip vip) async {
    final walletState = ref.read(walletProvider);
    final balance = walletState.balance?.balance ?? 0.0;
    final price = parseDouble(vip.basePrice);

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
      final orchestrator = PaymentOrchestrator(ref, context);
      await orchestrator.purchaseVipWithChannel(
        vipId: parseInt(vip.id),
        price: price,
        vipName: vip.translations.name,
        channel: result.channel!,
        contentId: widget.videoInfo.id,
        contentType: 'video',
        onPurchased: _handlePurchaseSuccess,
      );
    }
  }
}

// Widget _buildContent() {
//   final walletState = ref.watch(walletProvider);
//   final balance = walletState.balance?.balance ?? 0.0;
//   if (_isLoading) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: const Color(0xFF1E1E1E),
//         borderRadius: BorderRadius.circular(14),
//       ),
//       child: Row(
//         children: [
//           const SizedBox(
//             width: 20,
//             height: 20,
//             child: CircularProgressIndicator(
//               strokeWidth: 2,
//               valueColor: AlwaysStoppedAnimation<Color>(Colors.white54),
//             ),
//           ),
//           const SizedBox(width: 12),
//           Flexible(
//             child: Text(
//               translate('loading'),
//               style: const TextStyle(color: Colors.white54, fontSize: 14),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   if (_packages.isEmpty) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: const Color(0xFF1E1E1E),
//         borderRadius: BorderRadius.circular(14),
//       ),
//       child: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: Colors.white.withValues(alpha: 0.1),
//               shape: BoxShape.circle,
//             ),
//             child: const Icon(
//               Icons.access_time_outlined,
//               size: 20,
//               color: Colors.white38,
//             ),
//           ),
//           const SizedBox(width: 12),
//           Flexible(
//             child: Text(
//               translate('noTimePackages'),
//               style: const TextStyle(color: Colors.white60, fontSize: 14),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   return Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       Text(
//         translate('unlockMoreViewingTime'),
//         style: const TextStyle(
//           color: Colors.white,
//           fontSize: 16,
//           fontWeight: FontWeight.w600,
//         ),
//       ),
//       const SizedBox(height: 12),
//
//       ConstrainedBox(
//         constraints: BoxConstraints(
//           maxHeight: MediaQuery.of(context).size.height * 0.25,
//         ),
//         child: SingleChildScrollView(
//           child: TimePackageList(
//             packages: _packages,
//             selectedPackageId: _selectedPackageId,
//             onSelected: (package) {
//               setState(() {
//                 _selectedPackageId = package.id;
//               });
//               _handleTimePackagePurchase(balance);
//             },
//             currency: 'CNY',
//           ),
//         ),
//       ),
//     ],
//   );
// }

//   Future<void> _handleTimePackagePurchase(double balance) async {
//     final selected = _packages.firstWhere((p) => p.id == _selectedPackageId);
//
//     if (!mounted) return;
//
//     final result = await PaymentChannelPopup.showWithWalletOption(
//       context: context,
//       amount: selected.price,
//       paymentType: 'time_package',
//       walletBalance: balance,
//     );
//
//     if (result == null || !mounted) return;
//
//     final orchestrator = PaymentOrchestrator(ref, context);
//
//     if (result.useWallet) {
//       final success = await orchestrator.purchaseTimePackage(selected);
//
//       if (!mounted) return;
//
//       if (success) {
//         ref.read(walletProvider.notifier).refresh();
//         widget.onSuccess?.call();
//       }
//     } else if (result.channel != null) {
//       Navigator.of(context).pop();
//       if (!mounted) return;
//
//       await orchestrator.purchaseTimePackageWithChannel(
//         selected,
//         result.channel!,
//       );
//     }
//   }
