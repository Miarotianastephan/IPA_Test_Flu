import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../provider/currency_provider.dart';

/// Reusable price display component with automatic currency conversion
class PriceDisplay extends ConsumerWidget {
  final double standardPrice;
  final double? vipPrice;
  final String currency;
  final bool showVipUpsell;
  final TextStyle? standardPriceStyle;
  final TextStyle? vipPriceStyle;
  final bool convertFromBase;

  const PriceDisplay({
    super.key,
    required this.standardPrice,
    this.vipPrice,
    this.currency = 'USD',
    this.showVipUpsell = true,
    this.standardPriceStyle,
    this.vipPriceStyle,
    this.convertFromBase = true,
  });

  String _formatPrice(double price) {
    final formatter = NumberFormat.currency(symbol: '', decimalDigits: 2);
    return formatter.format(price);
  }

  int _calculateSavings(double standardPrice, double? vipPrice) {
    if (vipPrice == null || vipPrice >= standardPrice) return 0;
    return (((standardPrice - vipPrice) / standardPrice) * 100).round();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currencyState = ref.watch(currencyProvider);

    // Convert prices from base currency (CNY) to local currency if needed
    final displayStandardPrice = convertFromBase
        ? currencyState.convertFromBase(standardPrice)
        : standardPrice;
    final displayVipPrice = vipPrice != null && convertFromBase
        ? currencyState.convertFromBase(vipPrice!)
        : vipPrice;

    final hasVipDiscount =
        displayVipPrice != null && displayVipPrice < displayStandardPrice;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Standard price
        Row(
          children: [
            const Icon(Icons.attach_money, size: 20, color: Colors.grey),
            const SizedBox(width: 4),
            Text(
              'Standard Price: ',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[700],
              ),
            ),
            Text(
              _formatPrice(displayStandardPrice),
              style:
                  standardPriceStyle ??
                  theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
            ),
          ],
        ),

        // VIP price (if applicable)
        if (hasVipDiscount && showVipUpsell) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber.shade300),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.workspace_premium,
                  size: 20,
                  color: Colors.amber,
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'VIP Price: ${_formatPrice(displayVipPrice)}',
                      style:
                          vipPriceStyle ??
                          theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.amber.shade700,
                          ),
                    ),
                    Text(
                      'Save ${_calculateSavings(displayStandardPrice, displayVipPrice)}% with VIP',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.amber.shade800,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
