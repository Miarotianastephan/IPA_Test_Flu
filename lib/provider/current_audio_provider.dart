import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/models/manga.dart';



final currentAudioProvider = StateProvider<Manga?>((ref) => null);