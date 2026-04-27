import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/video_info.dart';
import '../../provider/video_preview_provider.dart';
import '../../provider/wallet_provider.dart';
import 'price_display.dart';

/// Price display popup for video content
class PriceDisplayPopup extends ConsumerStatefulWidget {
  final VideoInfo video;
  final VoidCallback? onPreview;
  final VoidCallback? onBuyNow;
  final VoidCallback? onCancel;

  const PriceDisplayPopup({
    super.key,
    required this.video,
    this.onPreview,
    this.onBuyNow,
    this.onCancel,
  });

  @override
  ConsumerState<PriceDisplayPopup> createState() => _PriceDisplayPopupState();

  /// Show the popup as a bottom sheet
  static Future<void> show({
    required BuildContext context,
    required VideoInfo video,
    VoidCallback? onPreview,
    VoidCallback? onBuyNow,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PriceDisplayPopup(
        video: video,
        onPreview: onPreview,
        onBuyNow: onBuyNow,
        onCancel: () => Navigator.of(context).pop(),
      ),
    );
  }
}

class _PriceDisplayPopupState extends ConsumerState<PriceDisplayPopup> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final previewState = ref.watch(videoPreviewProvider);
    final walletState = ref.watch(walletProvider);

    // For now, assume preview is enabled. Will be controlled by feature flags later
    final canPreview = previewState.hasQuotaRemaining;
    final hasSufficientBalance =
        walletState.balance?.hasSufficientBalance(widget.video.price) ?? false;

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle bar
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

          // Video thumbnail and title
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  widget.video.cover,
                  width: 100,
                  height: 140,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 100,
                    height: 140,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.movie, size: 40),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Video info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.video.title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          _formatDuration(widget.video.duration),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),

          // Price display
          PriceDisplay(
            standardPrice: widget.video.price,
            vipPrice: widget.video.needVip ? widget.video.price * 0.67 : null,
            currency: 'USD',
            showVipUpsell: !widget.video.needVip,
          ),

          // Preview info
          if (canPreview) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.play_circle_outline,
                    color: Colors.blue,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      previewState.getQuotaText(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Wallet balance info
          if (walletState.balance != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.account_balance_wallet,
                  size: 16,
                  color: Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  'Wallet Balance: \$${walletState.balance!.availableBalance.toStringAsFixed(2)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: hasSufficientBalance
                        ? Colors.green.shade700
                        : Colors.orange.shade700,
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 24),

          // Action buttons
          Row(
            children: [
              // Preview button (if available)
              if (canPreview && widget.onPreview != null) ...[
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      widget.onPreview?.call();
                    },
                    icon: const Icon(Icons.visibility),
                    label: const Text('Preview'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],

              // Buy now button
              Expanded(
                flex: canPreview ? 1 : 2,
                child: ElevatedButton.icon(
                  onPressed: widget.onBuyNow == null
                      ? null
                      : () {
                          Navigator.of(context).pop();
                          widget.onBuyNow?.call();
                        },
                  icon: const Icon(Icons.payment),
                  label: Text(hasSufficientBalance ? 'Buy Now' : 'Add Funds'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: hasSufficientBalance
                        ? theme.colorScheme.primary
                        : Colors.orange,
                  ),
                ),
              ),
            ],
          ),

          // Cancel button
          const SizedBox(height: 12),
          TextButton(
            onPressed: widget.onCancel ?? () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),

          // Safe area padding
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  String _formatDuration(int seconds) {
    final duration = Duration(seconds: seconds);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final secs = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${secs}s';
    } else {
      return '${secs}s';
    }
  }
}
