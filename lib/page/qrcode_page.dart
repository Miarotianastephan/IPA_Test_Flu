import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("二维码已保存到相册")));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("保存失败，请检查相册权限")));
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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("内容已复制")));
  }

  @override
  Widget build(BuildContext context) {
    final qrData = _userInfo?.credential.toString() ?? "";

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text("我的凭证"), backgroundColor: Colors.black),
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
                          onPressed: () {},
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
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                  ),
                  icon: const Icon(Icons.copy, color: Colors.black),
                  label: const Text(
                    "复制登录凭证",
                    style: TextStyle(color: Colors.black),
                  ),
                  onPressed: _copyText,
                ),
                const SizedBox(width: 30),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                  ),
                  icon: const Icon(Icons.save, color: Colors.black),
                  label: const Text(
                    "保存登录凭证",
                    style: TextStyle(color: Colors.black),
                  ),
                  onPressed: _saveQRCode,
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
