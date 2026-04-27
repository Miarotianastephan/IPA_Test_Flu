import 'package:flutter/material.dart';
import 'package:live_app/models/manga.dart';
import 'package:live_app/models/roman.dart';
import 'package:live_app/page/creator_detail_page.dart';
import 'package:live_app/page/episode_detail_page.dart';
import 'package:live_app/page/roman_detail_page.dart';
import 'package:palette_generator_master/palette_generator_master.dart';

class NovelCard extends StatefulWidget {
  final dynamic item;
  final bool showCreatorInfo;

  const NovelCard({super.key, required this.item, this.showCreatorInfo = true});

  @override
  State<NovelCard> createState() => _NovelCardState();
}

class _NovelCardState extends State<NovelCard> {
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
    final textColor = getAdaptiveTextColor(dominantColor);

    return GestureDetector(
      onTap: () {
        if (widget.item is Manga) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EpisodeDetailPage(
                mangaTitle: widget.item.titles.isNotEmpty
                    ? widget.item.titles[0].title
                    : "",
                mangaCover: widget.item.s3CoverUrl,
                mangaDescription: widget.item.titles.isNotEmpty
                    ? widget.item.titles[0].description
                    : "",
                chapters: widget.item.chapters,
                initialChapter: 1,
                initialEpisode: 1,
              ),
            ),
          );
        } else if (widget.item is Roman) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RomanReaderPage(roman: widget.item),
            ),
          );
        }
      },
      child: Card(
        elevation: 6,
        child: Container(
          decoration: BoxDecoration(
            color: dominantColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              AspectRatio(
                aspectRatio: 3 / 4,
                child: Image.network(widget.item.s3CoverUrl, fit: BoxFit.cover),
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
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: textColor,
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
                  textAlign: TextAlign.start,
                  style: TextStyle(color: textColor.withValues(alpha: 0.8)),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (widget.showCreatorInfo)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 4.0,
                  ),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CreatorDetailPage(
                            creatorName: widget.item.creatorObj.name,
                            creatorId: widget.item.creatorObj.id,
                            creatorAvatar: widget.item.creatorObj.avatar ?? "",
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
                            widget.item.creatorObj.avatar ?? "",
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.item.creatorObj.name,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: textColor,
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
