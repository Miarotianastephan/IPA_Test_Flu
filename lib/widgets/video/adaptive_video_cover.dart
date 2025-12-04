import 'dart:io' as io;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:live_app/widgets/encrypted_image.dart';

import '../../api/api_client.dart';
import '../../config/cache_manager.dart';

class AdaptiveVideoCover extends StatefulWidget {
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
  State<AdaptiveVideoCover> createState() => _AdaptiveVideoCoverState();
}

class _AdaptiveVideoCoverState extends State<AdaptiveVideoCover> {
  double? _aspectRatio;
  Uint8List? _imageData;
  bool _loading = true;
  bool _error = false;

  final _apiClient = ApiClient();
  final _cacheManager = UniversalCacheManager();

  @override
  void initState() {
    super.initState();
    _loadImageAndCalculateRatio();
  }

  Future<Uint8List> _decrypt(Uint8List data) async {
    final decrypted = data.map((b) => b ^ 0xFF).toList();
    return Uint8List.fromList(decrypted);
  }

  Future<void> _loadImageAndCalculateRatio() async {
    try {
      Uint8List bytes;

      io.File? cachedFile = await _cacheManager.getFile(
        widget.url,
        manager: _cacheManager.customCacheManager(key: "images_cache"),
      );

      if (!mounted) return;

      if (cachedFile != null) {
        bytes = await cachedFile.readAsBytes();
      } else {
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

        if (widget.url.toLowerCase().endsWith(".pdf")) {
          bytes = await _decrypt(bytes);
          if (!mounted) return;
        }

        final tempFile = await _cacheManager.getFile(
          widget.url,
          manager: _cacheManager.customCacheManager(key: "images_cache"),
        );

        if (tempFile != null) {
          await tempFile.writeAsBytes(bytes);
        }
      }

      if (!mounted) return;

      final image = await decodeImageFromList(bytes);
      final aspectRatio = image.width / image.height;

      if (!mounted) return;

      setState(() {
        _imageData = bytes;
        _aspectRatio = aspectRatio;
        _loading = false;
      });
    } catch (e, st) {
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
    final screenHeight = MediaQuery.of(context).size.height;

    if (widget.videoType == 1) {
      return SizedBox(
        width: double.infinity,
        height: screenHeight * 0.28,
        child: EncryptedImage(
          url: widget.url,
          fit: widget.fit,
          placeholder: widget.placeholder,
          errorWidget: widget.errorWidget,
        ),
      );
    }

    if (_loading) {
      return widget.placeholder ??
          const Center(child: CircularProgressIndicator());
    }

    if (_error) {
      return widget.errorWidget ??
          const Center(child: Icon(Icons.broken_image, color: Colors.grey));
    }

    if (_imageData != null && _aspectRatio != null) {
      return ConstrainedBox(
        constraints: BoxConstraints(minHeight: screenHeight * 0.11),
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
