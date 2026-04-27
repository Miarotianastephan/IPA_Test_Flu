import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/models/ad.dart';
import 'package:live_app/utils/ad_utils.dart';
import 'package:live_app/widgets/ad_badge.dart';
import 'package:live_app/widgets/encrypted_image.dart';

class AdPopup extends ConsumerStatefulWidget {
  final Ad ad;
  final VoidCallback? onClose;
  final VoidCallback? onSkip;

  const AdPopup({super.key, required this.ad, this.onClose, this.onSkip});

  @override
  ConsumerState<AdPopup> createState() => _AdPopupState();

  static Future<void> show(
    BuildContext context, {
    required Ad ad,
    bool barrierDismissible = false,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      builder: (context) => AdPopup(ad: ad),
    );
  }
}

class _AdPopupState extends ConsumerState<AdPopup> {
  Timer? _closeButtonTimer;
  Timer? _skipCountdownTimer;
  bool _canClose = false;
  int _skipCountdown = 0;

  @override
  void initState() {
    super.initState();
    _initializeTimers();
  }

  void _initializeTimers() {
    if (widget.ad.isSkippable) {
      _skipCountdown = widget.ad.skipCountdownSeconds;
      if (_skipCountdown > 0) {
        _skipCountdownTimer = Timer.periodic(const Duration(seconds: 1), (
          timer,
        ) {
          if (!mounted) {
            timer.cancel();
            return;
          }
          setState(() {
            _skipCountdown--;
            if (_skipCountdown <= 0) {
              timer.cancel();
            }
          });
        });
      }
    }

    final closeDelay = widget.ad.closeButtonDelaySeconds;
    if (closeDelay > 0) {
      _closeButtonTimer = Timer(Duration(seconds: closeDelay), () {
        if (mounted) {
          setState(() => _canClose = true);
        }
      });
    } else {
      _canClose = true;
    }
  }

  @override
  void dispose() {
    _closeButtonTimer?.cancel();
    _skipCountdownTimer?.cancel();
    super.dispose();
  }

  void _handleClose() {
    if (!_canClose && widget.ad.isForce) return;

    widget.onClose?.call();
    if (mounted && Navigator.canPop(context)) {
      Navigator.of(context).pop();
    }
  }

  void _handleSkip() {
    if (!widget.ad.isSkippable || _skipCountdown > 0) return;

    widget.onSkip?.call();
    if (mounted && Navigator.canPop(context)) {
      Navigator.of(context).pop();
    }
  }

  void _handleAdTap() {
    onAdRedirection(widget.ad, ref);
    if (mounted && Navigator.canPop(context)) {
      Navigator.of(context).pop();
    }
  }

  String? _getAdImageUrl() {
    return widget.ad.imageLargeUrl ??
        widget.ad.imageMediumUrl ??
        widget.ad.imageSmallUrl;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final maxWidth = size.width * 0.85;
    final maxHeight = size.height * 0.70;

    const aspectRatio = 9 / 16;
    double dialogHeight = maxHeight;
    double dialogWidth = dialogHeight * aspectRatio;

    if (dialogWidth > maxWidth) {
      dialogWidth = maxWidth;
      dialogHeight = dialogWidth / aspectRatio;
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: dialogWidth,
        height: dialogHeight,
        child: Stack(
          children: [
            _buildAdContent(),

            Positioned(
              top: 16,
              left: 16,
              child: AdBadge(
                fontSize: 12,
                horizontalPadding: 10,
                verticalPadding: 4,
                borderRadius: 6,
              ),
            ),

            if (_canClose || !widget.ad.isForce)
              Positioned(top: 12, right: 12, child: _buildCloseButton()),

            if (widget.ad.adTitle != null ||
                widget.ad.adDescription != null ||
                widget.ad.ctaText != null)
              Positioned(bottom: 0, left: 0, right: 0, child: _buildAdInfo()),
          ],
        ),
      ),
    );
  }

  Widget _buildAdContent() {
    return GestureDetector(
      onTap: _handleAdTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 30,
              offset: const Offset(0, 10),
              spreadRadius: 5,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Container(color: Colors.black, child: _buildImageContent()),
        ),
      ),
    );
  }

  Widget _buildImageContent() {
    final imageUrl = _getAdImageUrl();

    if (imageUrl == null) {
      return const Center(
        child: Icon(Icons.image_not_supported, size: 64, color: Colors.white54),
      );
    }

    return EncryptedImage(
      url: imageUrl,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
    );
  }

  Widget _buildCloseButton() {
    final showTimer = widget.ad.isSkippable && _skipCountdown > 0;
    final canActuallyClose = _canClose && !showTimer;

    return AnimatedScale(
      scale: canActuallyClose ? 1.0 : 0.95,
      duration: const Duration(milliseconds: 200),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: canActuallyClose ? _handleClose : null,
              borderRadius: BorderRadius.circular(24),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: showTimer
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: Center(
                          child: Text(
                            '$_skipCountdown',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      )
                    : Icon(
                        Icons.close_rounded,
                        color: canActuallyClose
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.5),
                        size: 24,
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernBadge() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.campaign_rounded, size: 14, color: Colors.white),
              SizedBox(width: 4),
              Text(
                'AD',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdInfo() {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(24),
        bottomRight: Radius.circular(24),
      ),
      child: Container(
        color: Colors.black.withValues(alpha: 0.4),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                Colors.black.withValues(alpha: 0.85),
                Colors.black.withValues(alpha: 0.3),
                Colors.transparent,
              ],
              stops: const [0.0, 0.7, 1.0],
            ),
            border: Border(
              top: BorderSide(
                color: Colors.white.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.ad.adTitle != null)
                Text(
                  widget.ad.adTitle!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                    letterSpacing: -0.5,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              if (widget.ad.adDescription != null) ...[
                const SizedBox(height: 8),
                Text(
                  widget.ad.adDescription!,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 14,
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (widget.ad.ctaText != null) ...[
                const SizedBox(height: 16),
                _buildCtaButton(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCtaButton() {
    return SizedBox(
      width: double.infinity,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [Color(0xFFFFFFFF), Color(0xFFF0F0F0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _handleAdTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.black87,
            shadowColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.ad.ctaText!,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_rounded, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
