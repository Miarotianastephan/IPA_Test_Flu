import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:live_app/l10n/app_localizations.dart';
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.qrCodeSaved)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.qrCodeSaveFailed),
          ),
        );
      }
      setState(() => _showContent = false);
    } catch (e) {
      debugPrint(e.toString());

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("保存失败: $e")));
      setState(() => _showContent = false);
    }
  }

  /// 复制二维码内容
  void _copyText() {
    if (_userInfo == null) return;
    Clipboard.setData(ClipboardData(text: _userInfo!.credential.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.contentCopied)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final qrData = _userInfo?.credential.toString() ?? "";
    final localisations = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(localisations.myCredentials),
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
                  text: localisations.copyLoginCredentials,
                  onPressed: _copyText,
                  icon: Icons.copy,
                ),
                const SizedBox(width: 20),
                AutoScrollButton(
                  text: localisations.saveLoginCredentials,
                  onPressed: _saveQRCode,
                  icon: Icons.save,
                ),
              ],
            ),
          ],
        ),
      ),
      // ),
    );
  }
}
