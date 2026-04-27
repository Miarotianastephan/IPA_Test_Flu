import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/provider/currency_provider.dart';
import 'package:live_app/provider/i18n_provider.dart';

import '../../models/recharge_amount.dart';
import '../../provider/wallet_provider.dart';
import 'recharge_amount_grid.dart';

class RechargeAmountPopup extends ConsumerStatefulWidget {
  final String currency;
  final Function(RechargeAmount)? onAmountSelected;
  final VoidCallback? onCancel;

  const RechargeAmountPopup({
    super.key,
    required this.currency,
    this.onAmountSelected,
    this.onCancel,
  });

  @override
  ConsumerState<RechargeAmountPopup> createState() =>
      _RechargeAmountPopupState();

  static Future<RechargeAmount?> show({
    required BuildContext context,
    String? currency,
  }) {
    if (!context.mounted) return Future.value(null);

    return showModalBottomSheet<RechargeAmount>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: false,
      backgroundColor: Colors.transparent,
      builder: (context) => RechargeAmountPopup(
        currency: currency ?? 'CNY',
        onAmountSelected: (amount) {
          Navigator.of(context).pop(amount);
        },
        onCancel: () => Navigator.of(context).pop(),
      ),
    );
  }
}

class _RechargeAmountPopupState extends ConsumerState<RechargeAmountPopup> {
  int? _selectedAmountId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final walletState = ref.watch(walletProvider);
    final i18n = ref.read(i18nNotifierProvider.notifier);

    final currencyState = ref.watch(currencyProvider);

    final localBalance = currencyState.convertFromBase(
      walletState.balance?.balance ?? 0.0,
    );

    final amounts = walletState.rechargeAmounts;

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            i18n.translate("rechargeWallet"),
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.account_balance_wallet,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                      child: Text(
                        i18n.translate("currentBalance"),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                    Text(
                      localBalance.toStringAsFixed(2),
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          if (walletState.isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(),
              ),
            )
          else if (amounts.isEmpty)
            Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    i18n.translate('noRechargeAmountsAvailable'),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            )
          else ...[
            Text(
              i18n.translate('selectAmount:'),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 12),

            RechargeAmountGrid(
              amounts: amounts,
              selectedAmountId: _selectedAmountId,
              onSelected: (amount) {
                setState(() {
                  _selectedAmountId = amount.id;
                });
              },
            ),
          ],

          if (_selectedAmountId != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.card_giftcard,
                    color: Colors.green,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Builder(
                      builder: (context) {
                        final selectedAmount = amounts.firstWhere(
                          (a) => a.id == _selectedAmountId,
                        );
                        if (selectedAmount.bonusAmount > 0) {
                          return Text(
                            '${i18n.translate('youWillReceive')}  ${currencyState.convertFromBase(selectedAmount.totalAmount).toStringAsFixed(2)} (${i18n.translate('includes')}  ${currencyState.convertFromBase(selectedAmount.bonusAmount).toStringAsFixed(2)} ${i18n.translate('bonus')}!)',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          );
                        }
                        return Text(
                          '${i18n.translate('youWillReceive')}  ${currencyState.convertFromBase(selectedAmount.amount).toStringAsFixed(2)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.green.shade700,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],

          if (_selectedAmountId != null) ...[
            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed:
                        widget.onCancel ?? () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: theme.colorScheme.error,
                      foregroundColor: Colors.grey.shade800,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      i18n.translate('cancel'),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final selectedAmount = amounts.firstWhere(
                        (a) => a.id == _selectedAmountId,
                      );
                      widget.onAmountSelected?.call(selectedAmount);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 2,
                    ),
                    child: Text(
                      i18n.translate('continue'),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],

          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}
