import 'dart:typed_data';

import '../utils/text_util.dart';

class ImageLayoutInfo {
  final bool isSvg;
  final double aspectRatio;

  const ImageLayoutInfo({required this.isSvg, required this.aspectRatio});
}

class ReadImageLayoutParams {
  final Uint8List bytes;
  final String url;

  const ReadImageLayoutParams({required this.bytes, required this.url});
}

String? webWorkerFileType(String url) {
  final fileType = getImageFileType(url);
  switch (fileType) {
    case ImageFileType.enc:
      return 'enc';
    case ImageFileType.pdf:
      return 'pdf';
    case null:
      return null;
  }
}

ImageLayoutInfo readImageLayoutInBackground(ReadImageLayoutParams params) {
  final isSvg = isImageSvgUrl(params.url) || isImageSvgBytes(params.bytes);
  if (isSvg) {
    final svgRatio = tryReadSvgAspectRatio(params.bytes);
    return ImageLayoutInfo(isSvg: true, aspectRatio: svgRatio ?? 0.75);
  }

  final dimensions = extractEncodedImageDimensions(params.bytes);
  if (dimensions == null || dimensions.height <= 0) {
    return const ImageLayoutInfo(isSvg: false, aspectRatio: 0.75);
  }

  return ImageLayoutInfo(
    isSvg: false,
    aspectRatio: dimensions.width / dimensions.height,
  );
}

bool isImageSvgUrl(String url) {
  final lower = url.toLowerCase();
  return lower.endsWith('.svg.enc') ||
      lower.endsWith('.svg.pdf') ||
      lower.endsWith('.svg');
}

bool isImageSvgBytes(Uint8List bytes) {
  if (bytes.length < 5) {
    return false;
  }

  final header = String.fromCharCodes(bytes.take(256));
  return header.trimLeft().startsWith('<svg') ||
      header.trimLeft().startsWith('<?xml');
}

double? tryReadSvgAspectRatio(Uint8List bytes) {
  final text = String.fromCharCodes(bytes.take(1024));

  final viewBoxMatch = RegExp(
    r"""viewBox\s*=\s*['"]\s*[-\d.]+\s+[-\d.]+\s+([-\d.]+)\s+([-\d.]+)\s*['"]""",
    caseSensitive: false,
  ).firstMatch(text);
  if (viewBoxMatch != null) {
    final width = double.tryParse(viewBoxMatch.group(1)!);
    final height = double.tryParse(viewBoxMatch.group(2)!);
    if (width != null && height != null && width > 0 && height > 0) {
      return width / height;
    }
  }

  final widthMatch = RegExp(
    r"""width\s*=\s*['"]\s*([-\d.]+)""",
    caseSensitive: false,
  ).firstMatch(text);
  final heightMatch = RegExp(
    r"""height\s*=\s*['"]\s*([-\d.]+)""",
    caseSensitive: false,
  ).firstMatch(text);
  if (widthMatch != null && heightMatch != null) {
    final width = double.tryParse(widthMatch.group(1)!);
    final height = double.tryParse(heightMatch.group(1)!);
    if (width != null && height != null && width > 0 && height > 0) {
      return width / height;
    }
  }

  return null;
}

ImageDimensions? extractEncodedImageDimensions(Uint8List bytes) {
  if (bytes.length < 24) {
    return null;
  }

  final png = tryReadPngDimensions(bytes);
  if (png != null) {
    return png;
  }

  final jpeg = tryReadJpegDimensions(bytes);
  if (jpeg != null) {
    return jpeg;
  }

  final gif = tryReadGifDimensions(bytes);
  if (gif != null) {
    return gif;
  }

  final webp = tryReadWebpDimensions(bytes);
  if (webp != null) {
    return webp;
  }

  final bmp = tryReadBmpDimensions(bytes);
  if (bmp != null) {
    return bmp;
  }

  return null;
}

ImageDimensions? tryReadPngDimensions(Uint8List bytes) {
  const pngSignature = <int>[137, 80, 78, 71, 13, 10, 26, 10];
  for (var i = 0; i < pngSignature.length; i++) {
    if (bytes[i] != pngSignature[i]) {
      return null;
    }
  }

  final width = readUint32Be(bytes, 16);
  final height = readUint32Be(bytes, 20);
  if (width <= 0 || height <= 0) {
    return null;
  }

  return ImageDimensions(width: width, height: height);
}

ImageDimensions? tryReadGifDimensions(Uint8List bytes) {
  final header = String.fromCharCodes(bytes.take(6));
  if (header != 'GIF87a' && header != 'GIF89a') {
    return null;
  }

  final width = readUint16Le(bytes, 6);
  final height = readUint16Le(bytes, 8);
  if (width <= 0 || height <= 0) {
    return null;
  }

  return ImageDimensions(width: width, height: height);
}

ImageDimensions? tryReadBmpDimensions(Uint8List bytes) {
  if (bytes[0] != 0x42 || bytes[1] != 0x4D || bytes.length < 26) {
    return null;
  }

  final width = readInt32Le(bytes, 18).abs();
  final height = readInt32Le(bytes, 22).abs();
  if (width <= 0 || height <= 0) {
    return null;
  }

  return ImageDimensions(width: width, height: height);
}

ImageDimensions? tryReadWebpDimensions(Uint8List bytes) {
  if (bytes.length < 30 ||
      String.fromCharCodes(bytes.sublist(0, 4)) != 'RIFF' ||
      String.fromCharCodes(bytes.sublist(8, 12)) != 'WEBP') {
    return null;
  }

  final chunkType = String.fromCharCodes(bytes.sublist(12, 16));
  if (chunkType == 'VP8X' && bytes.length >= 30) {
    final width = 1 + readUint24Le(bytes, 24);
    final height = 1 + readUint24Le(bytes, 27);
    return ImageDimensions(width: width, height: height);
  }

  if (chunkType == 'VP8 ' && bytes.length >= 30) {
    final width = readUint16Le(bytes, 26) & 0x3FFF;
    final height = readUint16Le(bytes, 28) & 0x3FFF;
    if (width > 0 && height > 0) {
      return ImageDimensions(width: width, height: height);
    }
  }

  if (chunkType == 'VP8L' && bytes.length >= 25) {
    final b0 = bytes[21];
    final b1 = bytes[22];
    final b2 = bytes[23];
    final b3 = bytes[24];
    final width = 1 + (((b1 & 0x3F) << 8) | b0);
    final height = 1 + (((b3 & 0x0F) << 10) | (b2 << 2) | ((b1 & 0xC0) >> 6));
    if (width > 0 && height > 0) {
      return ImageDimensions(width: width, height: height);
    }
  }

  return null;
}

ImageDimensions? tryReadJpegDimensions(Uint8List bytes) {
  if (bytes.length < 4 || bytes[0] != 0xFF || bytes[1] != 0xD8) {
    return null;
  }

  var offset = 2;
  while (offset + 9 < bytes.length) {
    if (bytes[offset] != 0xFF) {
      offset++;
      continue;
    }

    final marker = bytes[offset + 1];
    if (marker == 0xD8 || marker == 0xD9) {
      offset += 2;
      continue;
    }

    if (marker == 0x01 || (marker >= 0xD0 && marker <= 0xD7)) {
      offset += 2;
      continue;
    }

    if (offset + 4 >= bytes.length) {
      return null;
    }

    final segmentLength = readUint16Be(bytes, offset + 2);
    if (segmentLength < 2 || offset + 2 + segmentLength > bytes.length) {
      return null;
    }

    if (isJpegSofMarker(marker)) {
      final height = readUint16Be(bytes, offset + 5);
      final width = readUint16Be(bytes, offset + 7);
      if (width > 0 && height > 0) {
        return ImageDimensions(width: width, height: height);
      }
      return null;
    }

    offset += 2 + segmentLength;
  }

  return null;
}

bool isJpegSofMarker(int marker) {
  switch (marker) {
    case 0xC0:
    case 0xC1:
    case 0xC2:
    case 0xC3:
    case 0xC5:
    case 0xC6:
    case 0xC7:
    case 0xC9:
    case 0xCA:
    case 0xCB:
    case 0xCD:
    case 0xCE:
    case 0xCF:
      return true;
    default:
      return false;
  }
}

int readUint16Be(Uint8List bytes, int offset) {
  return (bytes[offset] << 8) | bytes[offset + 1];
}

int readUint16Le(Uint8List bytes, int offset) {
  return bytes[offset] | (bytes[offset + 1] << 8);
}

int readUint24Le(Uint8List bytes, int offset) {
  return bytes[offset] | (bytes[offset + 1] << 8) | (bytes[offset + 2] << 16);
}

int readUint32Be(Uint8List bytes, int offset) {
  return (bytes[offset] << 24) |
      (bytes[offset + 1] << 16) |
      (bytes[offset + 2] << 8) |
      bytes[offset + 3];
}

int readInt32Le(Uint8List bytes, int offset) {
  final value =
      bytes[offset] |
      (bytes[offset + 1] << 8) |
      (bytes[offset + 2] << 16) |
      (bytes[offset + 3] << 24);
  return value.toSigned(32);
}

class ImageDimensions {
  final int width;
  final int height;

  const ImageDimensions({required this.width, required this.height});
}
