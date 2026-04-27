import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../provider/currency_provider.dart';
import '../../provider/i18n_provider.dart';

enum PaymentMethodChoice { walletPayment, directPayment, rechargeWallet }

/// Dialog shown for payment method selection
/// Gives user choice to use wallet (if sufficient), pay directly, or recharge wallet
class PaymentMethodChoiceDialog extends ConsumerStatefulWidget {
  final double contentPrice;
  final double currentBalance;
  final String contentTitle;

  const PaymentMethodChoiceDialog({
    super.key,
    required this.contentPrice,
    required this.currentBalance,
    required this.contentTitle,
  });

  static Future<PaymentMethodChoice?> show({
    required BuildContext context,
    required double contentPrice,
    required double currentBalance,
    required String contentTitle,
  }) async {
    return showDialog<PaymentMethodChoice>(
      context: context,
      barrierDismissible: true,
      builder: (context) => PaymentMethodChoiceDialog(
        contentPrice: contentPrice,
        currentBalance: currentBalance,
        contentTitle: contentTitle,
      ),
    );
  }

  @override
  ConsumerState<PaymentMethodChoiceDialog> createState() =>
      _PaymentMethodChoiceDialogState();
}

class _PaymentMethodChoiceDialogState
    extends ConsumerState<PaymentMethodChoiceDialog> {
  bool _isLoadingRecharge = false;

  @override
  Widget build(BuildContext context) {
    final i18n = ref.read(i18nNotifierProvider.notifier);
    final currencyState = ref.watch(currencyProvider);

    final localBalance = currencyState.convertFromBase(widget.currentBalance);

    final localPrice = currencyState.convertFromBase(widget.contentPrice);

    final shortfall = localPrice - localBalance;
    final hasEnoughBalance = widget.currentBalance >= widget.contentPrice;

    return Dialog(
      backgroundColor: const Color(0xFF121212),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
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

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    i18n.translate('yourBalance'),
                    style: const TextStyle(color: Colors.white54, fontSize: 14),
                  ),
                  Flexible(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.circle,
                            size: 8,
                            color: hasEnoughBalance
                                ? Colors.greenAccent
                                : Colors.redAccent,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            localBalance.toStringAsFixed(2),
                            style: TextStyle(
                              color: hasEnoughBalance
                                  ? Colors.greenAccent
                                  : Colors.redAccent,
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
            ),

            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    i18n.translate('price'),
                    style: const TextStyle(color: Colors.white54, fontSize: 14),
                  ),
                  Flexible(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Text(
                        localPrice.toStringAsFixed(2),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            if (!hasEnoughBalance)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      i18n.translate('shortfall'),
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Flexible(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Text(
                          shortfall.toStringAsFixed(2),
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            if (!hasEnoughBalance) const SizedBox(height: 12),

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
              SizedBox(
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
                  onPressed: () {
                    Navigator.of(
                      context,
                    ).pop(PaymentMethodChoice.walletPayment);
                  },
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
              ),
              const SizedBox(height: 12),
            ],

            SizedBox(
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
                onPressed: () {
                  Navigator.of(context).pop(PaymentMethodChoice.directPayment);
                },
                child: Text(
                  i18n.translate('payDirectly'),
                  style: TextStyle(
                    color: hasEnoughBalance ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            if (!hasEnoughBalance)
              SizedBox(
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
                          Navigator.of(
                            context,
                          ).pop(PaymentMethodChoice.rechargeWallet);
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
              ),
          ],
        ),
      ),
    );
  }
}
