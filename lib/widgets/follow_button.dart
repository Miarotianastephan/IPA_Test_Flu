import 'package:flutter/material.dart';
import 'package:live_app/l10n/app_localizations.dart';

class FollowButton extends StatelessWidget {
  final bool isFollowed;
  final ValueChanged<bool>? onPressed;

  const FollowButton({
    super.key,
    required this.isFollowed,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Container(
      height: 25,
      padding: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: isFollowed ? Colors.grey[400] : Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: TextButton(
        onPressed: () {
          onPressed?.call(!isFollowed);
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