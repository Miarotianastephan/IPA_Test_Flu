import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/vip.dart';
import '../../provider/currency_provider.dart';
import '../../provider/i18n_provider.dart';
import '../../provider/my_user_provider.dart';
import '../../provider/wallet_provider.dart';
import '../../services/payment_orchestrator.dart';
import '../../utils/json_utils.dart';
import '../../utils/toast_util.dart';
import '../encrypted_image.dart';
import 'payment_channel_popup.dart';

enum VipPaymentChoice { walletPayment, directPayment, rechargeWallet }

class VipPurchaseResult {
  final bool success;
  final VipPaymentChoice? choice;

  const VipPurchaseResult({this.success = false, this.choice});

  static const dismissed = VipPurchaseResult();
  static const walletSuccess = VipPurchaseResult(
    success: true,
    choice: VipPaymentChoice.walletPayment,
  );
  static VipPurchaseResult chooseDirectPayment() =>
      const VipPurchaseResult(choice: VipPaymentChoice.directPayment);
  static VipPurchaseResult chooseRecharge() =>
      const VipPurchaseResult(choice: VipPaymentChoice.rechargeWallet);
}

class VipPurchaseDialog extends ConsumerStatefulWidget {
  final Vip vip;
  final VoidCallback? onSuccess;
  final VoidCallback? onDismiss;

  const VipPurchaseDialog({
    super.key,
    required this.vip,
    this.onSuccess,
    this.onDismiss,
  });

  static Future<bool> show({
    required BuildContext context,
    required Vip vip,
    required WidgetRef ref,
    VoidCallback? onSuccess,
    VoidCallback? onDismiss,
  }) async {
    if (!context.mounted) return false;

    final walletState = ref.read(walletProvider);
    final balance = walletState.balance?.balance ?? 0.0;
    final price = parseDouble(vip.basePrice);

    final result = await PaymentChannelPopup.showWithWalletOption(
      context: context,
      amount: price,
      paymentType: 'vip_purchase',
      walletBalance: balance,
    );

    if (result == null) {
      onDismiss?.call();
      return false;
    }

    if (!context.mounted) return false;

    if (result.useWallet) {
      final i18n = ref.read(i18nNotifierProvider.notifier);
      final success = await ref
          .read(userProvider.notifier)
          .buyVip(int.parse(vip.id));

      if (!context.mounted) return false;

      if (success) {
        ref.read(walletProvider.notifier).refresh();
        ToastUtil.success(i18n.translate('vipPurchasedSuccessfully'));
        onSuccess?.call();
        return true;
      }

      ToastUtil.error(i18n.translate('failedToPurchaseVip'));
      return false;
    }

    if (result.channel == null) return false;

    final orchestrator = PaymentOrchestrator(ref, context);
    return orchestrator.purchaseVipWithChannel(
      vipId: parseInt(vip.id),
      price: price,
      vipName: vip.translations.name,
      channel: result.channel!,
      onPurchased: onSuccess,
    );
  }

  @override
  ConsumerState<VipPurchaseDialog> createState() => _VipPurchaseDialogState();
}

class _VipPurchaseDialogState extends ConsumerState<VipPurchaseDialog> {
  bool _isLoadingRecharge = false;

  @override
  Widget build(BuildContext context) {
    final i18n = ref.read(i18nNotifierProvider.notifier);
    final currencyState = ref.watch(currencyProvider);
    final walletState = ref.watch(walletProvider);

    final balance = walletState.balance?.balance ?? 0.0;
    final price = parseDouble(widget.vip.basePrice);
    final localBalance = currencyState.convertFromBase(balance);
    final localPrice = currencyState.convertFromBase(price);
    final hasEnoughBalance = balance >= price;
    final shortfall = localPrice - localBalance;

    final translation = widget.vip.translations;

    return Dialog(
      backgroundColor: const Color(0xFF121212),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (widget.vip.logoUrl.isNotEmpty)
                  EncryptedImage(
                    url: widget.vip.logoUrl,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              translation.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (widget.vip.isRecommended) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFFFD700),
                                    Color(0xFFFFA000),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                i18n.translate('recommended'),
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "${widget.vip.validDays} ${i18n.translate('days')}",
                        style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Text(
              hasEnoughBalance
                  ? i18n.translate('choosePaymentMethod')
                  : i18n.translate('insufficientBalance'),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 16),

            _buildInfoRow(
              label: i18n.translate('yourBalance'),
              value: '${localBalance.toStringAsFixed(2)}',
              valueColor: hasEnoughBalance
                  ? Colors.greenAccent
                  : Colors.redAccent,
              showIndicator: true,
              indicatorColor: hasEnoughBalance
                  ? Colors.greenAccent
                  : Colors.redAccent,
            ),

            const SizedBox(height: 12),

            _buildInfoRow(
              label: i18n.translate('price'),
              value: '${localPrice.toStringAsFixed(2)}',
              valueColor: Colors.white,
            ),

            if (!hasEnoughBalance) ...[
              const SizedBox(height: 12),
              _buildInfoRow(
                label: i18n.translate('shortfall'),
                value: '${shortfall.toStringAsFixed(2)}',
                valueColor: Colors.redAccent,
                labelColor: Colors.redAccent,
              ),
            ],

            const SizedBox(height: 20),

            Row(
              children: [
                const Expanded(
                  child: Divider(color: Colors.white24, thickness: 1),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    i18n.translate('choosePaymentMethod'),
                    style: const TextStyle(color: Colors.white54, fontSize: 13),
                  ),
                ),
                const Expanded(
                  child: Divider(color: Colors.white24, thickness: 1),
                ),
              ],
            ),

            const SizedBox(height: 20),

            if (hasEnoughBalance) ...[
              _buildWalletButton(context, i18n, price),
              const SizedBox(height: 12),
            ],

            _buildDirectPaymentButton(context, i18n, hasEnoughBalance),

            const SizedBox(height: 12),

            if (!hasEnoughBalance) _buildRechargeButton(context, i18n),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required String label,
    required String value,
    required Color valueColor,
    Color labelColor = Colors.white54,
    bool showIndicator = false,
    Color? indicatorColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: labelColor, fontSize: 14)),
          Flexible(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              reverse: true,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (showIndicator) ...[
                    Icon(Icons.circle, size: 8, color: indicatorColor),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    value,
                    style: TextStyle(
                      color: valueColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletButton(
    BuildContext context,
    dynamic i18n,
    double basePrice,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: () => _handleWalletPayment(context, i18n),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.account_balance_wallet,
              color: Colors.black,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              i18n.translate('useWallet'),
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDirectPaymentButton(
    BuildContext context,
    dynamic i18n,
    bool hasEnoughBalance,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          side: const BorderSide(color: Colors.white, width: 1),
          backgroundColor: hasEnoughBalance
              ? const Color(0xFF1E1E1E)
              : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: () => _handleDirectPayment(context),
        child: Text(
          i18n.translate('payDirectly'),
          style: TextStyle(
            color: hasEnoughBalance ? Colors.white : Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildRechargeButton(BuildContext context, dynamic i18n) {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          elevation: 0,
          side: const BorderSide(color: Colors.white, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: _isLoadingRecharge
            ? null
            : () {
                setState(() {
                  _isLoadingRecharge = true;
                });
                _handleRechargeWallet(context);
              },
        child: _isLoadingRecharge
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                i18n.translate('rechargeWallet'),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Future<void> _handleWalletPayment(BuildContext context, dynamic i18n) async {
    final translation = widget.vip.translations;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(i18n.translate('confirmation')),
          content: Text(
            '${i18n.translate('confirmPurchaseVip')} "${translation.name}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(
                i18n.translate('cancel'),
                style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(
                i18n.translate('confirm'),
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) return;

    final success = await ref
        .read(userProvider.notifier)
        .buyVip(int.parse(widget.vip.id));

    if (!context.mounted) return;

    if (success) {
      ref.read(walletProvider.notifier).refresh();
      ToastUtil.success(i18n.translate('vipPurchasedSuccessfully'));
      Navigator.of(context).pop(VipPurchaseResult.walletSuccess);
      widget.onSuccess?.call();
    } else {
      ToastUtil.error(i18n.translate('failedToPurchaseVip'));
    }
  }

  void _handleDirectPayment(BuildContext dialogContext) {
    Navigator.of(dialogContext).pop(VipPurchaseResult.chooseDirectPayment());
  }

  void _handleRechargeWallet(BuildContext dialogContext) {
    Navigator.of(dialogContext).pop(VipPurchaseResult.chooseRecharge());
  }
}
