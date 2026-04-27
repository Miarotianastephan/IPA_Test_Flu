import 'package:flutter/material.dart';
import 'package:live_app/models/audio.dart';
import 'package:live_app/models/manga.dart';
import 'package:live_app/models/roman.dart';
import 'package:live_app/page/novel_grid.dart';
import 'package:live_app/widgets/empty_widget.dart';

class CreatorDetailPage extends StatefulWidget {
  final String creatorName;
  final int creatorId;
  final String creatorAvatar;
  final List<dynamic> items;

  const CreatorDetailPage({
    super.key,
    required this.creatorName,
    required this.creatorId,
    required this.creatorAvatar,
    required this.items,
  });

  @override
  State<CreatorDetailPage> createState() => _CreatorDetailPageState();
}

class _CreatorDetailPageState extends State<CreatorDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController outerController;
  late List<String> categories;

  @override
  void initState() {
    super.initState();
    categories = widget.items
        .map((item) {
          if (item is Manga) {
            return item.mangasCategory.name.isNotEmpty
                ? item.mangasCategory.name
                : item.ref;
          }
          if (item is Roman) {
            return item.category.name;
          }
          if (item is Audio) {
            return item.audioCategory.name;
          }
          return "Autre";
        })
        .toSet()
        .toList();

    outerController = TabController(length: categories.length, vsync: this);
  }

  @override
  void dispose() {
    outerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundImage: NetworkImage(widget.creatorAvatar),
          ),
          const SizedBox(height: 12),
          Text(
            widget.creatorName,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          TabBar(
            controller: outerController,
            isScrollable: true,
            tabs: categories.map((cat) => Tab(text: cat)).toList(),
            labelColor: Colors.white,
            labelStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 14,
              color: Color.fromRGBO(255, 255, 255, 0.8),
            ),
          ),
          Expanded(
            child: Container(
              color: const Color.fromARGB(20, 96, 125, 139),
              child: TabBarView(
                controller: outerController,
                children: categories.map((cat) {
                  final filtered = widget.items.where((item) {
                    if (item is Manga) {
                      return (item.mangasCategory.name.isNotEmpty
                              ? item.mangasCategory.name
                              : item.ref) ==
                          cat;
                    }
                    if (item is Roman) {
                      return item.category.name == cat;
                    }
                    if (item is Audio) {
                      return (item.audioCategory.name) == cat;
                    }
                    return false;
                  }).toList();

                  if (filtered.isEmpty) {
                    return EmptyWidget();
                  }

                  final first = filtered.first;
                  if (first is Manga) {
                    return _buildMangaSection(filtered.cast<Manga>());
                  } else if (first is Roman) {
                    return _buildRomanSection(filtered.cast<Roman>());
                  } else if (first is Audio) {
                    return _buildAudioSection(filtered.cast<Audio>());
                  }

                  return const SizedBox.shrink();
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildMangaSection(List<Manga> mangas) {
  return NovelGrid(items: mangas, showCreatorInfo: false);
}

Widget _buildRomanSection(List<Roman> roman) {
  return NovelGrid(items: roman, showCreatorInfo: false);
}

Widget _buildAudioSection(List<Audio> audios) {
  return NovelGrid(items: audios, showCreatorInfo: false, isAudio: true);
}
