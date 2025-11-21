import 'dart:io' as io;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../api/api_client.dart';
import '../config/cache_manager.dart';
import '../utils/utils.dart';

class EncryptedImage extends StatefulWidget {
  final String url;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget? placeholder;
  final Widget? errorWidget;

  const EncryptedImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.placeholder,
    this.errorWidget,
  });

  @override
  State<EncryptedImage> createState() => _EncryptedImageState();
}

class _EncryptedImageState extends State<EncryptedImage> {
  Uint8List? _imageData;
  bool _loading = true;
  bool _error = false;

  final _apiClient = ApiClient();
  final _cacheManager = UniversalCacheManager();

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  /// 内置解密逻辑（仅针对 `.pdf` 加密图片示例）
  Future<Uint8List> _decrypt(Uint8List data) async {
    final decrypted = data.map((b) => b ^ 0xFF).toList();
    return Uint8List.fromList(decrypted);
  }

  Future<void> _loadImage() async {
    try {
      Uint8List bytes;

      // === 尝试读取缓存 ===
      io.File? cachedFile = await _cacheManager.getFile(
        widget.url,
        manager: _cacheManager.customCacheManager(key: "images_cache"),
      );

      if (!mounted) return;

      if (cachedFile != null) {
        bytes = await cachedFile.readAsBytes();
      } else {
        // === 下载 ===
        final downloaded = await _apiClient.downloadFile(
          widget.url,
          save: false,
        );

        if (!mounted) return;

        if (kIsWeb) {
          bytes = downloaded as Uint8List;
        } else {
          final file = downloaded as io.File;
          bytes = await file.readAsBytes();
        }

        // === PDF 解密 ===
        if (widget.url.toLowerCase().endsWith(".pdf")) {
          bytes = await _decrypt(bytes);
          if (!mounted) return;
        }

        // === 写入缓存 ===
        final tempFile = await _cacheManager.getFile(
          widget.url,
          manager: _cacheManager.customCacheManager(key: "images_cache"),
        );

        if (tempFile != null) {
          await tempFile.writeAsBytes(bytes);
        }
      }

      if (!mounted) return;

      setState(() {
        _imageData = bytes;
        _loading = false;
      });
    } catch (e, st) {
      debugPrint("加载图片失败: $e");
      debugPrintStack(stackTrace: st);

      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return widget.placeholder ??
          const Center(child: CircularProgressIndicator());
    }

    if (_error) {
      return widget.errorWidget ??
          const Center(child: Icon(Icons.broken_image, color: Colors.grey));
    }

    if (_imageData != null) {
      return Image.memory(
        _imageData!,
        fit: widget.fit,
        width: widget.width,
        height: widget.height,
      );
    }

    return widget.errorWidget ??
        const Center(child: Icon(Icons.broken_image, color: Colors.grey));
  }
}

class UserAvatar extends StatelessWidget {
  final String? url;
  final String? nickname;
  final int? userId;
  final double size;
  final VoidCallback? onTap;

  const UserAvatar({
    super.key,
    this.userId,
    this.url,
    this.nickname,
    this.size = 40.0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasAvatar = url != null && url!.isNotEmpty;
    final displayChar = (nickname != null && nickname!.isNotEmpty)
        ? nickname![0]
        : "?";

    return GestureDetector(
      onTap:
          onTap ??
          () => toUserDetailPage(
            context: context,
            userId: userId,
            url: url,
            nickname: nickname,
          ),
      child: CircleAvatar(
        radius: size / 2,
        backgroundColor: hasAvatar ? Colors.transparent : Colors.grey[300],
        child: hasAvatar
            ? ClipOval(
                child: EncryptedImage(
                  url: url!,
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                  placeholder: Container(
                    color: Colors.grey[300],
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: Container(
                    color: Colors.grey[300],
                    child: const Center(child: Icon(Icons.person_off)),
                  ),
                ),
              )
            : Text(
                displayChar,
                style: TextStyle(
                  fontSize: size / 2,
                  color: Theme.of(context).colorScheme.onSecondary,
                ),
              ),
      ),
    );
  }
}
