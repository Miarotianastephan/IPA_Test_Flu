import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/provider/i18n_provider.dart';
import 'package:live_app/widgets/vip_badge.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../models/forum_attachment.dart';
import '../../models/forum_post.dart';
import '../../page/forum_post_detail_page.dart';
import '../../page/forum_tag_category_page.dart';
import '../encrypted_image.dart';

class ForumPostCard extends ConsumerWidget {
  final ForumPost post;
  final bool? showCategory;

  const ForumPostCard({
    super.key,
    required this.post,
    this.showCategory = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final i18n = ref.read(i18nNotifierProvider.notifier);
    final attachments = post.attachments ?? const <ForumAttachment>[];
    final hasAudio = attachments.any(
      (attachment) => attachment.fileType == 'audio',
    );
    final hasFile = attachments.any(
      (attachment) => attachment.fileType == 'file',
    );

    void goToForumTagCategory({
      required String title,
      required String type,
      required int id,
    }) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              ForumTagCategoryPage(title: title, type: type, id: id),
        ),
      );
    }

    Widget buildTag(IconData icon, String label) {
      return Container(
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: Colors.black),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(fontSize: 12, color: Colors.black)),
          ],
        ),
      );
    }

    Widget buildContentText(String description) {
      return _ForumPostDescriptionText(
        description: description,
        seeMoreLabel: i18n.translate('seeMore'),
      );
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      color: Colors.black54,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ForumPostDetailPage(postId: post.id),
            ),
          );
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (post.description.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: buildContentText(post.description),
                    ),
                  if (attachments.isNotEmpty)
                    _ForumPostMediaSection(
                      postId: post.id,
                      attachments: attachments,
                    ),
                  Padding(
                    padding: const EdgeInsets.only(right: 6, top: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: Row(
                            children: [
                              if (post.tags != null && post.tags!.isNotEmpty)
                                ...post.tags!
                                    .take(3)
                                    .map(
                                      (t) => Padding(
                                        padding: const EdgeInsets.only(left: 6),
                                        child: GestureDetector(
                                          onTap: () {
                                            goToForumTagCategory(
                                              title: t.name,
                                              type: "tag",
                                              id: t.id,
                                            );
                                          },
                                          child: Text(
                                            "#${t.name}",
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey.shade500,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                              if (post.tags != null && post.tags!.length > 3)
                                Padding(
                                  padding: const EdgeInsets.only(left: 6),
                                  child: GestureDetector(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text(
                                        "...",
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // if (post.price > 0) PriceTag(basePrice: post.price),
                            if (hasAudio) ...[
                              const SizedBox(width: 6),
                              buildTag(
                                Icons.audiotrack,
                                i18n.translate('hasAudio'),
                              ),
                            ],
                            if (hasFile) ...[
                              buildTag(
                                Icons.insert_drive_file,
                                i18n.translate('hasFile'),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(
                        Icons.remove_red_eye,
                        size: 14,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        "${post.viewCount}",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.comment,
                        size: 14,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        "${post.commentCount}",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      const Spacer(),
                      if (showCategory == true)
                        GestureDetector(
                          onTap: () {
                            if (post.category != null) {
                              goToForumTagCategory(
                                title: post.category!.name,
                                type: "category",
                                id: post.category!.id,
                              );
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              post.category?.name ??
                                  i18n.translate('unknownCategory'),
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      UserAvatar(
                        size: 24,
                        url: post.user?.avatar ?? "https://picsum.photos/40",
                        nickname: post.user?.nickname,
                        userId: post.userId,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        flex: 0,
                        child: Text(
                          post.user?.nickname ??
                              i18n.translate('anonymousUser'),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const VipBadge(vip: null, size: 14),
                      if (post.user != null && post.user!.isFollowed)
                        Container(
                          margin: const EdgeInsets.only(left: 6),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.tealAccent.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: Colors.tealAccent.withValues(alpha: 0.5),
                              width: 0.8,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.check_rounded,
                                size: 12,
                                color: Colors.tealAccent,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                i18n.translate('alreadyFollowed'),
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.2,
                                  color: Colors.tealAccent,
                                ),
                              ),
                            ],
                          ),
                        ),
                      const Spacer(),
                      Text(
                        post.createdAt.toString().substring(0, 10),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
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

class _ForumPostDescriptionText extends StatelessWidget {
  const _ForumPostDescriptionText({
    required this.description,
    required this.seeMoreLabel,
  });

  final String description;
  final String seeMoreLabel;

  @override
  Widget build(BuildContext context) {
    const maxLines = 4;
    final baseStyle = DefaultTextStyle.of(
      context,
    ).style.merge(const TextStyle(color: Colors.grey, fontSize: 14));
    final linkText = ' $seeMoreLabel';

    return LayoutBuilder(
      builder: (context, constraints) {
        final direction = Directionality.of(context);
        final textScaler = MediaQuery.textScalerOf(context);
        final linkStyle = baseStyle.copyWith(color: Colors.lightBlueAccent);
        final plainTp = TextPainter(
          text: TextSpan(text: description, style: baseStyle),
          maxLines: maxLines,
          textDirection: direction,
          textScaler: textScaler,
        )..layout(maxWidth: constraints.maxWidth);

        if (!plainTp.didExceedMaxLines) {
          return Text(
            description,
            style: baseStyle,
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
          );
        }

        bool fits(String visible) {
          final tp = TextPainter(
            text: TextSpan(
              style: baseStyle,
              children: [
                TextSpan(text: visible),
                const TextSpan(text: '...'),
                TextSpan(text: linkText, style: linkStyle),
              ],
            ),
            maxLines: maxLines,
            textDirection: direction,
            textScaler: textScaler,
          )..layout(maxWidth: constraints.maxWidth);
          return !tp.didExceedMaxLines;
        }

        int left = 0;
        int right = description.length;
        while (left < right) {
          final mid = (left + right + 1) >> 1;
          final candidate = description.substring(0, mid).trimRight();
          if (fits(candidate)) {
            left = mid;
          } else {
            right = mid - 1;
          }
        }

        final visible = description.substring(0, left).trimRight();

        return Text.rich(
          TextSpan(
            style: baseStyle,
            children: [
              TextSpan(text: visible),
              const TextSpan(text: '...'),
              TextSpan(
                text: linkText,
                style: linkStyle,
                recognizer: TapGestureRecognizer()..onTap = () {},
              ),
            ],
          ),
          maxLines: maxLines,
          overflow: TextOverflow.ellipsis,
          textScaler: textScaler,
        );
      },
    );
  }
}

const double _forumPostMediaWebActivationVisibleFraction = 0.18;
const double _forumPostMediaMobileActivationVisibleFraction = 0.08;

class _ForumPostMediaSection extends StatefulWidget {
  const _ForumPostMediaSection({
    required this.postId,
    required this.attachments,
  });

  final int postId;
  final List<ForumAttachment> attachments;

  @override
  State<_ForumPostMediaSection> createState() => _ForumPostMediaSectionState();
}

class _ForumPostMediaSectionState extends State<_ForumPostMediaSection> {
  static final Set<int> _activatedPostIds = <int>{};

  late List<ForumAttachment> _media;
  late bool _mediaActivated;

  double get _activationVisibleFraction => kIsWeb
      ? _forumPostMediaWebActivationVisibleFraction
      : _forumPostMediaMobileActivationVisibleFraction;

  @override
  void initState() {
    super.initState();
    _resetState();
  }

  @override
  void didUpdateWidget(covariant _ForumPostMediaSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.postId != widget.postId ||
        oldWidget.attachments != widget.attachments) {
      _resetState();
    }
  }

  void _resetState() {
    _media =
        widget.attachments
            .where(
              (attachment) =>
                  attachment.fileType == 'image' ||
                  attachment.fileType == 'video',
            )
            .toList()
          ..sort((a, b) => b.fileType.compareTo(a.fileType));
    _mediaActivated =
        _media.isEmpty || _activatedPostIds.contains(widget.postId);
  }

  void _handleVisibilityChanged(VisibilityInfo info) {
    if (_mediaActivated || info.visibleFraction < _activationVisibleFraction) {
      return;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _mediaActivated = true;
    });
    _activatedPostIds.add(widget.postId);
  }

  Widget _buildConstrainedEncryptedImage(
    String url, {
    BoxFit fit = BoxFit.cover,
    Widget? errorWidget,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite && constraints.maxWidth > 0
            ? constraints.maxWidth
            : null;
        final height =
            constraints.maxHeight.isFinite && constraints.maxHeight > 0
            ? constraints.maxHeight
            : null;

        return EncryptedImage(
          url: url,
          width: width,
          height: height,
          fit: fit,
          errorWidget: errorWidget,
        );
      },
    );
  }

  Widget _buildBrokenTile() {
    return Container(
      color: Colors.grey.shade500,
      child: const Center(
        child: Icon(Icons.broken_image, size: 48, color: Colors.white70),
      ),
    );
  }

  Widget _buildVideoOverlay() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(color: Colors.black26),
        const Center(
          child: Icon(Icons.play_circle_fill, color: Colors.white70, size: 48),
        ),
      ],
    );
  }

  Widget _buildDeferredTile({required bool isVideo}) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(color: const Color(0xFF1F1F1F)),
        if (isVideo) _buildVideoOverlay(),
      ],
    );
  }

  Widget _buildCountOverlay() {
    return Container(
      color: Colors.black45,
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.photo_library, color: Colors.white, size: 20),
            const SizedBox(width: 4),
            Text(
              '${_media.length - 3}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoThumbnailFallback() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(color: const Color(0xFF1F1F1F)),
        _buildVideoOverlay(),
      ],
    );
  }

  Widget _buildMediaTile(int index, {bool showCount = false}) {
    final attachment = _media[index];
    final isVideo = attachment.fileType == 'video';

    Widget content;
    if (!_mediaActivated) {
      content = _buildDeferredTile(isVideo: isVideo);
    } else if (isVideo) {
      final thumbnailUrl = attachment.thumbnailUrl ?? '';
      content = Stack(
        fit: StackFit.expand,
        children: [
          thumbnailUrl.isNotEmpty
              ? _buildConstrainedEncryptedImage(
                  thumbnailUrl,
                  fit: BoxFit.cover,
                  errorWidget: _buildVideoThumbnailFallback(),
                )
              : _buildVideoThumbnailFallback(),
          _buildVideoOverlay(),
        ],
      );
    } else if (attachment.fileUrl.isNotEmpty) {
      content = _buildConstrainedEncryptedImage(attachment.fileUrl);
    } else {
      content = _buildBrokenTile();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Stack(
        fit: StackFit.expand,
        children: [
          content,
          if (showCount && _media.length > 3) _buildCountOverlay(),
        ],
      ),
    );
  }

  Widget _buildMediaLayout() {
    if (_media.isEmpty) {
      return const SizedBox.shrink();
    }

    if (_media.length == 1) {
      return Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: AspectRatio(aspectRatio: 16 / 9, child: _buildMediaTile(0)),
      );
    }

    if (_media.length == 2) {
      return Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: AspectRatio(aspectRatio: 3 / 4, child: _buildMediaTile(0)),
            ),
            const SizedBox(width: 4),
            Expanded(
              flex: 2,
              child: AspectRatio(
                aspectRatio: 3 / 4,
                child: _buildMediaTile(_media.length - 2),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: AspectRatio(
        aspectRatio: 4 / 3,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(flex: 3, child: _buildMediaTile(0)),
            const SizedBox(width: 4),
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  Expanded(child: _buildMediaTile(_media.length - 2)),
                  const SizedBox(height: 4),
                  Expanded(
                    child: _buildMediaTile(_media.length - 1, showCount: true),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: ValueKey('forum-post-media-${widget.postId}'),
      onVisibilityChanged: _handleVisibilityChanged,
      child: _buildMediaLayout(),
    );
  }
}
