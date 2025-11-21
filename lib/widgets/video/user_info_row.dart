import 'package:flutter/material.dart';
import 'package:live_app/l10n/app_localizations.dart';
import 'package:live_app/utils/utils.dart';
import 'package:live_app/widgets/follow_button.dart';

import '../encrypted_image.dart';

class UserInfoRow extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Row(
      children: [
        UserAvatar(
          userId: userId,
          url: avatarUrl,
          nickname: nickname,
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
                    userId: userId,
                    url: avatarUrl,
                    nickname: nickname,
                  );
                },
                child: Text(
                  nickname,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$fansCount ${localizations.fans}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),

        FollowButton(isFollowed: isFollowed, onPressed: onFollowPressed),
      ],
    );
  }
}
