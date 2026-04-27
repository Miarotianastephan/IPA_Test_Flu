import 'package:flutter/material.dart';

/// Badge widget to display VIP discount on content cards
class VipDiscountBadge extends StatelessWidget {
  final int discountPercentage;
  final bool isSmall;

  const VipDiscountBadge({
    super.key,
    required this.discountPercentage,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 6 : 8,
        vertical: isSmall ? 2 : 4,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(isSmall ? 8 : 12),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star, color: Colors.white, size: isSmall ? 12 : 14),
          SizedBox(width: isSmall ? 2 : 4),
          Text(
            '$discountPercentage% OFF',
            style: TextStyle(
              color: Colors.white,
              fontSize: isSmall ? 10 : 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// Price display widget with VIP discount
class PriceWithDiscount extends StatelessWidget {
  final double originalPrice;
  final double finalPrice;
  final int? discountPercentage;
  final bool isCompact;

  const PriceWithDiscount({
    super.key,
    required this.originalPrice,
    required this.finalPrice,
    this.discountPercentage,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasDiscount = finalPrice < originalPrice;

    if (isCompact) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (hasDiscount) ...[
            Text(
              '\$${originalPrice.toStringAsFixed(2)}',
              style: theme.textTheme.bodySmall?.copyWith(
                decoration: TextDecoration.lineThrough,
                color: Colors.grey,
              ),
            ),
            const SizedBox(width: 4),
          ],
          Text(
            '\$${finalPrice.toStringAsFixed(2)}',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: hasDiscount ? Colors.green : theme.colorScheme.primary,
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasDiscount && discountPercentage != null) ...[
          VipDiscountBadge(discountPercentage: discountPercentage!),
          const SizedBox(height: 8),
        ],
        if (hasDiscount) ...[
          Text(
            '\$${originalPrice.toStringAsFixed(2)}',
            style: theme.textTheme.bodyMedium?.copyWith(
              decoration: TextDecoration.lineThrough,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
        ],
        Text(
          '\$${finalPrice.toStringAsFixed(2)}',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: hasDiscount ? Colors.green : theme.colorScheme.primary,
          ),
        ),
        if (hasDiscount) ...[
          const SizedBox(height: 4),
          Text(
            'Save \$${(originalPrice - finalPrice).toStringAsFixed(2)}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.green,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}
