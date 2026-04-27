import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/page/vip_list_page.dart';
import 'package:live_app/provider/i18n_provider.dart';
import 'package:live_app/provider/wallet_provider.dart';

class UpgradePlanButton extends ConsumerWidget {
  final double? width;
  final double? height;
  final double borderRadius;
  final VoidCallback? onPressed;
  final BuildContext? dialogContext;

  const UpgradePlanButton({
    super.key,
    this.width = double.infinity,
    this.height = 44,
    this.borderRadius = 14,
    this.onPressed,
    this.dialogContext,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final translate = ref.read(i18nNotifierProvider.notifier).translate;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFD4AF37), Color(0xFFFFD700)],
        ),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        onPressed:
            onPressed ??
            () {
              if (dialogContext != null) {
                Navigator.of(dialogContext!).pop();
              }
              ref.read(walletProvider.notifier).loadBalance();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const VipListPage()),
              );
            },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.diamond, color: Colors.black, size: 18),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                translate("upgradePlan"),
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
