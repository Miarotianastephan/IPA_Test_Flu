import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/models/game_reduction_model.dart';
import 'package:live_app/provider/i18n_provider.dart';
import 'package:live_app/widgets/encrypted_image.dart';

class PromotionDialog extends ConsumerStatefulWidget {
  final VoidCallback onClose;
  final VoidCallback onCta;
  final GameReductionData reductionData;

  const PromotionDialog({
    super.key,
    required this.onClose,
    required this.onCta,
    required this.reductionData,
  });

  @override
  ConsumerState<PromotionDialog> createState() => _PromotionDialogState();
}

class _PromotionDialogState extends ConsumerState<PromotionDialog> {
  bool _canClose = false;
  int _remainingSeconds = 5;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
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

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardSize = screenWidth * 0.85;

    final i18n = ref.read(i18nNotifierProvider.notifier);
    String translate(String key) => i18n.translate(key);

    return PopScope(
      canPop: _canClose,
      child: Material(
        color: Colors.transparent,
        child: Center(
          child: SizedBox(
            width: cardSize,
            height: cardSize,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    width: cardSize,
                    height: cardSize,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        EncryptedImage(
                          url: widget.reductionData.icon ?? "",
                          placeholder: Container(
                            width: cardSize,
                            height: cardSize,
                            color: Colors.grey[300],
                          ),
                          errorWidget: Image.asset(
                            'lib/assets/promo.png',
                            width: cardSize,
                            height: cardSize,
                            fit: BoxFit.contain,
                          ),
                          fit: BoxFit.contain,
                          width: cardSize,
                          height: cardSize,
                        ),
                        Positioned(
                          bottom: 40,
                          left: 20,
                          right: 20,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.reductionData.title ?? "",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red[900],
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                widget.reductionData.description ?? "",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: Colors.yellow,
                                  height: 1.3,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 16),
                              GestureDetector(
                                onTap: widget.onCta,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: 20,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.yellow,
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: Text(
                                    translate('tryNow'),
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.red[900],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: -10,
                  right: -10,
                  child: GestureDetector(
                    onTap: _canClose ? widget.onClose : null,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: _canClose
                            ? Colors.white.withValues(alpha: 0.9)
                            : Colors.white.withValues(alpha: 0.7),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: _canClose
                            ? const Icon(
                                Icons.close,
                                size: 18,
                                color: Color(0xFFF87171),
                              )
                            : Text(
                                '$_remainingSeconds',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFF87171),
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
      ),
    );
  }
}
