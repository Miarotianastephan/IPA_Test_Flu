import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/forum_post.dart';

final selectedPostProvider = StateProvider<ForumPost?>((ref) => null);
