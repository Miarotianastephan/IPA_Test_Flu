import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/models/video_info.dart';

final currentVideoProvider = StateProvider<VideoInfo?>((ref) => null);
