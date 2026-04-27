import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../services/web_image_worker_client_stub.dart'
    if (dart.library.html) '../services/web_image_worker_client_web.dart'
    as web_image_worker;
import '../repository/image_repository.dart';
import '../models/vip.dart';
import '../utils/text_util.dart';
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
  String? _webImageUrl;
  String? _webSvgText;
  bool _isSvg = false;
  bool _loading = true;
  bool _error = false;
  int _requestVersion = 0;

  bool _isSvgUrl(String url) {
    final lower = url.toLowerCase();
    return lower.endsWith('.svg.enc') ||
        lower.endsWith('.svg.pdf') ||
        lower.endsWith('.svg');
  }

  bool _isSvgBytes(Uint8List? bytes) {
    if (bytes == null || bytes.length < 5) return false;
    final header = String.fromCharCodes(bytes.take(256));
    return header.trimLeft().startsWith('<svg') ||
        header.trimLeft().startsWith('<?xml');
  }

  @override
  void initState() {
    super.initState();
    _resetStateForCurrentWidget();
  }

  @override
  void didUpdateWidget(covariant EncryptedImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url == widget.url &&
        oldWidget.width == widget.width &&
        oldWidget.height == widget.height &&
        oldWidget.fit == widget.fit) {
      return;
    }

    _resetStateForCurrentWidget();
  }

  void _resetStateForCurrentWidget() {
    _imageData = null;
    _webImageUrl = null;
    _webSvgText = null;
    _isSvg = false;
    _loading = true;
    _error = false;
    _requestVersion++;

    _primeFromCaches();
    if (_loading) {
      _loadImage(requestVersion: _requestVersion);
    }
  }

  void _primeFromCaches() {
    if (widget.url.isEmpty) {
      _loading = false;
      _error = true;
      return;
    }

    final fileType = getImageFileType(widget.url);
    if (fileType == null) {
      _loading = false;
      _error = true;
      return;
    }

    if (_hydrateFromWebCaches(targetWidth: _webTargetWidthPx())) {
      _loading = false;
      return;
    }

    final imageRepo = ref.read(imageRepositoryProvider);
    final cachedBytes = imageRepo.getMemoryCachedBytes(widget.url);
    if (cachedBytes == null) {
      return;
    }

    _imageData = cachedBytes;
    _isSvg = _isSvgUrl(widget.url) || _isSvgBytes(cachedBytes);
    _loading = false;
  }

  bool _hydrateFromWebCaches({int? targetWidth}) {
    if (!kIsWeb || !web_image_worker.supportsWebImageWorker) {
      return false;
    }

    final encryptionKey = dotenv.env['ENCRYPTION_KEY'] ?? '';
    if (encryptionKey.isEmpty) {
      return false;
    }

    final cachedDisplay = web_image_worker.getCachedWebImageDisplay(
      url: widget.url,
      encryptionKey: encryptionKey,
      targetWidth: targetWidth,
    );
    if (cachedDisplay == null) {
      return false;
    }

    _webImageUrl = cachedDisplay.objectUrl;
    _webSvgText = cachedDisplay.svgText;
    _isSvg = cachedDisplay.isSvg;
    return true;
  }

  double _platformDevicePixelRatio() {
    final view =
        WidgetsBinding.instance.platformDispatcher.implicitView ??
        (WidgetsBinding.instance.platformDispatcher.views.isNotEmpty
            ? WidgetsBinding.instance.platformDispatcher.views.first
            : null);
    return view?.devicePixelRatio ?? 1.0;
  }

  double? _platformLogicalWidth() {
    final view =
        WidgetsBinding.instance.platformDispatcher.implicitView ??
        (WidgetsBinding.instance.platformDispatcher.views.isNotEmpty
            ? WidgetsBinding.instance.platformDispatcher.views.first
            : null);
    if (view == null) {
      return null;
    }

    final dpr = view.devicePixelRatio;
    if (dpr <= 0) {
      return null;
    }

    final logicalWidth = view.physicalSize.width / dpr;
    if (!logicalWidth.isFinite || logicalWidth <= 0) {
      return null;
    }

    return logicalWidth;
  }

  int? _webTargetWidthPx() {
    if (!kIsWeb || !web_image_worker.supportsWebImageWorker) {
      return null;
    }

    final explicitWidth = widget.width;
    final width =
        explicitWidth != null && explicitWidth.isFinite && explicitWidth > 0
        ? explicitWidth
        : _platformLogicalWidth();
    if (width == null || !width.isFinite || width <= 0) {
      return null;
    }

    final targetWidth = (width * _platformDevicePixelRatio()).round();
    if (targetWidth <= 0) {
      return null;
    }
    return targetWidth;
  }

  String _workerFileType(ImageFileType fileType) {
    switch (fileType) {
      case ImageFileType.enc:
        return 'enc';
      case ImageFileType.pdf:
        return 'pdf';
    }
  }

  Future<bool> _tryLoadImageWithWorker({
    required ImageFileType fileType,
    required int requestVersion,
  }) async {
    if (!kIsWeb || !web_image_worker.supportsWebImageWorker) {
      return false;
    }

    final encryptionKey = dotenv.env['ENCRYPTION_KEY'] ?? '';
    if (encryptionKey.isEmpty) {
      return false;
    }

    try {
      final display = await web_image_worker.loadWebImage(
        url: widget.url,
        fileType: _workerFileType(fileType),
        encryptionKey: encryptionKey,
        targetWidth: _webTargetWidthPx(),
      );
      if (display == null) {
        return false;
      }

      if (!mounted || requestVersion != _requestVersion) {
        return true;
      }

      setState(() {
        _imageData = null;
        _webImageUrl = display.objectUrl;
        _webSvgText = display.svgText;
        _isSvg = display.isSvg;
        _loading = false;
        _error = false;
      });
      return true;
    } catch (e, st) {
      debugPrint('Web worker 加载图片失败: $e (URL: ${widget.url})');
      debugPrintStack(stackTrace: st, maxFrames: 6);
      return false;
    }
  }

  Future<void> _loadImage({required int requestVersion}) async {
    if (widget.url.isEmpty) {
      if (!mounted || requestVersion != _requestVersion) return;
      setState(() {
        _loading = false;
        _error = true;
      });
      return;
    }

    final fileType = getImageFileType(widget.url);
    if (fileType == null) {
      if (!mounted || requestVersion != _requestVersion) return;
      setState(() {
        _loading = false;
        _error = true;
      });
      return;
    }

    try {
      final loadedFromWorker = await _tryLoadImageWithWorker(
        fileType: fileType,
        requestVersion: requestVersion,
      );
      if (loadedFromWorker) {
        return;
      }

      final imageRepo = ref.read(imageRepositoryProvider);
      final imageBytes = await imageRepo.getImageBytes(widget.url);
      if (!mounted || requestVersion != _requestVersion) return;

      setState(() {
        _imageData = imageBytes;
        _webImageUrl = null;
        _webSvgText = null;
        _isSvg = _isSvgUrl(widget.url) || _isSvgBytes(imageBytes);
        _loading = false;
        _error = false;
      });
    } catch (e, st) {
      if (e is DioException && e.response?.statusCode == 404) {
        debugPrint("图片不存在 (404): ${widget.url}");
      } else {
        debugPrint("加载图片失败: $e (URL: ${widget.url})");
        debugPrintStack(stackTrace: st);
      }

      if (!mounted || requestVersion != _requestVersion) return;

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

    if (_webSvgText != null) {
      return SvgPicture.string(
        _webSvgText!,
        fit: widget.fit,
        width: widget.width,
        height: widget.height,
      );
    }

    if (_webImageUrl != null) {
      return Image.network(
        _webImageUrl!,
        fit: widget.fit,
        width: widget.width,
        height: widget.height,
        filterQuality: FilterQuality.low,
        gaplessPlayback: true,
        errorBuilder: (context, error, stackTrace) {
          return widget.errorWidget ??
              const Icon(Icons.broken_image, color: Colors.grey);
        },
      );
    }

    if (_imageData != null) {
      if (_isSvg) {
        return SvgPicture.memory(
          _imageData!,
          fit: widget.fit,
          width: widget.width,
          height: widget.height,
        );
      }
      return Image.memory(
        _imageData!,
        fit: widget.fit,
        width: widget.width,
        height: widget.height,
        filterQuality: FilterQuality.low,
      );
    }

    return Image.network(
      widget.url,
      fit: widget.fit,
      width: widget.width,
      height: widget.height,
      filterQuality: FilterQuality.low,
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
  final String? userId;
  final Vip? vip;
  final double size;
  final VoidCallback? onTap;

  const UserAvatar({
    super.key,
    this.userId,
    this.url,
    this.nickname,
    this.vip,
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
            vip: vip,
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
                    child: const SizedBox.expand(),
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
