import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/provider/current_user_provider.dart';
import 'package:live_app/provider/i18n_provider.dart';
import 'package:live_app/provider/user_follow_provider.dart';

class FollowButton extends ConsumerStatefulWidget {
  final String userId;

  const FollowButton({super.key, required this.userId});

  @override
  ConsumerState<FollowButton> createState() => _FollowButtonState();
}

class _FollowButtonState extends ConsumerState<FollowButton> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final currentUserId = ref.watch(currentUserIdProvider);
    if (widget.userId == currentUserId) {
      return const SizedBox.shrink();
    }

    final i18n = ref.read(i18nNotifierProvider.notifier);
    String translate(String key) => i18n.translate(key);
    final isFollowed = ref.watch(userFollowProvider(widget.userId)).isFollowed;

    return GestureDetector(
      onTap: _isLoading
          ? null
          : () async {
              final messenger = ScaffoldMessenger.maybeOf(context);
              setState(() {
                _isLoading = true;
              });
              try {
                await ref
                    .read(userFollowProvider(widget.userId).notifier)
                    .toggleFollow();
              } catch (e) {
                if (mounted) {
                  messenger?.showSnackBar(
                    SnackBar(
                      content: Text('Error: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } finally {
                if (mounted) {
                  setState(() {
                    _isLoading = false;
                  });
                }
              }
            },
      child: Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: isFollowed ? const Color(0xFF2D2D2D) : const Color(0xFFD11545),
          borderRadius: BorderRadius.circular(21),
        ),
        child: Center(
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isFollowed ? translate("followed") : translate("follow"),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (isFollowed) ...[
                      const SizedBox(width: 4),
                      const Icon(Icons.check, color: Colors.white, size: 16),
                    ],
                  ],
                ),
        ),
      ),
    );
  }
}
