import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/models/ad_video.dart';
import 'package:live_app/utils/ad_utils.dart';
import 'package:live_app/utils/text_util.dart';
import 'package:live_app/widgets/encrypted_image.dart';

class AdCoverImageScreen extends ConsumerStatefulWidget {
  final String coverImageUrl;
  final int duration;
  final AdTargetType? targetType;
  final String? jumpUrl;
  final String? claimUrl;
  final VoidCallback onAdFinished;

  const AdCoverImageScreen({
    super.key,
    required this.coverImageUrl,
    required this.duration,
    this.targetType,
    this.jumpUrl,
    this.claimUrl,
    required this.onAdFinished,
  });

  @override
  ConsumerState<AdCoverImageScreen> createState() => _AdCoverImageScreenState();
}

class _AdCoverImageScreenState extends ConsumerState<AdCoverImageScreen> {
  bool _canClose = false;
  int _remainingSeconds = 5;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 1) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        timer.cancel();
        setState(() {
          _canClose = true;
          _remainingSeconds = 0;
        });
      }
    });
  }

  void _finishAd() {
    if (_canClose && mounted) {
      widget.onAdFinished();
      Navigator.of(context).pop();
    }
  }

  Future<void> _handleCta() async {
    final url = isValidUrl(widget.claimUrl) ? widget.claimUrl : widget.jumpUrl;
    await handleAdVideoRedirection(
      ref: ref,
      targetType: widget.targetType,
      url: url,
      context: context,
      popToRoot: true,
    );
  }

  Future<void> _handleImageTap() async {
    if (widget.jumpUrl == null) return;
    await handleAdVideoRedirection(
      ref: ref,
      targetType: widget.targetType,
      url: widget.jumpUrl,
      context: context,
      popToRoot: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _canClose,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: AbsorbPointer(
          absorbing: false,
          child: Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  onTap: () {},
                  child: Container(color: Colors.black54),
                ),
              ),

              Positioned.fill(
                child: Container(
                  color: Colors.black,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: GestureDetector(
                          onTap: _handleImageTap,
                          child: EncryptedImage(
                            url: widget.coverImageUrl,
                            fit: BoxFit.contain,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        ),
                      ),

                      Positioned(
                        top: MediaQuery.of(context).padding.top + 16,
                        right: 16,
                        child: GestureDetector(
                          onTap: _finishAd,
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: _canClose
                                ? const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 20,
                                  )
                                : Center(
                                    child: Text(
                                      '$_remainingSeconds',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                      ),

                      if (widget.jumpUrl != null || widget.claimUrl != null)
                        Positioned(
                          bottom: MediaQuery.of(context).padding.bottom + 24,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: GestureDetector(
                              onTap: _handleCta,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 40,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.yellow,
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: Text(
                                  'Click',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.red[900],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
