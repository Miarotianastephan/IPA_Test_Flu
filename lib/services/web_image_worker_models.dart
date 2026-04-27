class WebImageLayoutData {
  final bool isSvg;
  final int width;
  final int height;

  const WebImageLayoutData({
    required this.isSvg,
    required this.width,
    required this.height,
  });

  double get aspectRatio {
    if (width <= 0 || height <= 0) {
      return 0.75;
    }
    return width / height;
  }
}

class WebImageDisplayData extends WebImageLayoutData {
  final String? objectUrl;
  final String? svgText;

  const WebImageDisplayData({
    required super.isSvg,
    required super.width,
    required super.height,
    this.objectUrl,
    this.svgText,
  });
}
