import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/models/chapter_manga.dart';
import 'package:live_app/provider/i18n_provider.dart';

class EpisodeDetailPage extends ConsumerStatefulWidget {
  final String mangaTitle;
  final String mangaCover;
  final String mangaDescription;
  final List<ChapterManga> chapters;
  final int initialChapter;
  final int initialEpisode;
  const EpisodeDetailPage({
    super.key,
    required this.mangaTitle,
    required this.mangaCover,
    required this.mangaDescription,
    required this.chapters,
    this.initialChapter = 1,
    this.initialEpisode = 1,
  });
  @override
  ConsumerState<EpisodeDetailPage> createState() => _EpisodeDetailPageState();
}

class _EpisodeDetailPageState extends ConsumerState<EpisodeDetailPage> {
  late int selectedChapter;
  late int selectedEpisode;
  bool showSelectors = false;
  bool showUI = true;
  Timer? _hideTimer;
  final ScrollController _scrollController = ScrollController();
  String translate(String key) =>
      ref.read(i18nNotifierProvider.notifier).translate(key);
  @override
  void initState() {
    super.initState();
    selectedChapter = widget.initialChapter;
    selectedEpisode = widget.initialEpisode;
    _startHideTimer();
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOut,
    );
  }

  void _toggleUI() {
    setState(() {
      showUI = !showUI;
    });

    if (showUI) {
      _startHideTimer();
    } else {
      _hideTimer?.cancel();
    }
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 10), () {
      setState(() {
        showUI = false;
      });
    });
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentChapter = widget.chapters[selectedChapter - 1];
    final currentEpisode = currentChapter.episodes[selectedEpisode - 1];

    return Scaffold(
      extendBodyBehindAppBar: showSelectors ? false : true,
      appBar: showUI || showSelectors == true
          ? AppBar(
              backgroundColor: Colors.black38,
              automaticallyImplyLeading: showSelectors ? false : true,
              elevation: 0.0,
              title: showSelectors == false
                  ? Text(
                      "${translate("chapter")} ${widget.chapters[selectedChapter - 1].chapterNumber} "
                      "- ${translate("episode")} ${widget.chapters[selectedChapter - 1].episodes[selectedEpisode - 1].number}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
              actions: [
                IconButton(
                  icon: Icon(
                    showSelectors ? Icons.cancel_outlined : Icons.info_outline,
                  ),
                  onPressed: () {
                    setState(() {
                      showSelectors = !showSelectors;
                    });
                  },
                ),
              ],
            )
          : null,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: showSelectors == true ? null : _toggleUI,
        child: Stack(
          children: [
            Positioned.fill(
              child: Scrollable(
                controller: _scrollController,
                axisDirection: AxisDirection.down,
                viewportBuilder: (context, position) {
                  return Viewport(
                    axisDirection: AxisDirection.down,
                    offset: position,
                    slivers: [
                      SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final img = currentEpisode.mangasImages[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2.0),
                            child: Image.network(
                              img.s3ImageUrl,
                              fit: BoxFit.contain,
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              },
                            ),
                          );
                        }, childCount: currentEpisode.mangasImages.length),
                      ),
                    ],
                  );
                },
              ),
            ),
            if (showSelectors)
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 400),
                crossFadeState: showSelectors
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,

                firstChild: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 8,
                    ),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            widget.mangaCover,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 12.0),
                        Text(
                          widget.mangaTitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8.0),
                        Text(
                          widget.mangaDescription,
                          style: TextStyle(fontSize: 18.0),
                        ),
                        SizedBox(height: 8.0),
                        Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(10.0),
                                ),
                                color: Colors.white70,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Text(
                                  "${translate("chapter")} ${widget.chapters[selectedChapter - 1].chapterNumber} : ",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8.0),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  final val = await showDialog<int>(
                                    context: context,
                                    builder: (context) {
                                      return SimpleDialog(
                                        title: Text(translate("chooseChapter")),
                                        children: widget.chapters
                                            .asMap()
                                            .entries
                                            .map((entry) {
                                              final i = entry.key;
                                              final chapter = entry.value;
                                              final title =
                                                  chapter.titles.isNotEmpty
                                                  ? chapter.titles[0].title
                                                  : chapter.title;

                                              return SimpleDialogOption(
                                                onPressed: () {
                                                  Navigator.pop(context, i + 1);
                                                  _scrollToTop();
                                                },
                                                child: Text(
                                                  "${translate("chapter")} ${chapter.chapterNumber} : $title",
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              );
                                            })
                                            .toList(),
                                      );
                                    },
                                  );

                                  if (val != null) {
                                    setState(() {
                                      selectedChapter = val;
                                      selectedEpisode = 1;
                                    });
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  alignment: Alignment.centerLeft,
                                ),
                                child: Text(
                                  widget
                                          .chapters[selectedChapter - 1]
                                          .titles
                                          .isNotEmpty
                                      ? widget
                                            .chapters[selectedChapter - 1]
                                            .titles[0]
                                            .title
                                      : widget
                                            .chapters[selectedChapter - 1]
                                            .title,
                                  textAlign: TextAlign.start,
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),

                        Row(
                          children: [
                            Container(
                              decoration: const BoxDecoration(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10.0),
                                ),
                                color: Colors.white70,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Text(
                                  "${translate("episode")} ${currentChapter.episodes[selectedEpisode - 1].number} : ",

                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8.0),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  final val = await showDialog<int>(
                                    context: context,
                                    builder: (context) {
                                      return SimpleDialog(
                                        title: Text(translate("chooseEpisode")),
                                        children: currentChapter.episodes
                                            .asMap()
                                            .entries
                                            .map((entry) {
                                              final i = entry.key;
                                              final ep = entry.value;

                                              return SimpleDialogOption(
                                                onPressed: () {
                                                  Navigator.pop(context, i + 1);
                                                  _scrollToTop();
                                                },
                                                child: Text(
                                                  "${translate("episode")} ${ep.number} : ${ep.name}",
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              );
                                            })
                                            .toList(),
                                      );
                                    },
                                  );

                                  if (val != null) {
                                    setState(() => selectedEpisode = val);
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  alignment: Alignment.centerLeft,
                                ),
                                child: Text(
                                  currentChapter
                                      .episodes[selectedEpisode - 1]
                                      .name,
                                  textAlign: TextAlign.start,
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                secondChild: const SizedBox.shrink(),
              ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: showUI
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (selectedEpisode > 1 || selectedChapter > 1)
                  FloatingActionButton.extended(
                    backgroundColor: Colors.black38,
                    heroTag: "prev",
                    icon: const Icon(Icons.arrow_back),
                    label: Text(
                      selectedEpisode > 1
                          ? translate("previousEpisode")
                          : translate("previousChapter"),
                    ),
                    onPressed: () {
                      setState(() {
                        if (selectedEpisode > 1) {
                          selectedEpisode--;
                        } else if (selectedChapter > 1) {
                          selectedChapter--;
                          selectedEpisode = widget
                              .chapters[selectedChapter - 1]
                              .episodes
                              .length;
                        }
                      });
                      _scrollToTop();
                    },
                  ),
                if ((selectedEpisode > 1 || selectedChapter > 1) &&
                    (selectedEpisode < currentChapter.episodes.length ||
                        selectedChapter < widget.chapters.length))
                  const SizedBox(width: 16),
                if (selectedEpisode < currentChapter.episodes.length ||
                    selectedChapter < widget.chapters.length)
                  FloatingActionButton.extended(
                    backgroundColor: Colors.black38,
                    heroTag: "next",
                    icon: const Icon(Icons.arrow_forward),
                    label: Text(
                      selectedEpisode < currentChapter.episodes.length
                          ? translate("nextEpisode")
                          : translate("nextChapter"),
                    ),
                    onPressed: () {
                      setState(() {
                        if (selectedEpisode < currentChapter.episodes.length) {
                          selectedEpisode++;
                        } else if (selectedChapter < widget.chapters.length) {
                          selectedChapter++;
                          selectedEpisode = 1;
                        }
                      });
                      _scrollToTop();
                    },
                  ),
              ],
            )
          : null,
    );
  }
}
