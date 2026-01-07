import 'package:flutter/material.dart';
import 'package:live_app/models/manga.dart';
import 'package:live_app/page/novel_grid.dart';

class NovelTabPage extends StatelessWidget {
  final String category;
  final List<Manga> items;
  const NovelTabPage({super.key, required this.category, required this.items});

  @override
  Widget build(BuildContext context) {
    return NovelGrid(items: items);
  }
}
