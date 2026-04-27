import 'package:flutter/material.dart';
import '../../models/content_access_response.dart';
import 'vip_discount_badge.dart';

/// Widget to show lock status and pricing on video cards
class ContentLockIndicator extends StatelessWidget {
  final ContentAccessResponse? accessResponse;
  final double? defaultPrice;
  final bool isCompact;

  const ContentLockIndicator({
    super.key,
    this.accessResponse,
    this.defaultPrice,
    this.isCompact = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // If access response is null or has access, show nothing
    if (accessResponse == null || accessResponse!.hasAccess) {
      return const SizedBox.shrink();
    }

    // If payment not required, show nothing
    if (!accessResponse!.requiresPayment) {
      return const SizedBox.shrink();
    }

    final price = accessResponse!.price ?? defaultPrice;
    if (price == null) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 6 : 8,
        vertical: isCompact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.lock,
            color: theme.colorScheme.primary,
            size: isCompact ? 14 : 16,
          ),
          const SizedBox(width: 4),
          if (accessResponse!.isVipDiscount &&
              accessResponse!.originalPrice != null) ...[
            // Show both original and discounted price
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '\$${accessResponse!.originalPrice!.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: isCompact ? 10 : 12,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
                Text(
                  '\$${price.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isCompact ? 12 : 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ] else ...[
            // Show only price
            Text(
              '\$${price.toStringAsFixed(2)}',
              style: TextStyle(
                color: Colors.white,
                fontSize: isCompact ? 12 : 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Complete content lock badge with VIP discount for video cards
class ContentLockBadge extends StatelessWidget {
  final ContentAccessResponse? accessResponse;
  final double? defaultPrice;

  const ContentLockBadge({super.key, this.accessResponse, this.defaultPrice});

  @override
  Widget build(BuildContext context) {
    // If access response is null or has access, show nothing
    if (accessResponse == null || accessResponse!.hasAccess) {
      return const SizedBox.shrink();
    }

    // If payment not required, show nothing
    if (!accessResponse!.requiresPayment) {
      return const SizedBox.shrink();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // VIP Discount Badge (if applicable)
        if (accessResponse!.isVipDiscount &&
            accessResponse!.discountPercentage > 0)
          VipDiscountBadge(
            discountPercentage: accessResponse!.discountPercentage,
            isSmall: true,
          ),
        const SizedBox(height: 4),

        // Lock Indicator with Price
        ContentLockIndicator(
          accessResponse: accessResponse,
          defaultPrice: defaultPrice,
          isCompact: true,
        ),

        // Preview Available Badge
        if (accessResponse!.hasPreviewsAvailable) ...[
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.purple.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: Colors.purple.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.play_circle_outline,
                  color: Colors.purple,
                  size: 12,
                ),
                const SizedBox(width: 2),
                Text(
                  '${accessResponse!.previewsRemaining} previews',
                  style: const TextStyle(
                    color: Colors.purple,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
