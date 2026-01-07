import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/api/api_client.dart';
import 'package:live_app/config/cache_manager.dart';

import '../repository/image_repository.dart';
import '../utils/utils.dart';

class EncryptedImage extends ConsumerStatefulWidget {
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
  ConsumerState<EncryptedImage> createState() => _EncryptedImageState();
}

class _EncryptedImageState extends ConsumerState<EncryptedImage> {
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
      final imageRepo = ref.read(imageRepositoryProvider);

      final bytes = await imageRepo.getImageBytes(widget.url);

      if (bytes != null) {
        if (!mounted) return;
        setState(() {
          _imageData = bytes;
          _loading = false;
        });
        return;
      }

      final isEncrypted = widget.url.toLowerCase().endsWith('.pdf');

      if (!isEncrypted) {
        if (!mounted) return;
        setState(() {
          _loading = false;
        });
        imageRepo.enqueueDownload(widget.url);
      } else {
        await imageRepo.downloadAndCacheImage(widget.url);
        final freshBytes = await imageRepo.getImageBytes(widget.url);

        if (!mounted) return;
        setState(() {
          _imageData = freshBytes;
          _loading = false;
        });
      }
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
      final child =
          widget.placeholder ??
          const Center(child: CircularProgressIndicator());

      if (widget.width != null || widget.height != null) {
        return SizedBox(
          width: widget.width,
          height: widget.height,
          child: child,
        );
      }
      return child;
    }

    if (_error) {
      final errorWidget =
          widget.errorWidget ??
          const Icon(Icons.broken_image, color: Colors.grey);

      if (widget.width != null || widget.height != null) {
        return SizedBox(
          width: widget.width,
          height: widget.height,
          child: Center(child: errorWidget),
        );
      }
      return errorWidget;
    }

    if (_imageData != null) {
      return Image.memory(
        _imageData!,
        fit: widget.fit,
        width: widget.width,
        height: widget.height,
      );
    }

    return Image.network(
      widget.url,
      fit: widget.fit,
      width: widget.width,
      height: widget.height,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        final loader =
            widget.placeholder ??
            const Center(child: CircularProgressIndicator(strokeWidth: 2));
        return (widget.width != null || widget.height != null)
            ? SizedBox(
                width: widget.width,
                height: widget.height,
                child: loader,
              )
            : loader;
      },
      errorBuilder: (context, error, stackTrace) {
        return widget.errorWidget ??
            const Icon(Icons.broken_image, color: Colors.grey);
      },
    );
  }
}

class UserAvatar extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final hasAvatar = url != null && url!.isNotEmpty;
    final displayChar = (nickname != null && nickname!.isNotEmpty)
        ? nickname![0]
        : "?";

    return GestureDetector(
      onTap:
          onTap ??
          () => toUserDetailPage(
            context: context,
            ref: ref,
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
