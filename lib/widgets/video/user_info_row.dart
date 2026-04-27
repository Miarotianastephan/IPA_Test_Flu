import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/provider/i18n_provider.dart';
import 'package:live_app/provider/user_follow_provider.dart';
import 'package:live_app/utils/utils.dart';
import 'package:live_app/widgets/follow_button.dart';
import 'package:live_app/widgets/vip_badge.dart';
import 'package:live_app/models/vip.dart';

import '../encrypted_image.dart';

class UserInfoRow extends ConsumerStatefulWidget {
  final String avatarUrl;
  final String userId;
  final String nickname;
  final int fansCount;
  final bool isFollowed;
  final Vip? vip;
  final Function(bool isFollowed)? onFollowPressed;

  const UserInfoRow({
    super.key,
    required this.avatarUrl,
    required this.userId,
    required this.nickname,
    required this.fansCount,
    required this.isFollowed,
    this.vip,
    this.onFollowPressed,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _UserInfoRowState();
}

class _UserInfoRowState extends ConsumerState<UserInfoRow> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref
            .read(userFollowProvider(widget.userId).notifier)
            .setFromBackend(
              isFollowed: widget.isFollowed,
              fansCount: widget.fansCount,
              followCount: 0,
            );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final i18n = ref.read(i18nNotifierProvider.notifier);
    final followState = ref.watch(userFollowProvider(widget.userId));

    return Row(
      children: [
        UserAvatar(
          userId: widget.userId,
          url: widget.avatarUrl,
          nickname: widget.nickname,
          size: 40,
        ),
        const SizedBox(width: 12),

        // 用户名 & 粉丝数
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  toUserDetailPage(
                    context: context,
                    ref: ref,
                    userId: widget.userId,
                    url: widget.avatarUrl,
                    nickname: widget.nickname,
                    vip: widget.vip,
                  );
                },
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        widget.nickname,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(width: 4),
                    VipBadge(vip: widget.vip),
                  ],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${followState.fansCount} ${i18n.translate('fans')}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),

        FollowButton(userId: widget.userId),
      ],
    );
  }
}
