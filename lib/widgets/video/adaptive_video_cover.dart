import 'dart:io' as io;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/widgets/encrypted_image.dart';
import '../../repository/image_repository.dart';
import '../../utils/text_util.dart';

class AdaptiveVideoCover extends ConsumerStatefulWidget {
  final String url;
  final int videoType;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  const AdaptiveVideoCover({
    super.key,
    required this.url,
    required this.videoType,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
  });

  @override
  ConsumerState<AdaptiveVideoCover> createState() => _AdaptiveVideoCoverState();
}

class _AdaptiveVideoCoverState extends ConsumerState<AdaptiveVideoCover> {
  static const _minHeightRatio = 0.11;
  static const _type1HeightRatio = 0.28;


  double? _aspectRatio;
  Uint8List? _imageData;
  bool _loading = true;
  bool _error = false;


  @override
  void initState() {
    super.initState();
    if(widget.videoType != 1){
      _loadImageAndCalculateRatio();
    }
  }

  @override
  void dispose() {
    _imageData = null;
    super.dispose();
  }





  Future<void> _loadImageAndCalculateRatio() async {
    final imageRepo = ref.read(imageRepositoryProvider);
    if (!mounted) return;

    if (!isValidUrl(widget.url)) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = true;
        });
      }
      return;
    }

    try {
      final imageCache = await imageRepo.downloadAndCacheImage(widget.url);

      final bytes = imageCache.bytes;
      if (bytes == null) {
        throw StateError('Image bytes is null for url: ${widget.url}');
      }

      final image = await decodeImageFromList(bytes);
      if (!mounted) return;

      final aspectRatio = image.width / image.height;

      if (mounted) {
        setState(() {
          _imageData = bytes;
          _aspectRatio = aspectRatio;
          _loading = false;
        });
      }
    } catch (e, st) {
      debugPrintStack(stackTrace: st, maxFrames: 5);
      if (mounted) {
        setState(() {
          _loading = false;
          _error = true;
        });
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    if (widget.videoType == 1) {
      return SizedBox(
        width: double.infinity,
        height: MediaQuery.of(context).size.height * _type1HeightRatio,
        child: EncryptedImage(
          url: widget.url,
          fit: widget.fit,
          placeholder: widget.placeholder,
          errorWidget: widget.errorWidget,
        ),
      );
    }

    final screenHeight = MediaQuery.of(context).size.height;
    final minHeight = screenHeight * _minHeightRatio;

    if (_loading) {
      return SizedBox(
        width: double.infinity,
        height: minHeight,
        child:
            widget.placeholder ??
            const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error) {
      return SizedBox(
        width: double.infinity,
        height: minHeight,
        child:
            widget.errorWidget ??
            const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
      );
    }

    if (_imageData != null && _aspectRatio != null) {
      return ConstrainedBox(
        constraints: BoxConstraints(minHeight: minHeight),
        child: AspectRatio(
          aspectRatio: _aspectRatio!,
          child: Image.memory(_imageData!, fit: widget.fit),
        ),
      );
    }

    return widget.errorWidget ??
        const Center(child: Icon(Icons.broken_image, color: Colors.grey));
  }
}
