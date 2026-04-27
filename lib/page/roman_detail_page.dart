import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/models/roman.dart';
import 'package:live_app/page/creator_detail_page.dart';
import 'package:live_app/provider/i18n_provider.dart';

class RomanReaderPage extends ConsumerStatefulWidget {
  final Roman roman;
  const RomanReaderPage({super.key, required this.roman});
  @override
  ConsumerState<RomanReaderPage> createState() => _RomanReaderPageState();
}

class _RomanReaderPageState extends ConsumerState<RomanReaderPage> {
  int _currentChapterIndex = 0;
  String _selectedLanguage = "en";
  double _fontSize = 18;
  bool _uiVisible = true;
  Timer? _hideTimer;
  Color _backgroundColor = Colors.black;
  final ScrollController _scrollController = ScrollController();
  Color get textColor =>
      _backgroundColor == Colors.white ? Colors.black : Colors.white;
  String translate(String key) =>
      ref.read(i18nNotifierProvider.notifier).translate(key);

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOut,
    );
  }

  void _showChapterDialog() {
    final chapters = widget.roman.chapters;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        title: Text(
          translate("chooseChapter"),
          style: TextStyle(color: Colors.white),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: chapters.length,
            itemBuilder: (context, index) => ListTile(
              title: Text(
                "${translate("chapter")} ${chapters[index].chapterNumber}",
                style: const TextStyle(color: Colors.white),
              ),
              onTap: () {
                setState(() => _currentChapterIndex = index);
                Navigator.pop(context);
              },
            ),
          ),
        ),
      ),
    );
  }

  void _showLanguageDialog() {
    final languages = widget.roman.chapters[_currentChapterIndex].contents
        .map((c) => c.language.code)
        .toSet()
        .toList();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        title: Text(
          translate("chooseLanguage"),
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: languages.map((lang) {
            return ListTile(
              title: Text(
                lang.toUpperCase(),
                style: const TextStyle(color: Colors.white),
              ),
              onTap: () {
                setState(() => _selectedLanguage = lang);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showSettingsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color.fromARGB(126, 37, 47, 52),
      isScrollControlled: true,
      barrierColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final Color modalTextColor = _backgroundColor == Colors.white
                ? Colors.black
                : Colors.white;

            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      translate("settings"),
                      style: TextStyle(
                        color: modalTextColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text("Aa", style: TextStyle(color: modalTextColor)),
                        Expanded(
                          child: Slider(
                            thumbColor: Colors.white,
                            activeColor: Colors.grey,
                            value: _fontSize,
                            min: 14,
                            max: 24,
                            divisions: 5,
                            label: "${_fontSize.toInt()}",
                            onChanged: (v) {
                              setState(() => _fontSize = v);
                              setModalState(() {});
                            },
                          ),
                        ),
                        Text(
                          "Aa",
                          style: TextStyle(color: modalTextColor, fontSize: 24),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Wrap(
                            spacing: 12,
                            children:
                                [
                                  Colors.white,
                                  Colors.black,
                                  Colors.green,
                                  Colors.pink,
                                  Colors.blue,
                                  Colors.orange,
                                ].map((color) {
                                  final isSelected = _backgroundColor == color;
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() => _backgroundColor = color);
                                      setModalState(() {});
                                    },
                                    child: Container(
                                      width: 30,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        color: color,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: isSelected
                                              ? Colors.blueAccent
                                              : color == Colors.black
                                              ? Colors.white70
                                              : Colors.transparent,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[800],
                            ),
                            icon: const Icon(
                              Icons.color_lens,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  Color tempColor = _backgroundColor;
                                  return AlertDialog(
                                    backgroundColor: Colors.black,
                                    title: Text(
                                      translate("selectColor"),
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    content: SingleChildScrollView(
                                      child: ColorPicker(
                                        pickerColor: tempColor,
                                        onColorChanged: (c) => tempColor = c,
                                        enableAlpha: false,
                                        pickerAreaHeightPercent: 0.8,
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        child: Text(
                                          translate("cancel"),
                                          style: TextStyle(
                                            color: Colors.white70,
                                          ),
                                        ),
                                        onPressed: () => Navigator.pop(context),
                                      ),
                                      TextButton(
                                        child: Text(
                                          translate("ok"),
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        onPressed: () {
                                          setState(
                                            () => _backgroundColor = tempColor,
                                          );
                                          setModalState(() {});
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _startHideTimer();
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 10), () {
      setState(() {
        _uiVisible = false;
      });
    });
  }

  void _toggleUI() {
    setState(() {
      _uiVisible = !_uiVisible;
    });

    if (_uiVisible) {
      _startHideTimer();
    } else {
      _hideTimer?.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    final roman = widget.roman;
    final chapter = roman.chapters[_currentChapterIndex];
    final content = chapter.contents.firstWhere(
      (c) => c.language.code == _selectedLanguage,
      orElse: () => chapter.contents.first,
    );

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: _uiVisible
          ? AppBar(
              backgroundColor: Colors.black,

              actions: [
                IconButton(
                  icon: const Icon(Icons.menu_book, size: 20.0),
                  onPressed: _showChapterDialog,
                ),
                IconButton(
                  icon: const Icon(Icons.language, size: 20.0),
                  onPressed: _showLanguageDialog,
                ),
                IconButton(
                  icon: const Icon(Icons.info_outline, size: 20.0),
                  onPressed: () {
                    final roman = widget.roman;
                    showDialog(
                      context: context,
                      barrierColor: Colors.black87,
                      builder: (context) => AlertDialog(
                        backgroundColor: Colors.black,

                        content: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              if (roman.s3CoverUrl != null)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    roman.s3CoverUrl!,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              const SizedBox(height: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  ...roman.titles
                                      .where(
                                        (t) =>
                                            t.language.code ==
                                            _selectedLanguage,
                                      )
                                      .map((t) {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 2,
                                          ),
                                          child: Text(
                                            t.title,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        );
                                      }),
                                  if (roman.titles.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Text(
                                        roman.titles[0].description,
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => CreatorDetailPage(
                                        creatorName: roman.creatorObj.name,
                                        creatorId: roman.creatorObj.id,
                                        creatorAvatar: roman.creatorObj.avatar,
                                        items: [roman],
                                      ),
                                    ),
                                  );
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      radius: 24,
                                      backgroundImage: NetworkImage(
                                        roman.creatorObj.avatar,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      roman.creatorObj.name,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              _infoRow(
                                translate("category"),
                                roman.category.name,
                              ),
                              _infoRow(
                                translate("chapters"),
                                roman.chaptersCount.toString(),
                              ),
                            ],
                          ),
                        ),

                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              translate("close"),
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.settings, size: 20.0),
                  onPressed: _showSettingsSheet,
                ),
              ],
            )
          : null,
      body: GestureDetector(
        onTap: _toggleUI,
        child: Scrollable(
          controller: _scrollController,
          axisDirection: AxisDirection.down,
          viewportBuilder: (context, position) {
            return Viewport(
              axisDirection: AxisDirection.down,
              offset: position,
              slivers: [
                SliverList(
                  delegate: SliverChildListDelegate([
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          !_uiVisible
                              ? SizedBox(height: 20.0)
                              : SizedBox.shrink(),
                          Text(
                            "${translate("chapter")} ${chapter.chapterNumber}",
                            style: TextStyle(
                              color: textColor,
                              fontSize: _fontSize + 4,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "[${content.language.name}]",
                            style: TextStyle(
                              fontSize: _fontSize - 2,
                              fontStyle: FontStyle.italic,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            content.content,
                            style: TextStyle(
                              color: textColor,
                              fontSize: _fontSize,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ]),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _uiVisible
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_currentChapterIndex > 0)
                  FloatingActionButton.extended(
                    heroTag: "prev",
                    backgroundColor: Colors.black38,
                    icon: const Icon(Icons.arrow_back),
                    label: Text(translate("previousChapter")),
                    onPressed: () {
                      setState(() {
                        _currentChapterIndex = (_currentChapterIndex - 1).clamp(
                          0,
                          widget.roman.chapters.length - 1,
                        );
                      });
                      _scrollToTop();
                    },
                  ),
                if (_currentChapterIndex > 0 &&
                    _currentChapterIndex < widget.roman.chapters.length - 1)
                  const SizedBox(width: 16),
                if (_currentChapterIndex < widget.roman.chapters.length - 1)
                  FloatingActionButton.extended(
                    heroTag: "next",
                    backgroundColor: Colors.black38,
                    icon: const Icon(Icons.arrow_forward),
                    label: Text(translate("nextChapter")),
                    onPressed: () {
                      setState(() {
                        _currentChapterIndex = (_currentChapterIndex + 1).clamp(
                          0,
                          widget.roman.chapters.length - 1,
                        );
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

Widget _infoRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            "$label :",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(value, style: const TextStyle(color: Colors.white70)),
        ),
      ],
    ),
  );
}
