import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/models/vip.dart';
import 'package:live_app/page/vip_detail_page.dart';
import 'package:live_app/provider/currency_provider.dart';
import 'package:live_app/provider/i18n_provider.dart';
import 'package:live_app/provider/my_user_provider.dart';
import 'package:live_app/provider/vip_provider.dart';
import 'package:live_app/utils/json_utils.dart';
import 'package:live_app/widgets/encrypted_image.dart';

class VipCardList extends ConsumerStatefulWidget {
  final double? maxHeight;
  final BuildContext? dialogContext;

  const VipCardList({super.key, this.maxHeight = 300, this.dialogContext});

  @override
  ConsumerState<VipCardList> createState() => _VipCardListState();
}

class _VipCardListState extends ConsumerState<VipCardList> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(vipProvider.notifier).loadVips();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(vipProvider);
    final theme = Theme.of(context);
    final i18n = ref.read(i18nNotifierProvider.notifier);
    final currencyState = ref.watch(currencyProvider);
    final userVip = ref.watch(userProvider).user;
    final userVipId = userVip?.vip?.id;

    final sortedVips = [...state.vips]
      ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

    if (state.loading) {
      return SizedBox(
        height: 120,
        child: Center(
          child: CircularProgressIndicator(color: theme.colorScheme.onPrimary),
        ),
      );
    }

    if (state.error != null) {
      return SizedBox(
        height: 80,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                i18n.translate('errorLoadingVips'),
                style: TextStyle(color: theme.textTheme.bodySmall?.color),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => ref.read(vipProvider.notifier).loadVips(),
                child: Text(i18n.translate('retry')),
              ),
            ],
          ),
        ),
      );
    }

    if (sortedVips.isEmpty) {
      return const SizedBox.shrink();
    }

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: widget.maxHeight ?? 300),
      child: ListView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemCount: sortedVips.length,
        itemBuilder: (context, index) {
          final vip = sortedVips[index];
          return _buildCompactVipCard(
            context,
            currencyState,
            vip,
            theme,
            userVipId,
            i18n,
          );
        },
      ),
    );
  }

  Widget _buildCompactVipCard(
    BuildContext context,
    CurrencyState currencyState,
    Vip vip,
    ThemeData theme,
    String? userVipId,
    dynamic i18n,
  ) {
    final translation = vip.translations;
    final title = translation.name;
    final isRecommended = vip.isRecommended;
    final isCurrent = vip.id == userVipId;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (widget.dialogContext != null) {
              Navigator.of(widget.dialogContext!).pop();
            }
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => VipDetailPage(vip: vip)),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: isRecommended
                  ? const LinearGradient(
                      colors: [Color(0xFF2C2C2C), Color(0xFF1A1A1A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: isRecommended ? null : theme.cardColor,
              borderRadius: BorderRadius.circular(12),
              border: isRecommended
                  ? Border.all(color: const Color(0xFFFFD700), width: 1)
                  : Border.all(
                      color: theme.dividerColor.withValues(alpha: 0.2),
                    ),
            ),
            child: Row(
              children: [
                if (vip.logoUrl.isNotEmpty)
                  EncryptedImage(
                    url: vip.logoUrl,
                    width: 32,
                    height: 32,
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
                              title,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: isRecommended
                                    ? Colors.white
                                    : theme.textTheme.titleMedium?.color,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isRecommended) ...[
                            const SizedBox(width: 6),
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
                          if (isCurrent) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                i18n.translate('current'),
                                style: const TextStyle(
                                  color: Colors.green,
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
                        "${vip.validDays} ${i18n.translate('days')}",
                        style: TextStyle(
                          fontSize: 11,
                          color: isRecommended
                              ? Colors.grey[400]
                              : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      currencyState
                          .convertFromBase(parseDouble(vip.basePrice))
                          .toStringAsFixed(2),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isRecommended
                            ? Colors.white
                            : theme.textTheme.titleMedium?.color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: isRecommended ? Colors.grey[400] : Colors.grey[500],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
