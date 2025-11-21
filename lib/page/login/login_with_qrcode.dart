import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:live_app/l10n/app_localizations.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../provider/api_provider.dart';
import '../../utils/toast_util.dart';
import '../home.dart';

class LoginWithQrcodePage extends ConsumerStatefulWidget {
  const LoginWithQrcodePage({super.key});

  @override
  ConsumerState<LoginWithQrcodePage> createState() =>
      _LoginWithQrcodePageState();
}

class _LoginWithQrcodePageState extends ConsumerState<LoginWithQrcodePage> {
  final MobileScannerController _controller = MobileScannerController();
  bool isFlashOn = false;
  bool _isProcessing = false; // 防止重复触发扫码

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loginWithQRCode(String code, BuildContext context) async {
    final localizations = AppLocalizations.of(context)!;
    if (code.isEmpty) {
      ToastUtil.warning(localizations.scanFailed);
      return;
    }

    final userService = ref.read(userServiceProvider);

    try {
      await userService.loginByCredential(code);
      ToastUtil.success(localizations.loginSuccess);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const HomePage()),
            (route) => false, // false 表示移除所有旧页面
          );
        }
      });
    } catch (err, stack) {
      debugPrint("登录出错: $err");
      debugPrintStack(stackTrace: stack);
    }
  }

  Future<void> _uploadQRCode(BuildContext context) async {
    final localizations = AppLocalizations.of(context)!;
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    try {
      final result = await _controller.analyzeImage(image.path);
      if (result != null && result.barcodes.isNotEmpty) {
        final code = result.barcodes.first.rawValue ?? "";
        // ignore: use_build_context_synchronously
        await _loginWithQRCode(code, context);
        if (!mounted) return;
      } else {
        if (!mounted) return;
        ToastUtil.error(localizations.qrcodeNotRecognized);
      }
    } catch (e) {
      if (!mounted) return;
      ToastUtil.error(localizations.qrcodeParseFailed);
    }
  }

  void _toggleFlash() async {
    await _controller.toggleTorch();
    setState(() {
      isFlashOn = !isFlashOn;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: theme.colorScheme.primary,
      appBar: AppBar(title: const Text(""), centerTitle: true),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              localizations.loginWithQrcode,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          Center(
            child: SizedBox(
              height: 250,
              width: 250,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  children: [
                    // 相机取景
                    MobileScanner(
                      controller: _controller,
                      fit: BoxFit.cover,
                      onDetect: (capture) {
                        if (_isProcessing) return;
                        _isProcessing = true;

                        final List<Barcode> barcodes = capture.barcodes;
                        if (barcodes.isNotEmpty) {
                          final code = barcodes.first.rawValue ?? "";
                          _loginWithQRCode(code, context);
                        }
                      },
                    ),

                    // 遮罩层 + 扫描框
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final size = constraints.maxWidth * 0.8; // 扫描框宽度，正方形
                        final left = (constraints.maxWidth - size) / 2;
                        final top = (constraints.maxHeight - size) / 2;

                        return Stack(
                          children: [
                            // 镂空区域 + 圆角边框
                            Positioned(
                              left: left,
                              top: top,
                              child: Container(
                                color: Colors.transparent,
                                width: size,
                                height: size,
                                child: CustomPaint(
                                  painter: _CornerPainter(
                                    color: theme.colorScheme.secondary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                minimumSize: const Size(180, 48),
              ),
              onPressed: _toggleFlash,
              icon: Icon(isFlashOn ? Icons.flash_on : Icons.flash_off),
              label: Text(
                isFlashOn ? localizations.flashOff : localizations.flashOn,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () {
                _uploadQRCode(context);
              },
              icon: const Icon(Icons.upload_file),
              label: Text(
                localizations.uploadQrcode,
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  final Color color;

  _CornerPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const cornerLength = 28.0;
    const radius = 12.0;

    // 左上角
    final path1 = Path()
      ..moveTo(0, radius)
      ..arcToPoint(Offset(radius, 0), radius: const Radius.circular(radius))
      ..lineTo(cornerLength, 0);
    final path2 = Path()
      ..moveTo(0, radius)
      ..lineTo(0, cornerLength);
    canvas.drawPath(path1, paint);
    canvas.drawPath(path2, paint);

    // 右上角
    final path3 = Path()
      ..moveTo(size.width - cornerLength, 0)
      ..lineTo(size.width - radius, 0)
      ..arcToPoint(
        Offset(size.width, radius),
        radius: const Radius.circular(radius),
      );
    final path4 = Path()
      ..moveTo(size.width, radius)
      ..lineTo(size.width, cornerLength);
    canvas.drawPath(path3, paint);
    canvas.drawPath(path4, paint);

    // 左下角
    final path5 = Path()
      ..moveTo(0, size.height - cornerLength)
      ..lineTo(0, size.height - radius)
      ..arcToPoint(
        Offset(radius, size.height),
        radius: const Radius.circular(radius),
        clockwise: false,
      );
    final path6 = Path()
      ..moveTo(radius, size.height)
      ..lineTo(cornerLength, size.height);
    canvas.drawPath(path5, paint);
    canvas.drawPath(path6, paint);

    // 右下角
    final path7 = Path()
      ..moveTo(size.width - cornerLength, size.height)
      ..lineTo(size.width - radius, size.height)
      ..arcToPoint(
        Offset(size.width, size.height - radius),
        radius: const Radius.circular(radius),
        clockwise: false,
      );
    final path8 = Path()
      ..moveTo(size.width, size.height - radius)
      ..lineTo(size.width, size.height - cornerLength);
    canvas.drawPath(path7, paint);
    canvas.drawPath(path8, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
