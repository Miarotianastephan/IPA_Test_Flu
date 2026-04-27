import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/provider/i18n_provider.dart';

class PreviewTimerOverlay extends ConsumerStatefulWidget {
  final int durationSeconds;
  final VoidCallback onPreviewExpired;
  final VoidCallback? onSkipPreview;
  final ValueNotifier<bool>? videoPlayingNotifier;

  const PreviewTimerOverlay({
    super.key,
    required this.durationSeconds,
    required this.onPreviewExpired,
    this.onSkipPreview,
    this.videoPlayingNotifier,
  });

  @override
  ConsumerState<PreviewTimerOverlay> createState() =>
      _PreviewTimerOverlayState();
}

class _PreviewTimerOverlayState extends ConsumerState<PreviewTimerOverlay> {
  late int _remainingSeconds;
  Timer? _timer;
  bool _hasStarted = false;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.durationSeconds;

    if (widget.videoPlayingNotifier == null) {
      _startTimer();
    } else {
      widget.videoPlayingNotifier!.addListener(_onVideoPlayingChanged);
      if (widget.videoPlayingNotifier!.value) {
        _startTimer();
      }
    }
  }

  void _onVideoPlayingChanged() {
    if (!mounted) return;

    final isPlaying = widget.videoPlayingNotifier!.value;
    if (!_hasStarted && isPlaying) {
      _startTimer();
    }
  }

  void _startTimer() {
    if (_hasStarted) return;
    _hasStarted = true;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        _remainingSeconds--;
      });

      if (_remainingSeconds <= 0) {
        _timer?.cancel();
        widget.onPreviewExpired();
      }
    });
  }

  @override
  void dispose() {
    widget.videoPlayingNotifier?.removeListener(_onVideoPlayingChanged);
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;

    final i18n = ref.read(i18nNotifierProvider.notifier);

    return Positioned(
      top: 16,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.5),
              width: 2,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!_hasStarted)
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      theme.colorScheme.primary,
                    ),
                  ),
                )
              else
                Icon(Icons.preview, color: theme.colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                _hasStarted
                    ? '${i18n.translate("preview")}: ${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}'
                    : i18n.translate("loadingVideo"),
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (widget.onSkipPreview != null) ...[
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: widget.onSkipPreview,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      i18n.translate("unlock"),
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
