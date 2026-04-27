import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/models/notif_chinese.dart';
import 'package:live_app/provider/i18n_provider.dart';
import 'package:live_app/widgets/encrypted_image.dart';
import 'package:url_launcher/url_launcher.dart';

class ChinesePromotionDialog extends ConsumerStatefulWidget {
  final VoidCallback onClose;
  final NotifChinese notifChinese;

  const ChinesePromotionDialog({
    super.key,
    required this.onClose,
    required this.notifChinese,
  });

  @override
  ConsumerState<ChinesePromotionDialog> createState() =>
      _PromotionDialogState();
}

class _PromotionDialogState extends ConsumerState<ChinesePromotionDialog> {
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

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth = screenWidth * 0.85;
    final notif = widget.notifChinese;
    final i18n = ref.read(i18nNotifierProvider.notifier);
    String translate(String key) => i18n.translate(key);

    return PopScope(
      canPop: _canClose,
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: dialogWidth),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Container(
                width: dialogWidth,
                margin: const EdgeInsets.only(top: 35),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.only(top: 10, bottom: 12),
                      child: Text(
                        notif.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      child: Text(
                        notif.body.join('\n'),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          height: 1.6,
                        ),
                      ),
                    ),
                    if (notif.linkList.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: notif.linkList.map((linkItem) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${linkItem.text}: ',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => _launchUrl(linkItem.link),
                                      child: Text(
                                        linkItem.link,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF64B5F6),
                                          decoration: TextDecoration.underline,
                                          decorationColor: Color(0xFF64B5F6),
                                        ),
                                        softWrap: true,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 20,
                        right: 20,
                        bottom: 20,
                        top: 8,
                      ),
                      child: GestureDetector(
                        onTap: _canClose ? widget.onClose : null,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2A2A2A),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.grey.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            _canClose
                                ? translate('close')
                                : '${translate('close')} ($_remainingSeconds)',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 0,
                left: dialogWidth / 4 - 40,
                child: EncryptedImage(
                  url:
                      "https://lldvod.xosp.tv/images/1089e43bf79d0c808dd8149f6b164afd9d2f47c5ae2f54d00f4e686cbe01df83.png.enc",
                  height: 80,
                  width: 80,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
