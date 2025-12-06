import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/l10n/app_localizations.dart';
import 'package:live_app/provider/user_follow_provider.dart';

class FollowButton extends ConsumerWidget {
  final String userId;

  const FollowButton({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context)!;
    final isFollowed = ref.watch(userFollowProvider(userId)).isFollowed;

    return Container(
      height: 25,
      padding: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: isFollowed ? Colors.grey[400] : Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: TextButton(
        onPressed: () async {
          try {
            await ref.read(userFollowProvider(userId).notifier).toggleFollow();
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: ${e.toString()}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: Center(
          child: Text(
            isFollowed ? localizations.followed : localizations.follow,
            style: TextStyle(
              color: isFollowed ? Colors.white : Colors.black,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
