/*
原始二维码页面实现（按需求注释保留）：
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:live_app/provider/i18n_provider.dart';
import 'package:live_app/utils/toast_util.dart';
import 'package:live_app/widgets/auto_scroll_elevated_button.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

import '../config/storage_config.dart';
import '../models/userinfo.dart';
import '../provider/api_provider.dart';

class QRCodePage extends ConsumerStatefulWidget {
  const QRCodePage({super.key});

  @override
  ConsumerState<QRCodePage> createState() => _QRCodePageState();
}

class _QRCodePageState extends ConsumerState<QRCodePage> {
  UserInfo? _userInfo;
  final GlobalKey globalKey = GlobalKey();
  bool _showContent = false;

  String get _maskedContent {
    final text = _userInfo?.credential?.toString() ?? "";
    return _showContent ? text : "●" * 10;
  }

  @override
  void initState() {
    super.initState();
    getUserInfo();
  }

  Future<void> getUserInfo() async {
    final userService = ref.read(userServiceProvider);
    var userInfo = await userService.getInfo();
    StorageService.instance.setValue("user_info", jsonEncode(userInfo.data));
    getUserFromCache();
  }

  Future<void> getUserFromCache() async {
    final data = await StorageService.instance.getValue("user_info");
    if (data != null) {
      final map = data is String ? jsonDecode(data) : data;
      setState(() {
        _userInfo = UserInfo.fromJson(map);
      });
    }
  }

  /// 保存二维码到相册（使用 gallery_saver_plus）
  Future<void> _saveQRCode() async {
    final i18n = ref.read(i18nNotifierProvider.notifier);

    try {
      setState(() => _showContent = true);
      await Future.delayed(const Duration(milliseconds: 50));
      final boundary =
          globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List pngBytes = byteData!.buffer.asUint8List();

      final directory = await getTemporaryDirectory();
      final filePath =
          '${directory.path}/qrcode_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File(filePath);
      await file.writeAsBytes(pngBytes);

      final bool? success = await GallerySaver.saveImage(file.path);

      if (success == true) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(i18n.translate('qrCodeSaved'))));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(i18n.translate('qrCodeSaveFailed'))),
        );
      }
      setState(() => _showContent = false);
    } catch (e) {
      debugPrint(e.toString());
      ToastUtil.error("保存失败: $e");
      setState(() => _showContent = false);
    }
  }

  /// 复制二维码内容
  void _copyText() {
    if (_userInfo == null) return;
    final i18n = ref.read(i18nNotifierProvider.notifier);
    Clipboard.setData(ClipboardData(text: _userInfo!.credential.toString()));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(i18n.translate('contentCopied'))));
  }

  @override
  Widget build(BuildContext context) {
    final qrData = _userInfo?.credential.toString() ?? "";
    final i18n = ref.read(i18nNotifierProvider.notifier);
    String translate(String key) => i18n.translate(key);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(translate("myCredentials")),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 100),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            RepaintBoundary(
              key: globalKey,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final double qrSize = constraints.maxWidth * 0.5;

                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            color: Colors.white,
                            width: qrSize,
                            height: qrSize,
                            child: PrettyQrView.data(
                              data: qrData,
                              errorCorrectLevel: QrErrorCorrectLevel.M,
                              decoration: const PrettyQrDecoration(
                                shape: PrettyQrSmoothSymbol(),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                          ),
                          icon: Icon(
                            _showContent
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.black,
                          ),
                          label: Text(
                            _showContent
                                ? (_userInfo?.credential?.toString() ?? "")
                                : _maskedContent,
                            style: const TextStyle(color: Colors.black),
                          ),
                          onPressed: () {
                            // setState(() {
                            //   _showContent =
                            //       !_showContent;
                            // });
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 70),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AutoScrollButton(
                  text: translate("copyLoginCredentials"),
                  onPressed: _copyText,
                  icon: Icons.copy,
                ),
                const SizedBox(width: 20),
                kIsWeb
                    ? const SizedBox()
                    : AutoScrollButton(
                        text: translate("saveLoginCredentials"),
                        onPressed: _saveQRCode,
                        icon: Icons.save,
                      ),
              ],
            ),
            if (kIsWeb) ...[
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const ui.Color.fromARGB(
                      255,
                      0,
                      0,
                      0,
                    ).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const ui.Color.fromARGB(255, 255, 255, 255),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const ui.Color.fromARGB(
                            255,
                            255,
                            255,
                            255,
                          ).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.info_outline_rounded,
                          color: ui.Color.fromARGB(255, 255, 255, 255),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          translate("screenshotHint"),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
*/

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class QRCodePage extends ConsumerStatefulWidget {
  const QRCodePage({super.key});

  @override
  ConsumerState<QRCodePage> createState() => _QRCodePageState();
}

class _QRCodePageState extends ConsumerState<QRCodePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text(''), backgroundColor: Colors.black),
      body: const Center(
        child: Text('二维码功能已停用', style: TextStyle(color: Colors.white70)),
      ),
    );
  }
}
