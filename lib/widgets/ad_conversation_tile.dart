import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/models/ad.dart';
import 'package:live_app/utils/ad_utils.dart';
import 'package:live_app/widgets/ad_badge.dart';
import 'package:live_app/widgets/encrypted_image.dart';

class AdConversationTile extends ConsumerWidget {
  final Ad ad;
  final VoidCallback? onClose;

  const AdConversationTile({super.key, required this.ad, this.onClose});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final url = ad.imageLargeUrl ?? ad.imageMediumUrl ?? ad.imageSmallUrl;

    return ListTile(
      onTap: () => onAdRedirection(ad, ref),
      leading: _buildLeading(url),
      title: Row(
        children: [
          Flexible(
            child: Text(
              ad.adTitle ?? ad.adName,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          const AdBadge(),
        ],
      ),
      subtitle: Text(
        ad.adDescription ?? '',
        style: const TextStyle(
          color: Color.fromARGB(255, 158, 158, 158),
          fontSize: 14,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: _buildTrailing(),
    );
  }

  Widget _buildLeading(String? url) {
    if (url == null || url.isEmpty) {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.ad_units, color: Colors.white, size: 24),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        width: 40,
        height: 40,
        child: EncryptedImage(
          url: url,
          fit: BoxFit.cover,
          errorWidget: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.ad_units, color: Colors.white, size: 24),
          ),
        ),
      ),
    );
  }

  Widget _buildTrailing() {
    if (onClose != null) {
      return GestureDetector(
        onTap: onClose,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: Colors.white10,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.close, color: Colors.white54, size: 16),
        ),
      );
    }
    return const Icon(Icons.chevron_right, color: Colors.white38, size: 20);
  }
}
