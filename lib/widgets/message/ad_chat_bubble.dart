import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/models/ad.dart';
import 'package:live_app/utils/ad_utils.dart';
import 'package:live_app/widgets/ad_badge.dart';
import 'package:live_app/widgets/encrypted_image.dart';

class AdChatBubble extends ConsumerWidget {
  final Ad ad;

  const AdChatBubble({super.key, required this.ad});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageUrl = ad.imageLargeUrl ?? ad.imageMediumUrl ?? ad.imageSmallUrl;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: GestureDetector(
          onTap: () => onAdRedirection(ad, ref),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            decoration: BoxDecoration(
              color: Colors.grey.shade800,
              borderRadius: BorderRadius.circular(12),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (imageUrl != null && imageUrl.isNotEmpty)
                  Stack(
                    children: [
                      AspectRatio(
                        aspectRatio: 16 / 9,
                        child: EncryptedImage(
                          url: imageUrl,
                          fit: BoxFit.cover,
                          errorWidget: Container(
                            color: Colors.grey.shade700,
                            child: const Icon(
                              Icons.ad_units,
                              color: Colors.white54,
                              size: 40,
                            ),
                          ),
                        ),
                      ),
                      const Positioned(top: 8, left: 8, child: AdBadge()),
                    ],
                  ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ad.adTitle ?? ad.adName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (ad.adDescription != null &&
                          ad.adDescription!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            ad.adDescription!,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
