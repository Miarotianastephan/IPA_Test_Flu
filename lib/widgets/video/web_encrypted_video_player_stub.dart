import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WebEncryptedVideoPlayer extends ConsumerWidget {
  final String videoUrl;
  final String encryptionKey;

  const WebEncryptedVideoPlayer({
    super.key,
    required this.videoUrl,
    required this.encryptionKey,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    throw UnsupportedError('WebEncryptedVideoPlayer is only supported on web');
  }
}
