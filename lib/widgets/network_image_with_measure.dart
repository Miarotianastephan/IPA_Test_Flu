import 'package:flutter/material.dart';
import 'encrypted_image.dart'; // 引入加密图片组件

class NetworkImageWithMeasure extends StatefulWidget {
  final String? imageUrl;
  final ValueChanged<double> onImageMeasured;
  final BoxFit fit;
  final double? width;

  const NetworkImageWithMeasure({
    super.key,
    required this.imageUrl,
    required this.onImageMeasured,
    this.fit = BoxFit.cover,
    this.width,
  });

  @override
  State<NetworkImageWithMeasure> createState() =>
      _NetworkImageWithMeasureState();
}

class _NetworkImageWithMeasureState extends State<NetworkImageWithMeasure> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        return EncryptedImage(
          url: widget.imageUrl ?? "",
          fit: widget.fit,
          width: widget.width ?? constraints.maxWidth,
        );
      },
    );
  }

  @override
  void didUpdateWidget(covariant NetworkImageWithMeasure oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 图片更新时，可能需要重新触发测量
    WidgetsBinding.instance.addPostFrameCallback((_) => _measureHeight());
  }

  void _measureHeight() {
    if (!mounted) return;
    final renderObject = context.findRenderObject();
    if (renderObject is RenderBox) {
      widget.onImageMeasured(renderObject.size.height);
    }
  }
}