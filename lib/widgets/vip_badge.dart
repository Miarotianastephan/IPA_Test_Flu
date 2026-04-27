import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/vip.dart';
import '../provider/vip_provider.dart';
import 'encrypted_image.dart';

class VipBadge extends ConsumerWidget {
  final Vip? vip;
  final String? vipId;
  final double size;
  final EdgeInsetsGeometry padding;
  const VipBadge({
    super.key,
    required this.vip,
    this.vipId,
    this.size = 20,
    this.padding = const EdgeInsets.all(0),
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final normalizedVipId = (vipId != null && vipId!.isNotEmpty)
        ? vipId
        : null;

    var resolvedVip = vip;
    if (resolvedVip == null && normalizedVipId != null) {
      final vipState = ref.watch(vipProvider);
      for (final item in vipState.vips) {
        if (item.id == normalizedVipId) {
          resolvedVip = item;
          break;
        }
      }

      if (resolvedVip == null &&
          vipState.vips.isEmpty &&
          !vipState.loading) {
        Future.microtask(() => ref.read(vipProvider.notifier).loadVips());
      }
    }

    final url = resolvedVip?.logoUrl;
    if (url == null || url.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: padding,
      child: EncryptedImage(
        key: ValueKey('vip_badge_${resolvedVip?.id ?? normalizedVipId}'),
        url: url,
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorWidget: Icon(Icons.stars, size: size, color: Colors.amber),
      ),
    );
  }
}
