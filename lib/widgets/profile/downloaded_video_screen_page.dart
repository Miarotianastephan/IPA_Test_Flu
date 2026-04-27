import 'package:flutter/material.dart';
import 'package:live_app/widgets/video_screen.dart';

class DownloadedVideoScreenPage extends StatelessWidget {
  final String localPath;

  const DownloadedVideoScreenPage({super.key, required this.localPath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          SafeArea(child: VideoScreen(localPath: localPath)),
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 10,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: Navigator.of(context).pop,
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(
                    Icons.chevron_left,
                    color: Colors.white,
                    size: 28,
                    shadows: [
                      Shadow(
                        color: Color(0xE6000000),
                        blurRadius: 12,
                        offset: Offset(0, 0),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
