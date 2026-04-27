import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

import '../../models/video_info.dart';
import '../../models/vip.dart';
import '../../provider/currency_provider.dart';
import '../../provider/i18n_provider.dart';
import '../../utils/json_utils.dart';
import '../encrypted_image.dart';

class OptionCard extends StatelessWidget {
  final String title;
  final String? priceText;
  final String? logoUrl;
  final bool showLogo;
  final bool isRecommended;
  final bool isCurrent;
  final VoidCallback? onTap;

  const OptionCard({
    super.key,
    required this.title,
    this.priceText,
    this.logoUrl,
    this.showLogo = true,
    this.isRecommended = false,
    this.isCurrent = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      width: double.infinity,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isCurrent ? null : onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            decoration: BoxDecoration(
              gradient: isRecommended
                  ? const LinearGradient(
                      colors: [Color(0xFF2C2C2C), Color(0xFF1A1A1A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: isRecommended ? null : const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(8),
              border: isRecommended
                  ? Border.all(color: const Color(0xFFFFD700), width: 1)
                  : isCurrent
                  ? Border.all(color: Colors.green, width: 1)
                  : Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (showLogo)
                  if (logoUrl != null && logoUrl!.isNotEmpty) ...[
                    EncryptedImage(
                      url: logoUrl!,
                      width: 18,
                      height: 18,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(width: 10),
                  ] else ...[
                    Image.asset(
                      'lib/assets/buy_single.png',
                      width: 18,
                      height: 18,
                    ),
                    const SizedBox(width: 10),
                  ],
                Flexible(
                  child: Text(
                    priceText != null ? '$title $priceText' : title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isCurrent
                          ? Colors.green
                          : isRecommended
                          ? Colors.white
                          : Colors.white.withOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isCurrent) ...[
                  const SizedBox(width: 8),
                  const Icon(Icons.check_circle, color: Colors.green, size: 18),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget buildVipCard(
  Vip vip,
  String? userVipId,
  WidgetRef ref,
  VoidCallback onTap,
) {
  final currencyState = ref.read(currencyProvider);
  final price = currencyState
      .convertFromBase(parseDouble(vip.basePrice))
      .toStringAsFixed(2);

  return OptionCard(
    title: vip.translations.name,
    priceText: '($price)',
    logoUrl: vip.logoUrl,
    showLogo: false,
    isRecommended: vip.isRecommended,
    isCurrent: vip.id == userVipId,
    onTap: onTap,
  );
}

Widget buildDirectBuyOptionCard(
  String title,
  double basePrice,
  WidgetRef ref,
  VoidCallback onTap,
) {
  final currencyState = ref.read(currencyProvider);
  final price = currencyState.convertFromBase(basePrice).toStringAsFixed(2);

  return OptionCard(
    title: title,
    priceText: '($price)',
    logoUrl: null,
    showLogo: false,
    isRecommended: true,
    isCurrent: false,
    onTap: onTap,
  );
}

Widget buildSingleBuyCard(
  VideoInfo videoInfo,
  WidgetRef ref,
  VoidCallback onTap,
) {
  return buildDirectBuyOptionCard(
    ref.read(i18nNotifierProvider.notifier).translate("payDirectly"),
    parseDouble(videoInfo.price),
    ref,
    onTap,
  );
}
