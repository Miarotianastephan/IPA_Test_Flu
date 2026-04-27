import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/models/ad.dart';
import 'package:live_app/utils/ad_utils.dart';
import 'package:live_app/widgets/ad_badge.dart';
import 'package:live_app/widgets/encrypted_image.dart';

class AdPostCard extends ConsumerWidget {
  final Ad ad;

  const AdPostCard({super.key, required this.ad});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageUrl = ad.imageLargeUrl ?? ad.imageMediumUrl ?? ad.imageSmallUrl;
    final hasImage = imageUrl != null && imageUrl.isNotEmpty;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      color: Colors.black54,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => onAdRedirection(ad, ref),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          ad.adTitle ?? ad.adName,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const AdBadge(),
                    ],
                  ),
                  const SizedBox(height: 8),

                  if (ad.adDescription != null && ad.adDescription!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        ad.adDescription!,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                  if (hasImage)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: EncryptedImage(
                            url: imageUrl,
                            fit: BoxFit.cover,
                            errorWidget: Container(
                              color: Colors.grey.shade500,
                              child: const Icon(
                                Icons.broken_image,
                                size: 48,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                  Padding(
                    padding: const EdgeInsets.only(right: 6, top: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox.shrink(),
                        if (ad.ctaText != null && ad.ctaText!.isNotEmpty)
                          GestureDetector(
                            onTap: () => onAdRedirection(ad, ref),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD81B60),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    ad.ctaText!,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.chevron_right,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 6),
                ],
              ),
            ),
            Divider(
              height: 1,
              thickness: 0.5,
              color: Colors.white.withValues(alpha: 0.15),
            ),
          ],
        ),
      ),
    );
  }
}
