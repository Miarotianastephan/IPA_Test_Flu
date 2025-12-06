import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/userinfo.dart';
import '../page/user_detail_page.dart';
import 'follow_button.dart';

final _followStateProvider = StateProvider.family<bool, UserInfo>(
  (ref, user) => user.isFollowed,
);

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
    final followState = ref.watch(_followStateProvider(user));

    final isFollowed = followState;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (onTap != null) {
          onTap?.call(user);
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => UserDetailPage(user: user)),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.white24,
              backgroundImage: user.avatar != null && user.avatar!.isNotEmpty
                  ? NetworkImage(user.avatar!)
                  : null,
              child: (user.avatar == null || user.avatar!.isEmpty)
                  ? const Icon(Icons.person, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "${user.nickname}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
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
            FollowButton(userId: user.id.toString()),
          ],
        ),
      ),
    );
  }
}
