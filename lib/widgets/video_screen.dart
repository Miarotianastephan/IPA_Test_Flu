import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:live_app/widgets/video/mobile_video_player.dart';
import 'package:live_app/widgets/video/web_video_player.dart';

class VideoScreen extends StatefulWidget {
  final String videoUrl;

  const VideoScreen({super.key, required this.videoUrl});

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  @override
  Widget build(BuildContext context) {
    return kIsWeb
        ? WebVideoPlayer(videoUrl: widget.videoUrl)
        : MobileVideoPlayer(videoUrl: widget.videoUrl);
  }
}
