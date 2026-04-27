import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/models/audio.dart';
import 'package:live_app/models/track_audio.dart';
import 'package:live_app/page/creator_detail_page.dart';
import 'package:live_app/page/mini_player_bar.dart';
import 'package:live_app/page/track_player_page.dart';
import 'package:live_app/provider/i18n_provider.dart';
import 'package:live_app/widgets/draggable_fab.dart';
import 'package:live_app/widgets/empty_widget.dart';
import 'package:live_app/provider/current_audio_provider.dart';

class AudioDetailPage extends ConsumerStatefulWidget {
  final Audio audio;
  const AudioDetailPage({super.key, required this.audio});
  @override
  ConsumerState<AudioDetailPage> createState() => _AudioDetailPageState();
}

class _AudioDetailPageState extends ConsumerState<AudioDetailPage> {
  @override
  Widget build(BuildContext context) {
    final List<TrackAudio> tracks =
        widget.audio.album?.tracks.isNotEmpty == true
        ? widget.audio.album!.tracks
        : widget.audio.tracks;

    final currentAudio = ref.watch(currentAudioProvider);
    final showFloating = ref.watch(showFloatingButtonProvider);
    String translate(String key) =>
        ref.read(i18nNotifierProvider.notifier).translate(key);
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: Text(
              widget.audio.titles.isNotEmpty
                  ? widget.audio.titles.first.title
                  : "Album",
            ),
          ),
          body: tracks.isEmpty
              ? const EmptyWidget()
              : Stack(
                  children: [
                    ListView.builder(
                      itemCount: tracks.length,
                      itemBuilder: (context, index) {
                        final track = tracks[index];
                        final isCurrent =
                            currentAudio != null && track.id == currentAudio.id;
                        return Card(
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          color: isCurrent
                              ? Colors.blueGrey.shade700
                              : Colors.black87,
                          child: ListTile(
                            leading: Stack(
                              alignment: Alignment.center,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: Image.network(
                                    widget.audio.s3CoverUrl,
                                    width: 40,
                                    height: 40,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const Icon(
                                  Icons.music_note,
                                  color: Colors.white,
                                  size: 20,
                                  shadows: [
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
                            title: Text(
                              track.title,
                              style: TextStyle(
                                color: isCurrent
                                    ? Colors.blueAccent
                                    : Colors.white,
                                fontWeight: isCurrent
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              track.description,
                              style: TextStyle(
                                color: isCurrent
                                    ? Colors.blueGrey.shade200
                                    : Colors.grey,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.more_horiz,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  barrierColor: const Color.fromARGB(
                                    56,
                                    96,
                                    125,
                                    139,
                                  ),
                                  builder: (context) => AlertDialog(
                                    backgroundColor: Colors.black,
                                    content: SingleChildScrollView(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            child: Image.network(
                                              widget.audio.s3CoverUrl,
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          const SizedBox(height: 12),
                                          if (widget.audio.album != null) ...[
                                            if (widget.audio.titles.isNotEmpty)
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                          top: 8,
                                                        ),
                                                    child: Text(
                                                      widget
                                                          .audio
                                                          .titles[0]
                                                          .title,
                                                      style: const TextStyle(
                                                        color: Colors.white70,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                          top: 8,
                                                        ),
                                                    child: Text(
                                                      widget
                                                          .audio
                                                          .titles[0]
                                                          .description,
                                                      style: const TextStyle(
                                                        color: Colors.white70,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            if (widget.audio.creatorObj != null)
                                              GestureDetector(
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (_) =>
                                                          CreatorDetailPage(
                                                            creatorName: widget
                                                                .audio
                                                                .creatorObj!
                                                                .name,
                                                            creatorId: widget
                                                                .audio
                                                                .creatorObj!
                                                                .id,
                                                            creatorAvatar:
                                                                widget
                                                                    .audio
                                                                    .creatorObj!
                                                                    .avatar ??
                                                                "",
                                                            items: [
                                                              widget.audio,
                                                            ],
                                                          ),
                                                    ),
                                                  );
                                                },
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    CircleAvatar(
                                                      radius: 24,
                                                      backgroundImage:
                                                          NetworkImage(
                                                            widget
                                                                    .audio
                                                                    .creatorObj!
                                                                    .avatar ??
                                                                "",
                                                          ),
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Text(
                                                      widget
                                                          .audio
                                                          .creatorObj!
                                                          .name,
                                                      style: const TextStyle(
                                                        color: Colors.white70,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            const SizedBox(height: 16),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    const Icon(
                                                      Icons.music_note,
                                                      color: Colors.white70,
                                                      size: 20,
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            track.title,
                                                            style:
                                                                const TextStyle(
                                                                  color: Colors
                                                                      .white70,
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                          const SizedBox(
                                                            height: 4,
                                                          ),
                                                          Text(
                                                            track.description,
                                                            style:
                                                                const TextStyle(
                                                                  color: Colors
                                                                      .grey,
                                                                  fontSize: 14,
                                                                ),
                                                            maxLines: 2,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text(
                                          translate("close"),
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            onTap: () async {
                              final player = ref.read(audioPlayerProvider);
                              try {
                                await player.stop();
                              } catch (_) {}
                              Navigator.push(
                                // ignore: use_build_context_synchronously
                                context,
                                MaterialPageRoute(
                                  builder: (_) => TrackPlayerPage(
                                    initialIndex: index,
                                    audio: widget.audio,
                                    tracks: widget.audio.album!.tracks,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                    if (currentAudio != null)
                      Positioned(
                        left: 20,
                        right: 20,
                        bottom: 20,
                        child: GestureDetector(
                          onTap: () {
                            final tracksList =
                                widget.audio.album?.tracks ??
                                widget.audio.tracks;
                            final currentIndex = tracksList.indexWhere(
                              (t) => t.id == currentAudio.id,
                            );
                            final safeIndex = currentIndex >= 0
                                ? currentIndex
                                : 0;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => TrackPlayerPage(
                                  initialIndex: safeIndex,
                                  audio: widget.audio,
                                  tracks: tracksList,
                                ),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Card(
                              color: Colors.black87,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: MiniPlayerBar(
                                currentAudio: currentAudio,
                                tracks: tracks,
                                initialIndex:
                                    tracks.indexWhere(
                                          (t) => t.id == currentAudio.id,
                                        ) >=
                                        0
                                    ? tracks.indexWhere(
                                        (t) => t.id == currentAudio.id,
                                      )
                                    : 0,
                                onClose: () {
                                  ref
                                          .read(
                                            showFloatingButtonProvider.notifier,
                                          )
                                          .state =
                                      true;
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
        ),
        showFloating
            ? DraggableFab(
                key: const ValueKey("fab"),
                cover: widget.audio.s3CoverUrl,
                onPressed: () {
                  ref.read(currentAudioProvider.notifier).state = widget.audio;
                  ref.read(showFloatingButtonProvider.notifier).state = false;
                },
              )
            : SizedBox.shrink(),
      ],
    );
  }
}
