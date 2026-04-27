import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/widgets/encrypted_image.dart';

import '../../models/payment_channel.dart';

class PaymentChannelTile extends ConsumerWidget {
  final PaymentChannel channel;
  final bool isSelected;
  final VoidCallback onTap;

  const PaymentChannelTile({
    super.key,
    required this.channel,
    required this.isSelected,
    required this.onTap,
  });

  IconData _getChannelIcon() {
    final code = channel.channelCode.toLowerCase();
    if (code.contains('paypal')) return Icons.payment;
    if (code.contains('credit') || code.contains('card')) {
      return Icons.credit_card;
    }
    if (code.contains('apple')) return Icons.apple;
    if (code.contains('google')) return Icons.g_mobiledata;
    if (code.contains('bank')) return Icons.account_balance;
    return Icons.payment;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final hasIconUrl = channel.icon != null && channel.icon!.isNotEmpty;

    final accentColor = theme.colorScheme.onPrimary;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: accentColor.withValues(alpha: 0.1),
          highlightColor: accentColor.withValues(alpha: 0.05),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                      colors: [
                        accentColor.withValues(alpha: 0.15),
                        accentColor.withValues(alpha: 0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              border: Border.all(
                color: isSelected
                    ? accentColor
                    : isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.grey.shade300,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(16),
              color: isSelected
                  ? null
                  : isDark
                  ? Colors.white.withValues(alpha: 0.03)
                  : Colors.grey.shade50,
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: accentColor.withValues(alpha: 0.1),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(
                            colors: [
                              accentColor,
                              accentColor.withValues(alpha: 0.2),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : LinearGradient(
                            colors: isDark
                                ? [
                                    Colors.white.withValues(alpha: 0.1),
                                    Colors.white.withValues(alpha: 0.05),
                                  ]
                                : [Colors.grey.shade200, Colors.grey.shade100],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: accentColor.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: hasIconUrl
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: EncryptedImage(
                            url: channel.icon!,
                            width: 35,
                            height: 35,
                            fit: BoxFit.contain,
                            errorWidget: Icon(
                              _getChannelIcon(),
                              color: isSelected
                                  ? Colors.white
                                  : isDark
                                  ? Colors.white70
                                  : Colors.grey.shade600,
                              size: 28,
                            ),
                          ),
                        )
                      : Icon(
                          _getChannelIcon(),
                          color: isSelected
                              ? Colors.white
                              : isDark
                              ? Colors.white70
                              : Colors.grey.shade600,
                          size: 24,
                        ),
                ),
                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        channel.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: isSelected
                              ? accentColor
                              : isDark
                              ? Colors.white
                              : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),

                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? accentColor
                        : isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.grey.shade200,
                    border: Border.all(
                      color: isSelected
                          ? accentColor
                          : isDark
                          ? Colors.white.withValues(alpha: 0.2)
                          : Colors.grey.shade400,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: Colors.black, size: 14)
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAmountChip(
    BuildContext context,
    String text,
    bool isDark,
    bool isSelected,
    Color accentColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected
            ? accentColor.withValues(alpha: 0.15)
            : isDark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: isSelected
              ? accentColor
              : isDark
              ? Colors.white60
              : Colors.grey.shade600,
        ),
      ),
    );
  }
}
