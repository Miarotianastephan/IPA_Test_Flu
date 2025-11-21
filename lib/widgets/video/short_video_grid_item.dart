import 'package:flutter/material.dart';
import 'package:live_app/l10n/app_localizations.dart';
import 'package:live_app/models/video_info.dart';

class ShortVideoGridItem extends StatefulWidget {
  final VideoInfo videoInfo;
  final int index;

  const ShortVideoGridItem({
    super.key,
    required this.videoInfo,
    required this.index,
  });

  @override
  State<StatefulWidget> createState() {
    return ShortVideoGridState();
  }
}

class ShortVideoGridState extends State<ShortVideoGridItem> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.primaries[widget.index % Colors.primaries.length],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          "${AppLocalizations.of(context)!.featured} ${widget.index}",
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    );
  }
}
