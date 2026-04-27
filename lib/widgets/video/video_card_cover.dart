import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../repository/image_repository.dart';
import '../../utils/text_util.dart';
import '../encrypted_image.dart';

const double _videoCardCoverFallbackAspectRatio = 0.75;
const double _videoCardCoverPortraitAspectRatio = 9 / 16;
const double _videoCardCoverLandscapeAspectRatio = 16 / 9;

Future<void> warmVideoCardCovers(WidgetRef ref, Iterable<String> urls) async {
  final imageRepo = ref.read(imageRepositoryProvider);
  final pendingUrls = urls
      .where((url) => url.isNotEmpty && isValidUrl(url))
      .toSet();

  for (final url in pendingUrls) {
    imageRepo.enqueueWarmLayout(url);
  }
}

class VideoCardCover extends ConsumerStatefulWidget {
  final String url;
  final int videoType;
  final BoxFit fit;
  final bool enabled;
  final bool paintImageAfterLoad;
  final double? fixedAspectRatio;
  final bool useContentConstraintsForImage;
  final Widget? placeholder;
  final Widget? errorWidget;

  const VideoCardCover({
    super.key,
    required this.url,
    required this.videoType,
    this.fit = BoxFit.cover,
    this.enabled = true,
    this.paintImageAfterLoad = true,
    this.fixedAspectRatio,
    this.useContentConstraintsForImage = false,
    this.placeholder,
    this.errorWidget,
  });

  @override
  ConsumerState<VideoCardCover> createState() => _VideoCardCoverState();
}

class _VideoCardCoverState extends ConsumerState<VideoCardCover> {
  ImageLayoutInfo? _layout;
  bool _error = false;
  bool _layoutLoading = false;
  int _requestVersion = 0;

  @override
  void initState() {
    super.initState();
    _resetStateForCurrentWidget();
  }

  @override
  void didUpdateWidget(covariant VideoCardCover oldWidget) {
    super.didUpdateWidget(oldWidget);
    final sourceChanged =
        oldWidget.url != widget.url || oldWidget.videoType != widget.videoType;
    final behaviorChanged =
        oldWidget.enabled != widget.enabled ||
        oldWidget.paintImageAfterLoad != widget.paintImageAfterLoad ||
        oldWidget.fixedAspectRatio != widget.fixedAspectRatio ||
        oldWidget.useContentConstraintsForImage !=
            widget.useContentConstraintsForImage;

    if (!sourceChanged && !behaviorChanged) {
      return;
    }

    if (sourceChanged ||
        oldWidget.fixedAspectRatio != widget.fixedAspectRatio) {
      _resetStateForCurrentWidget();
      return;
    }

    if (!oldWidget.enabled && widget.enabled) {
      _primeLayout();
    }
  }

  void _resetStateForCurrentWidget() {
    final imageRepo = ref.read(imageRepositoryProvider);
    _layout = imageRepo.getCachedImageLayout(widget.url);
    _error = false;
    _layoutLoading = false;
    _requestVersion++;

    if (widget.enabled) {
      _primeLayout();
    }
  }

  void _primeLayout() {
    if (!widget.enabled) {
      return;
    }

    if (widget.fixedAspectRatio != null && widget.fixedAspectRatio! > 0) {
      return;
    }

    if (widget.url.isEmpty || !isValidUrl(widget.url)) {
      if (!mounted) {
        return;
      }

      setState(() {
        _error = true;
      });
      return;
    }

    if (_layout != null || _layoutLoading) {
      return;
    }

    _layoutLoading = true;
    _loadLayout(_requestVersion);
  }

  Future<void> _loadLayout(int requestVersion) async {
    try {
      final layout = await ref
          .read(imageRepositoryProvider)
          .getImageLayout(widget.url);
      if (!mounted || requestVersion != _requestVersion) {
        return;
      }

      setState(() {
        _layout = layout;
        _layoutLoading = false;
        _error = false;
      });
    } catch (e, st) {
      debugPrint('VideoCardCover layout failed: $e, url=${widget.url}');
      debugPrintStack(stackTrace: st, maxFrames: 6);

      if (!mounted || requestVersion != _requestVersion) {
        return;
      }

      setState(() {
        _layoutLoading = false;
        _error = true;
      });
    }
  }

  Widget _buildPlaceholderFill() {
    return widget.placeholder ?? const ColoredBox(color: Colors.black);
  }

  Widget _buildErrorFill() {
    return widget.errorWidget ??
        const Center(child: Icon(Icons.broken_image, color: Colors.grey));
  }

  double _defaultAspectRatioForVideoType() {
    return widget.videoType == 1
        ? _videoCardCoverPortraitAspectRatio
        : _videoCardCoverLandscapeAspectRatio;
  }

  Widget _buildAspectRatioShell(double aspectRatio, Widget child) {
    final safeAspectRatio = aspectRatio > 0
        ? aspectRatio
        : _defaultAspectRatioForVideoType();

    return AspectRatio(aspectRatio: safeAspectRatio, child: child);
  }

  Widget _buildAspectRatioContent(double aspectRatio) {
    final safeAspectRatio = aspectRatio > 0
        ? aspectRatio
        : _videoCardCoverFallbackAspectRatio;
    final image = EncryptedImage(
      url: widget.url,
      fit: widget.fit,
      placeholder: SizedBox.expand(child: _buildPlaceholderFill()),
      errorWidget: _buildErrorFill(),
    );
    final constrainedImage = widget.useContentConstraintsForImage
        ? LayoutBuilder(
            builder: (context, constraints) {
              final width =
                  constraints.maxWidth.isFinite && constraints.maxWidth > 0
                  ? constraints.maxWidth
                  : null;
              final height =
                  constraints.maxHeight.isFinite && constraints.maxHeight > 0
                  ? constraints.maxHeight
                  : null;

              return EncryptedImage(
                url: widget.url,
                width: width,
                height: height,
                fit: widget.fit,
                placeholder: SizedBox.expand(child: _buildPlaceholderFill()),
                errorWidget: _buildErrorFill(),
              );
            },
          )
        : image;

    return _buildAspectRatioShell(
      safeAspectRatio,
      widget.enabled && widget.paintImageAfterLoad
          ? constrainedImage
          : SizedBox.expand(child: _buildPlaceholderFill()),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.fixedAspectRatio != null && widget.fixedAspectRatio! > 0) {
      return _buildAspectRatioContent(widget.fixedAspectRatio!);
    }

    final defaultAspectRatio = _defaultAspectRatioForVideoType();

    if (_layout == null) {
      if (_error) {
        return _buildAspectRatioShell(
          defaultAspectRatio,
          SizedBox.expand(child: _buildErrorFill()),
        );
      }

      if (widget.enabled && !_layoutLoading) {
        _primeLayout();
      }

      return _buildAspectRatioShell(
        defaultAspectRatio,
        SizedBox.expand(child: _buildPlaceholderFill()),
      );
    }

    return _buildAspectRatioContent(_layout!.aspectRatio);
  }
}
