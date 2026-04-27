import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/userinfo.dart';
import '../page/user_detail_page.dart';
import 'encrypted_image.dart';
import 'follow_button.dart';
import 'vip_badge.dart';

class UserListItem extends ConsumerWidget {
  final UserInfo user;
  final Function(UserInfo user)? onTap;
  final VoidCallback? onFollowTap;

  const UserListItem({
    super.key,
    required this.user,
    this.onTap,
    this.onFollowTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void handleTap() {
      if (onTap != null) {
        onTap?.call(user);
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => UserDetailPage(user: user)),
        );
      }
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: handleTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Row(
          children: [
            UserAvatar(
              url: user.avatar,
              nickname: user.nickname,
              userId: user.id,
              vip: user.vip,
              size: 40,
              onTap: handleTap,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          "${user.nickname}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      VipBadge(vip: user.vip),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    user.bio ?? "",
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            FollowButton(userId: user.id),
          ],
        ),
      ),
    );
  }
}
