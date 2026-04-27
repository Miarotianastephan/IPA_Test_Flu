import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:live_app/models/audio.dart';
import 'package:live_app/models/track_audio.dart';
import 'package:live_app/models/userinfo.dart';
import 'package:live_app/page/chat_detail_page.dart';
import 'package:live_app/page/download_page.dart';
import 'package:live_app/page/group_chat_detail_page.dart';
import 'package:live_app/page/track_player_page.dart';
import 'package:live_app/widgets/video_screen.dart';

Widget buildChatDetailPage(Object? arguments) {
  final args = arguments as Map?;
  final userJson = args?['user'];
  final user = UserInfo.fromJson(jsonDecode(userJson as String));
  return ChatDetailPage(user: user);
}

Widget buildGroupChatDetailPage(Object? arguments) {
  final args = arguments as Map?;
  final conversationIdValue = args?['conversationId'];
  final conversationId = conversationIdValue is int
      ? conversationIdValue
      : int.parse(conversationIdValue as String);
  return GroupChatDetailPage(conversationId: conversationId);
}

Widget buildDownloadsPage(Object? arguments) {
  return const DownloadsPage();
}

Widget buildVideoPage(Object? arguments) {
  final args = arguments as Map?;
  final path = args?['path'] as String;
  return VideoScreen(localPath: path);
}

Widget buildTrackPlayerPage(Object? arguments) {
  final args = arguments as Map?;
  final tracks = args?['tracks'] as List<TrackAudio>? ?? [];
  final audio = args?['audio'] as Audio;
  final initialIndex = args?['initialIndex'] as int? ?? 0;
  return TrackPlayerPage(
    tracks: tracks,
    audio: audio,
    initialIndex: initialIndex,
  );
}
