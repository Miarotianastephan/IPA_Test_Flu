import 'package:flutter/material.dart';
import 'package:live_app/l10n/app_localizations.dart';

class VideoTypeToggleButton extends StatelessWidget {
  final bool isLongVideo;
  final VoidCallback onToggle;

  const VideoTypeToggleButton({
    super.key,
    required this.isLongVideo,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return TextButton(
      onPressed: onToggle,
      child: Row(
        children: [
          Text(
            isLongVideo ? localizations.longVideo : localizations.shortVideo,
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(width: 6),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: isLongVideo ? 1.25 : 1.0),
            duration: const Duration(milliseconds: 450),
            curve: Curves.easeInOut,
            builder: (context, value, child) {
              return Transform.rotate(
                angle: value * 3.1415926 * 2,
                child: child,
              );
            },
            child: const Icon(Icons.stay_current_portrait, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
