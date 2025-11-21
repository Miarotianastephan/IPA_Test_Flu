import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:live_app/l10n/app_localizations.dart';

import '../../models/forum_post.dart';
import '../../page/forum_post_detail_page.dart';
import '../../page/forum_tag_category_page.dart';
import '../encrypted_image.dart';

class ForumPostCard extends StatelessWidget {
  final ForumPost post;

  const ForumPostCard({
    super.key,
    required this.post,
  });


  @override
  Widget build(BuildContext context) {
    void goToForumTagCategory({
      required String title,
      required String type,
      required int id,
    }) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              ForumTagCategoryPage(
                title: title,
                type: type,
                id: id,
              ),
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

    Widget buildContentText(String content) {
      const int maxLines = 4;
      const TextStyle baseStyle = TextStyle(color: Colors.grey, fontSize: 14);
      final String linkText = ' ${AppLocalizations.of(context)!.seeMore }';
      const TextStyle linkStyle = TextStyle(color: Colors.lightBlueAccent);

      return LayoutBuilder(
        builder: (context, constraints) {
          final direction = Directionality.of(context);
          final plainTp = TextPainter(
            text: TextSpan(text: content, style: baseStyle),
            maxLines: maxLines,
            textDirection: direction,
          )..layout(maxWidth: constraints.maxWidth);

          if (!plainTp.didExceedMaxLines) {
            return Text(
              content,
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
            )..layout(maxWidth: constraints.maxWidth);
            return !tp.didExceedMaxLines;
          }

          int left = 0;
          int right = content.length;
          while (left < right) {
            final mid = (left + right + 1) >> 1;
            final candidate = content.substring(0, mid).trimRight();
            if (fits(candidate)) {
              left = mid;
            } else {
              right = mid - 1;
            }
          }

          final visible = content.substring(0, left).trimRight();

          return RichText(
            maxLines: maxLines,
            text: TextSpan(
              style: baseStyle,
              children: [
                TextSpan(text: visible),
                TextSpan(
                  text: linkText,
                  style: linkStyle,
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      debugPrint("查看全文：${post.title}");
                    },
                ),
              ],
            ),
          );
        },
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
                  if (post.content.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: buildContentText(post.content),
                    ),
                  if (post.attachments != null && post.attachments!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: List.generate(3, (index) {
                              final media = post.attachments!
                                  .where(
                                    (a) =>
                                        a.fileType == 'image' ||
                                        a.fileType == 'video',
                                  )
                                  .toList();
                              if (index < media.length) {
                                final attachment = media[index];
                                return Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 2.0,
                                    ),
                                    child: AspectRatio(
                                      aspectRatio: 1,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Stack(
                                          fit: StackFit.expand,
                                          children: [
                                            if (attachment.fileType == 'video')
                                              Stack(
                                                fit: StackFit.expand,
                                                children: [
                                                  Image.network(
                                                    attachment.thumbnailUrl ??
                                                        "",
                                                    fit: BoxFit.cover,
                                                  ),
                                                  Container(
                                                    color: Colors.black26,
                                                  ),
                                                  const Center(
                                                    child: Icon(
                                                      Icons.play_circle_fill,
                                                      color: Colors.white70,
                                                      size: 48,
                                                    ),
                                                  ),
                                                ],
                                              )
                                            else
                                              Image.network(
                                                attachment.fileUrl,
                                                fit: BoxFit.cover,
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              } else {
                                return const Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 2.0,
                                    ),
                                    child: AspectRatio(
                                      aspectRatio: 1,
                                      child: SizedBox.shrink(),
                                    ),
                                  ),
                                );
                              }
                            }),
                          ),
                        ],
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(right: 6, top: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            if (post.attachments != null &&
                                post.attachments!
                                        .where(
                                          (a) =>
                                              a.fileType == 'image' ||
                                              a.fileType == 'video',
                                        )
                                        .length >
                                    3)
                              buildTag(Icons.image, AppLocalizations.of(context)!.moreMedia ),
                            if (post.attachments != null &&
                                post.attachments!.any(
                                  (a) => a.fileType == 'audio',
                                ))
                              buildTag(Icons.audiotrack, AppLocalizations.of(context)!.hasAudio),
                            if (post.attachments != null &&
                                post.attachments!.any(
                                  (a) => a.fileType == 'file',
                                ))
                              buildTag(Icons.insert_drive_file, AppLocalizations.of(context)!.hasFile ),
                          ],
                        ),
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
                              post.category?.name ?? AppLocalizations.of(context)!.unknownCategory,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.black,
                              ),
                            ),
                          ),
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
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: Row(
                          children: [
                            if (post.tags != null && post.tags!.isNotEmpty)
                              ...post.tags!.take(2).map(
                                    (t) =>
                                    Padding(
                                      padding: const EdgeInsets.only(left: 6),
                                      child: GestureDetector(
                                        onTap: () {
                                          goToForumTagCategory(
                                            title: t.name,
                                            type: "tag",
                                            id: t.id,
                                          );
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade200,
                                            borderRadius: BorderRadius.circular(
                                                4),
                                          ),
                                          child: Text(
                                            t.name,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                              ),
                            if (post.tags != null && post.tags!.length > 2)
                              Padding(
                                padding: const EdgeInsets.only(left: 6),
                                child: GestureDetector(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
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
                      Text(
                        post.user?.nickname ?? AppLocalizations.of(context)!.anonymousUser ,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
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
                                 AppLocalizations.of(context)!.alreadyFollowed,
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
