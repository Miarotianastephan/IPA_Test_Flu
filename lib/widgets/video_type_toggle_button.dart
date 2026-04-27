import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/provider/i18n_provider.dart';

class VideoTypeToggleButton extends ConsumerWidget {
  final bool? isLongVideo;
  final VoidCallback onToggle;
  final bool withText;

  const VideoTypeToggleButton({
    super.key,
    this.isLongVideo,
    required this.onToggle,
    required this.withText,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final i18n = ref.read(i18nNotifierProvider.notifier);
    return withText
        ? TextButton(
            onPressed: onToggle,
            child: Row(
              children: [
                Text(
                  isLongVideo == null
                      ? ""
                      : isLongVideo!
                      ? i18n.translate('longVideo')
                      : i18n.translate('shortVideo'),

                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
                const SizedBox(width: 6),
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(
                    begin: 0,
                    end: isLongVideo == null
                        ? 0.0
                        : isLongVideo!
                        ? 1.25
                        : 1.0,
                  ),
                  duration: const Duration(milliseconds: 450),
                  curve: Curves.easeInOut,
                  builder: (context, value, child) {
                    return Transform.rotate(
                      angle: value * 3.1415926 * 2,
                      child: child,
                    );
                  },
                  child: const Icon(
                    Icons.stay_current_portrait,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          )
        : InkWell(
            onTap: onToggle,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(
                begin: 0,
                end: isLongVideo == null
                    ? 0.0
                    : isLongVideo!
                    ? 1.25
                    : 1.0,
              ),
              duration: const Duration(milliseconds: 450),
              curve: Curves.easeInOut,
              builder: (context, value, child) {
                return Transform.rotate(
                  angle: value * 3.1415926 * 2,
                  child: child,
                );
              },
              child: Padding(
                padding: EdgeInsets.all(5.0),
                child: const Icon(
                  Icons.stay_current_portrait,
                  size: 20.0,
                  color: Colors.white,
                ),
              ),
            ),
          );
  }
}
