import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/models/audio.dart';
import 'package:live_app/page/audio_detail_page.dart';
import 'package:live_app/page/creator_detail_page.dart';

import 'package:live_app/provider/current_audio_provider.dart';
import 'package:palette_generator_master/palette_generator_master.dart';

class AudioNovelCard extends ConsumerStatefulWidget {
  final Audio item;
  final bool showCreatorInfo;
  const AudioNovelCard({
    super.key,
    required this.item,
    this.showCreatorInfo = true,
  });
  @override
  ConsumerState<AudioNovelCard> createState() => _AudioNovelCardState();
}

class _AudioNovelCardState extends ConsumerState<AudioNovelCard> {
  Color dominantColor = Colors.white;
  bool isWhite(Color c) => c.r == 255 && c.g == 255 && c.b == 255 && c.a == 255;

  @override
  void initState() {
    super.initState();
    _updatePalette(widget.item.s3CoverUrl);
  }

  Future<void> _updatePalette(String imageUrl) async {
    try {
      final PaletteGeneratorMaster paletteGenerator =
          await PaletteGeneratorMaster.fromImageProvider(
            NetworkImage(imageUrl),
          );
      setState(() {
        dominantColor = paletteGenerator.dominantColor?.color ?? Colors.white;
      });
    } catch (e) {
      debugPrint("Palette error: $e");
    }
  }

  Color getAdaptiveTextColor(Color dominant) {
    if (isWhite(dominant)) {
      return Colors.black;
    } else {
      return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        if (widget.item.album == null) {
          ref.read(currentAudioProvider.notifier).state = widget.item;
          final player = ref.read(audioPlayerProvider);
          await player.play(UrlSource(widget.item.s3AudioUrl));
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AudioDetailPage(audio: widget.item),
            ),
          );
        }
      },
      child: Card(
        elevation: 6,
        child: Container(
          decoration: BoxDecoration(
            color: dominantColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  AspectRatio(
                    aspectRatio: 9 / 7,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.network(
                            widget.item.s3CoverUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        ),
                        Icon(
                          widget.item.album == null
                              ? Icons.headphones_outlined
                              : Icons.album,
                          color: Colors.grey[100],
                          size: 50.0,
                          shadows: const [
                            Shadow(
                              color: Colors.black,
                              blurRadius: 4.0,
                              offset: Offset(2, 2),
                            ),
                            Shadow(
                              color: Colors.black54,
                              blurRadius: 8.0,
                              offset: Offset(-2, -2),
                            ),
                            Shadow(
                              color: Colors.purpleAccent,
                              blurRadius: 12.0,
                              offset: Offset(0, 0),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 4.0,
                    ),
                    child: Text(
                      widget.item.titles.isNotEmpty
                          ? widget.item.titles[0].title
                          : "",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: getAdaptiveTextColor(dominantColor),
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      widget.item.titles.isNotEmpty
                          ? widget.item.titles[0].description
                          : "",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: getAdaptiveTextColor(
                          dominantColor,
                        ).withValues(alpha: 0.8),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              if (widget.showCreatorInfo)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 8.0,
                  ),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CreatorDetailPage(
                            creatorName: widget.item.creatorObj!.name,
                            creatorId: widget.item.creatorObj!.id,
                            creatorAvatar: widget.item.creatorObj!.avatar ?? "",
                            items: [widget.item],
                          ),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 15.0,
                          backgroundImage: NetworkImage(
                            widget.item.creatorObj!.avatar ?? "",
                          ),
                        ),

                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.item.creatorObj!.name,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: getAdaptiveTextColor(
                                dominantColor,
                              ).withValues(alpha: 0.8),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
