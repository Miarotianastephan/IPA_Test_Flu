import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/l10n/app_localizations.dart';
import 'package:live_app/provider/user_follow_provider.dart';
import 'package:live_app/utils/utils.dart';
import 'package:live_app/widgets/follow_button.dart';

import '../encrypted_image.dart';

class UserInfoRow extends ConsumerStatefulWidget {
  final String avatarUrl;
  final int userId;
  final String nickname;
  final int fansCount;
  final bool isFollowed;
  final Function(bool isFollowed)? onFollowPressed;

  const UserInfoRow({
    super.key,
    required this.avatarUrl,
    required this.userId,
    required this.nickname,
    required this.fansCount,
    required this.isFollowed,
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
            .read(userFollowProvider(widget.userId.toString()).notifier)
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
    final localizations = AppLocalizations.of(context)!;
    final followState = ref.watch(userFollowProvider(widget.userId.toString()));

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
                    userId: widget.userId,
                    url: widget.avatarUrl,
                    nickname: widget.nickname,
                  );
                },
                child: Text(
                  widget.nickname,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${followState.fansCount} ${localizations.fans}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),

        FollowButton(userId: widget.userId.toString()),
      ],
    );
  }
}
