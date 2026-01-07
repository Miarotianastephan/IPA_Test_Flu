import 'package:flutter/material.dart';
import 'package:live_app/models/manga.dart';
import 'package:live_app/models/roman.dart';
import 'package:live_app/page/creator_detail_page.dart';
import 'package:live_app/page/episode_detail_page.dart';
import 'package:live_app/page/roman_detail_page.dart';

class NovelCard extends StatelessWidget {
  final dynamic item;
  final bool showCreatorInfo;
  const NovelCard({super.key, required this.item, this.showCreatorInfo = true});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (item is Manga) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EpisodeDetailPage(
                mangaTitle: item.titles.isNotEmpty ? item.titles[0].title : "",
                mangaCover: item.s3CoverUrl,
                mangaDescription: item.titles.isNotEmpty
                    ? item.titles[0].description
                    : "",
                chapters: item.chapters,
                initialChapter: 1,
                initialEpisode: 1,
              ),
            ),
          );
        } else if (item is Roman) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => RomanReaderPage(roman: item)),
          );
        }
      },
      child: Card(
        elevation: 6,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 3 / 4,
              child: Image.network(item.s3CoverUrl, fit: BoxFit.cover),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 4.0,
              ),
              child: Text(
                item.titles.isNotEmpty ? item.titles[0].title : "",
                textAlign: TextAlign.start,
                style: const TextStyle(fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                item.titles.isNotEmpty ? item.titles[0].description : "",
                textAlign: TextAlign.start,
                style: const TextStyle(color: Colors.grey),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (showCreatorInfo)
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
                          creatorName: item.creatorObj.name,
                          creatorId: item.creatorObj.id,
                          creatorAvatar: item.creatorObj.avatar ?? "",
                          items: [item],
                        ),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 15.0,
                        backgroundImage: NetworkImage(
                          item.creatorObj.avatar ?? "",
                        ),
                      ),

                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item.creatorObj.name,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
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
    );
  }
}
