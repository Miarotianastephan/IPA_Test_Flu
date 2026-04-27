import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/database/download_database.dart';
import 'package:live_app/provider/i18n_provider.dart';
import 'package:live_app/utils/text_util.dart';
import 'package:live_app/widgets/encrypted_image.dart';

class DownloadedListItem extends StatelessWidget {
  final Download item;
  final bool isDeleteMode;
  final String statusLabel;
  final Color statusColor;
  final String primaryActionLabel;
  final IconData primaryActionIcon;
  final bool showSecondaryAction;
  final VoidCallback onTap;
  final VoidCallback onPrimaryAction;
  final VoidCallback? onSecondaryAction;
  final VoidCallback onDelete;

  const DownloadedListItem({
    super.key,
    required this.item,
    required this.isDeleteMode,
    required this.statusLabel,
    required this.statusColor,
    required this.primaryActionLabel,
    required this.primaryActionIcon,
    required this.showSecondaryAction,
    required this.onTap,
    required this.onPrimaryAction,
    required this.onSecondaryAction,
    required this.onDelete,
  });

  String _typeLabel(dynamic i18n) {
    switch (item.type) {
      case "short":
        return i18n.translate("shortVideo", fallback: "Short Video");
      case "long":
        return i18n.translate("longVideo", fallback: "Long Video");
      case "forum":
        return i18n.translate("post", fallback: "Post");
      default:
        return item.type;
    }
  }

  bool _isTallCover() {
    // Keep compatible with the previous tile rule:
    // only long videos use the shorter cover, others use taller covers.
    return item.type != "long";
  }

  @override
  Widget build(BuildContext context) {
    final i18n = ProviderScope.containerOf(
      context,
      listen: false,
    ).read(i18nNotifierProvider.notifier);
    final showProgress =
        item.status == "downloading" ||
        item.status == "paused" ||
        (item.progress > 0 && item.progress < 100);
    final progressValue = item.progress.clamp(0, 100) / 100;
    final isTallCover = _isTallCover();
    final coverWidth = isTallCover ? 92.0 : 132.0;
    final coverHeight = isTallCover ? 152.0 : 84.0;
    final durationText = (item.durationSeconds ?? 0) > 0
        ? formatDuration(item.durationSeconds ?? 0)
        : "--:--";

    return Material(
      color: const Color(0xFF111111),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Stack(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: SizedBox(
                          width: coverWidth,
                          height: coverHeight,
                          child: (item.coverUrl.isNotEmpty)
                              ? EncryptedImage(
                                  url: item.coverUrl,
                                  fit: BoxFit.cover,
                                  errorWidget: Container(
                                    color: Colors.grey.shade900,
                                    child: const Center(
                                      child: Icon(
                                        Icons.broken_image,
                                        size: 26,
                                        color: Colors.white54,
                                      ),
                                    ),
                                  ),
                                )
                              : Container(
                                  color: Colors.grey.shade900,
                                  child: const Center(
                                    child: Icon(
                                      Icons.video_file,
                                      size: 26,
                                      color: Colors.white54,
                                    ),
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white12,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    _typeLabel(i18n),
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: statusColor.withValues(alpha: 0.18),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: statusColor.withValues(
                                        alpha: 0.45,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    statusLabel,
                                    style: TextStyle(
                                      color: statusColor,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(
                                  Icons.access_time_rounded,
                                  size: 13,
                                  color: Colors.white54,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  durationText,
                                  style: const TextStyle(
                                    color: Colors.white54,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (isDeleteMode)
                    Positioned(
                      top: -4,
                      right: -4,
                      child: GestureDetector(
                        onTap: onDelete,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.black87,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.delete_outline_rounded,
                            color: Colors.redAccent,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              _DownloadedListItemActions(
                item: item,
                showProgress: showProgress,
                progressValue: progressValue,
                primaryActionLabel: primaryActionLabel,
                primaryActionIcon: primaryActionIcon,
                onPrimaryAction: onPrimaryAction,
                onSecondaryAction: onSecondaryAction,
                showSecondaryAction: showSecondaryAction,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DownloadedListItemActions extends StatelessWidget {
  final Download item;
  final bool showProgress;
  final double progressValue;
  final String primaryActionLabel;
  final IconData primaryActionIcon;
  final VoidCallback onPrimaryAction;
  final VoidCallback? onSecondaryAction;
  final bool showSecondaryAction;

  const _DownloadedListItemActions({
    required this.item,
    required this.showProgress,
    required this.progressValue,
    required this.primaryActionLabel,
    required this.primaryActionIcon,
    required this.onPrimaryAction,
    required this.onSecondaryAction,
    required this.showSecondaryAction,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (showProgress) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: progressValue,
                    minHeight: 6,
                    backgroundColor: Colors.white12,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.lightBlueAccent,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "${item.progress.clamp(0, 100)}%",
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ],
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onPrimaryAction,
                icon: Icon(primaryActionIcon, size: 16),
                label: Text(primaryActionLabel),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white24),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(34),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
            ),
            if (showSecondaryAction && onSecondaryAction != null) ...[
              const SizedBox(width: 8),
              SizedBox(
                height: 34,
                width: 34,
                child: OutlinedButton(
                  onPressed: onSecondaryAction,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.redAccent),
                    foregroundColor: Colors.redAccent,
                    padding: EdgeInsets.zero,
                  ),
                  child: const Icon(Icons.cancel_rounded, size: 16),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
