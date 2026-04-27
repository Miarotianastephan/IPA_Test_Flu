import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';

import '../../models/userinfo.dart';
import '../../provider/i18n_provider.dart';
import '../../utils/toast_util.dart';

class AccountCredentialsDialog extends ConsumerStatefulWidget {
  final UserInfo user;

  const AccountCredentialsDialog({super.key, required this.user});

  @override
  ConsumerState<AccountCredentialsDialog> createState() =>
      _AccountCredentialsDialogState();
}

class _AccountCredentialsDialogState
    extends ConsumerState<AccountCredentialsDialog> {
  final GlobalKey _captureKey = GlobalKey();
  bool _isSaving = false;

  String _translate(String key, {String? fallback}) {
    return ref
        .read(i18nNotifierProvider.notifier)
        .translate(key, fallback: fallback);
  }

  String get _username {
    final value = widget.user.username?.trim() ?? '';
    return value.isEmpty ? '-' : value;
  }

  String get _displayId {
    final value = widget.user.displayId.trim();
    return value.isEmpty ? '-' : value;
  }

  String get _password {
    final value = widget.user.password?.trim() ?? '';
    return value.isEmpty ? '-' : value;
  }

  Future<void> _saveAccountCard() async {
    if (kIsWeb) {
      _showWebScreenshotHintDialog();
      return;
    }

    if (_isSaving) return;
    setState(() {
      _isSaving = true;
    });

    try {
      final boundary =
          _captureKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) {
        ToastUtil.error(
          _translate('saveFailedTryAgainLater', fallback: '保存失败，请稍后重试'),
        );
        return;
      }

      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List pngBytes = byteData!.buffer.asUint8List();

      final directory = await getTemporaryDirectory();
      final filePath =
          '${directory.path}/account_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File(filePath);
      await file.writeAsBytes(pngBytes);

      final success = await GallerySaver.saveImage(file.path);
      if (success == true) {
        ToastUtil.success(
          _translate('accountInfoSavedToAlbum', fallback: '账号信息已保存到相册'),
        );
      } else {
        ToastUtil.error(
          _translate('qrCodeSaveFailed', fallback: '保存失败，请检查相册权限'),
        );
      }
    } catch (_) {
      ToastUtil.error(
        _translate('saveFailedTryAgainLater', fallback: '保存失败，请稍后重试'),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _showWebScreenshotHintDialog() async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 40,
            vertical: 24,
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  color: Colors.white,
                  size: 28,
                ),
                const SizedBox(height: 10),
                Text(
                  _translate('screenshotSaveTitle', fallback: '请截图保存'),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _translate('screenshotHint', fallback: '网页端请手动截图，保存账号信息。'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(42),
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      shape: const StadiumBorder(),
                    ),
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: Text(
                      _translate('ok', fallback: '我知道了'),
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildItem(String label, String value) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: RepaintBoundary(
        key: _captureKey,
        child: Container(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _translate('saveAccountInfoTitle', fallback: '请保存账号信息'),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white70),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                _translate(
                  'saveAccountInfoDescription',
                  fallback: '为避免账号丢失，请及时保存以下账号信息。',
                ),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.75),
                  fontSize: 13,
                ),
              ),
              _buildItem(_translate('username', fallback: '用户名'), _username),
              _buildItem(
                _translate('accountLabel', fallback: '账号'),
                _displayId,
              ),
              _buildItem(_translate('password', fallback: '密码'), _password),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(46),
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: const StadiumBorder(),
                  ),
                  onPressed: _saveAccountCard,
                  child: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          _translate('saveAccountInfoButton', fallback: '保存账号'),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
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
